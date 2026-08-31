locals {
  # The two processes are two systemd units on one box (ADR-0005 §4 — 案窗 does not hang off the
  # webhook process, because every way rendering a page can die would take POST /line/webhook with
  # it). They are still one machine: the split that ADR buys is a process boundary, not a host.
  webhook-port = 8080
  window-port  = 8081

  # Derived, not read from the secret. LINE compares this string byte for byte against what is
  # registered in the console, case-window.ts refuses to start unless the path is exactly
  # /login/line/callback, and the host has to be the one Caddy holds a certificate for — three
  # places that must agree, so there is one value and it is computed from the hostname. The
  # console's copy is the one thing Terraform cannot reach; README.md says so out loud.
  callback-url = "https://${var.window-hostname}/login/line/callback"

  # 整理's entrance (ADR-0006): the daemon's second socket, and what the 案窗 process dials when
  # a 成員 presses the button. Derived for the same reason the ports are — it is not a secret,
  # and two sides have to agree: main.ts binds TIDYING_HOST:TIDYING_PORT, case-window.ts dials
  # TIDYING_ENTRANCE_URL. One value feeds all three so they cannot drift apart.
  #
  # It stays on loopback, and that is the whole of what makes this entrance private. ADR-0006
  # asks for both processes on one machine or one private segment; here they are two units on
  # this box, so nothing outside it can reach 8082 — and firewall.tf never has to know, because
  # the socket is not bound anywhere it could be asked about.
  #
  # case-window.ts calls required() on the URL, so leaving it out is not a degraded window: the
  # unit exits 2 at boot, and from outside that looks exactly like the daemon being down.
  tidying-host = "127.0.0.1"
  tidying-port = 8082

  env = merge(var.instance-env, {
    LINE_LOGIN_CALLBACK_URL = local.callback-url
    PORT                    = tostring(local.webhook-port)
    CASE_WINDOW_PORT        = tostring(local.window-port)
    TIDYING_HOST            = local.tidying-host
    TIDYING_PORT            = tostring(local.tidying-port)
    TIDYING_ENTRANCE_URL    = "http://${local.tidying-host}:${local.tidying-port}"
  })

  # systemd's EnvironmentFile format: one KEY=value per line. Values are quoted because a Neon
  # connection string or a `openssl rand -base64` secret is allowed to contain a `#`, and an
  # unquoted one would be read as a comment from that character on — a truncated DATABASE_URL
  # that still looks like a configured deployment. Backslash and double quote are escaped;
  # nothing else is special to that parser.
  env-file = join("\n", concat(
    [for k in sort(keys(local.env)) :
      format("%s=\"%s\"", k, replace(replace(local.env[k], "\\", "\\\\"), "\"", "\\\""))
    ],
    [""],
  ))
}

resource "random_password" "instance-password" {
  length           = 40
  special          = true
  override_special = "_%@"
}

# Two keys, two jobs, and neither is a human's. This one exists for the provisioner below and
# dies with the apply; `github-deploy` (deploy-key.tf) is what the box keeps.
resource "tls_private_key" "deploy-only" {
  algorithm = "ED25519"
}

# **A change to `metadata` replaces the instance**, because user_data is read once, at first boot.
# That is the accepted shape here rather than a wart to work around: rotating LINE_CHANNEL_SECRET
# or adding a 成員 rebuilds a three-minute box, and everything that outlives it — 案, 需求圖譜,
# 紀錄, 入站訊息 — is in Neon. What a rebuild does cost is /home/proma/.claude: every case's
# 對話 is dropped, and its next 回合 mints a new one (ADR-0001 §4 prices that loss as 語氣, not
# 需求). Editing /etc/proma/env in place instead would buy nothing and cost the guarantee that
# what Terraform says is on the box is what is on the box.
#
# **The deploy key is a dependency, not a decoration.** cloud-init clones during first boot, so a
# key registered afterwards is a box that fails its own setup script — and the provisioner below
# is what would then report it, several minutes into an apply.
resource "linode_instance" "proma" {
  depends_on = [github_repository_deploy_key.proma]

  label  = "proma"
  image  = "linode/ubuntu24.04"
  region = var.region
  type   = var.instance-type
  authorized_keys = concat(var.ssh_public_keys, [
    trimspace(tls_private_key.deploy-only.public_key_openssh),
  ])
  root_pass = random_password.instance-password.result

  metadata {
    user_data = base64encode(templatefile("${path.module}/templates/init.sh.tpl", {
      swap_gb             = var.swap-gb
      node_major          = var.node-major
      claude_code_version = var.claude-code-version
      github_repo         = var.github-repo
      github_ref          = var.github-ref
      deploy_key_b64      = base64encode(tls_private_key.github-deploy.private_key_openssh)
      env_b64             = base64encode(local.env-file)
      webhook_host        = var.webhook-hostname
      window_host         = var.window-hostname
      webhook_port        = local.webhook-port
      window_port         = local.window-port
    }))
  }

  interface {
    purpose = "public"
  }

  # The same shape as ClodeClaw's: wait for cloud-init, then insist on the sentinel. Without the
  # grep a half-built box is an apply that succeeded — and this one's failure mode is quiet, since
  # a machine with no `claude` on PATH answers every group with 引擎失敗 rather than with an error.
  provisioner "remote-exec" {
    connection {
      type = "ssh"
      user = "root"
      # The instance has one interface, so this set has one member — `ip_address` says the same
      # thing and the provider deprecated it.
      host        = tolist(self.ipv4)[0]
      private_key = tls_private_key.deploy-only.private_key_openssh
    }

    inline = [
      "cloud-init status --wait",
      "grep -q 'Setup complete!' /var/log/cloud-init-output.log || { echo 'Setup script failed! Check /var/log/cloud-init-output.log'; exit 1; }"
    ]
  }
}
