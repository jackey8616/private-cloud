#!/usr/bin/env bash
# PROMA's whole deployment, run once by cloud-init at first boot. Rendered from
# proma/templates/init.sh.tpl — every $${...} in here is Terraform's, and there are no braced
# shell variables at all, on purpose: the two languages spell substitution the same way, so a
# `$${HOME}` written for bash would be read as a template variable and fail the plan. (This very
# line is why the sentence is escaped: `$$` is how a template emits a literal one.)
#
# What it builds: Node, the pinned `claude` CLI, a `proma` user, the application repository, two
# systemd units, and Caddy in front of them holding the certificates for both hostnames.
#
# The last line prints a sentinel the Terraform provisioner greps for. A box that gets partway
# through this file is the failure worth catching, because it is quiet — a machine with no
# `claude` on PATH still boots, still answers the platform's webhook verification with 200, and
# turns every 回合 into 引擎失敗.
set -euo pipefail

# **No `set -x`.** Two of the blobs below are the LINE channel secret, the Neon credentials and
# the Claude subscription token; xtrace would copy each of them into
# /var/log/cloud-init-output.log, which is a second home for 憑證 that nobody would ever come
# back and clean up.
step() {
  echo
  echo "==> $1"
}

export DEBIAN_FRONTEND=noninteractive

# Ubuntu's own unattended-upgrades can be holding the dpkg lock during first boot, and apt-get
# fails outright rather than waiting for it. This is the difference between a deployment that
# works and one that works most mornings.
apt_get() {
  apt-get -o DPkg::Lock::Timeout=300 "$@"
}

step "timezone — the person reading journalctl is in Taiwan"
timedatectl set-timezone Asia/Taipei

step "swap: a nanode has none, and one 回合 peaks around 400MB"
if [ ! -f /swapfile ]; then
  fallocate -l ${swap_gb}G /swapfile
  chmod 600 /swapfile
  mkswap /swapfile
  swapon /swapfile
  echo '/swapfile none swap sw 0 0' >>/etc/fstab
fi

step "base packages"
apt_get update
apt_get install -y ca-certificates curl gnupg git jq sudo \
  debian-keyring debian-archive-keyring apt-transport-https

step "node ${node_major}.x"
# NodeSource rather than the distro package: the application runs .ts files with no build step,
# which needs the type stripping that is on by default from 22.18 — Ubuntu 24.04 ships 18.
curl -fsSL https://deb.nodesource.com/setup_${node_major}.x -o /tmp/nodesource_setup.sh
bash /tmp/nodesource_setup.sh
apt_get install -y nodejs
corepack enable

step "the engine, pinned to ${claude_code_version}"
# src/engine/engine.ts pins the same string and says so once per 回合 when the CLI reports
# anything else. Installed globally rather than per-user because the systemd unit's PATH is the
# only thing that has to find it.
npm install -g "@anthropic-ai/claude-code@${claude_code_version}"

step "caddy"
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' |
  gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' \
  >/etc/apt/sources.list.d/caddy-stable.list
apt_get update
apt_get install -y caddy

step "the proma user — nothing here runs as root"
id -u proma >/dev/null 2>&1 || useradd --create-home --shell /bin/bash proma

step "deploy key and github's host keys"
install -d -m 700 -o proma -g proma /home/proma/.ssh
printf '%s' '${deploy_key_b64}' | base64 -d >/home/proma/.ssh/id_ed25519
chmod 600 /home/proma/.ssh/id_ed25519
chown proma:proma /home/proma/.ssh/id_ed25519
# GitHub's own published host keys, over TLS, rather than ssh-keyscan's trust-on-first-use — the
# first use is the one moment an unauthenticated answer would be believed.
curl -fsSL https://api.github.com/meta | jq -r '.ssh_keys[] | "github.com " + .' \
  >/home/proma/.ssh/known_hosts
chmod 644 /home/proma/.ssh/known_hosts
chown proma:proma /home/proma/.ssh/known_hosts

step "configuration"
# root:proma 0640 — the two processes read it, and nothing else on the box can. The values
# themselves came down inside user_data, which the instance's own metadata service will hand to
# anyone who can run code here; that is the reason there is no third user account.
install -d -m 750 -o root -g proma /etc/proma
printf '%s' '${env_b64}' | base64 -d >/etc/proma/env
chmod 640 /etc/proma/env
chown root:proma /etc/proma/env

step "the application"
sudo -u proma -H git clone --branch '${github_ref}' \
  'git@github.com:${github_repo}.git' /home/proma/app
cd /home/proma/app
# --prod: the box has no test suite to run and no build to do, so vitest, oxlint and the
# TypeScript compiler have no reason to be resident on a 1GB machine.
sudo -u proma -H env COREPACK_ENABLE_DOWNLOAD_PROMPT=0 \
  pnpm install --prod --frozen-lockfile

step "engine sanity check"
# Spends nothing, and answers the one question that matters before the first 回合: is there a
# `claude` on PATH, and is it the pinned one.
sudo -u proma -H claude --version

step "systemd units"
cat >/etc/systemd/system/proma-webhook.service <<'UNIT'
[Unit]
Description=PROMA webhook — 回合, and the only process here that spends 額度
After=network-online.target
Wants=network-online.target
# No start rate limit: a process that cannot start is misconfigured, and main.ts exits 2 on an
# empty 成員 name list rather than running as a deployment that answers every group with
# silence. Looping every 10s is the loud version of that, and journalctl is where it is loud.
StartLimitIntervalSec=0

[Service]
Type=simple
User=proma
Group=proma
WorkingDirectory=/home/proma/app
EnvironmentFile=/etc/proma/env
# HOME is load-bearing rather than hygiene: 對話 are files under ~/.claude and --resume finds
# them by $HOME *and* by the working directory. Move either one and every case's next 回合
# starts a conversation instead of continuing one.
Environment=HOME=/home/proma
Environment=NODE_ENV=production
Environment=PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ExecStart=/usr/bin/node src/shell/main.ts
Restart=always
RestartSec=10
NoNewPrivileges=true
PrivateTmp=true

[Install]
WantedBy=multi-user.target
UNIT

cat >/etc/systemd/system/proma-window.service <<'UNIT'
[Unit]
Description=PROMA 案窗 — read-only, and its own process on purpose (ADR-0005 §4)
After=network-online.target
Wants=network-online.target
StartLimitIntervalSec=0

[Service]
Type=simple
User=proma
Group=proma
WorkingDirectory=/home/proma/app
# The same file, and deliberately not the same credentials inside it: this process reads
# CASE_WINDOW_DATABASE_URL, which must be a Neon read replica endpoint with a select-only role.
# Nothing in the code can check that (.env.example says so out loud) — it is true or false at
# deployment time, and this is deployment time.
EnvironmentFile=/etc/proma/env
Environment=HOME=/home/proma
Environment=NODE_ENV=production
Environment=PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ExecStart=/usr/bin/node src/shell/case-window.ts
Restart=always
RestartSec=10
NoNewPrivileges=true
PrivateTmp=true

[Install]
WantedBy=multi-user.target
UNIT

step "caddy site configuration"
cat >/etc/caddy/Caddyfile <<'CADDY'
# 對外表面從一個變成兩個 (ADR-0005) — and both of them terminate here.

${webhook_host} {
	# **No request body limit, deliberately.** An oversized 投遞 is answered 200 and hung up on
	# by the application itself (src/shell/webhook-server.ts), precisely so the platform does not
	# send the same one forever; a 413 from Caddy would be read as 「it never arrived」 and undo
	# that. The application's own ceiling is 1MiB and it is the one that counts.
	reverse_proxy 127.0.0.1:${webhook_port}
}

${window_host} {
	reverse_proxy 127.0.0.1:${window_port}
}
CADDY

step "start"
systemctl daemon-reload
systemctl enable --now proma-webhook.service proma-window.service
systemctl restart caddy

step "deploy helper"
cat >/usr/local/bin/proma-deploy <<'DEPLOY'
#!/usr/bin/env bash
# Pull the tracked branch and restart both processes. Run as root.
#
# **This kills whatever 回合 is in flight** — the engine is a child of the webhook process, so a
# turn interrupted here ends in silence for that group rather than in an answer. Deploy when
# nobody is being interviewed, or accept that one 企業主 gets nothing back for the sentence they
# just sent.
#
# Configuration is not updated by this script. /etc/proma/env comes from Terraform, and changing
# it is `terraform apply` (which replaces the instance) rather than an edit here that would drift
# from what the state says is on this box.
set -euo pipefail
cd /home/proma/app
branch="$(sudo -u proma -H git rev-parse --abbrev-ref HEAD)"
sudo -u proma -H git fetch --prune origin
sudo -u proma -H git reset --hard "origin/$branch"
sudo -u proma -H env COREPACK_ENABLE_DOWNLOAD_PROMPT=0 pnpm install --prod --frozen-lockfile
systemctl restart proma-webhook.service proma-window.service
systemctl --no-pager --lines=5 status proma-webhook.service proma-window.service
DEPLOY
chmod 755 /usr/local/bin/proma-deploy

# **The certificates are expected to fail on this boot.** Both A records are created by the DNS
# module *after* this instance exists, because they point at an IP that does not exist until it
# does — so Caddy's first HTTP-01 challenge has nothing resolving to it. Caddy retries on its own
# with backoff and heals within minutes of the records landing; `systemctl restart caddy` asks it
# to try again now.
echo
echo "Setup complete!"
