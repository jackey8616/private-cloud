variable "ssh_public_keys" {
  description = "SSH public keys for human login to the instance"
  type        = list(string)
  sensitive   = true
}

variable "allowed_connection_ips" {
  description = "Allowed IPs for SSH. Not for 80/443 — LINE publishes no source range, so the public endpoint is open to the world by necessity (firewall.tf)."
  type        = list(string)
}

variable "instance-env" {
  description = "PROMA's own configuration, rendered into /etc/proma/env. Keys are the ones src/shell/env.ts asks for; see README.md for the list and for the three keys this module derives rather than reads."
  type        = map(string)
  sensitive   = true

  # **The plan is the last place a missing key is cheap.** `required()` exits 2 on the box, which
  # is loud enough if somebody is reading journalctl — but CLAUDE_CODE_OAUTH_TOKEN is not read by
  # PROMA at all, it is read by the `claude` the engine spawns, and its absence is not an exit. It
  # is a 回合 that fails, then another one, quietly, for as long as nobody looks.
  #
  # Messages name the keys literally rather than computing which one is missing: the variable is
  # sensitive, and anything derived from it — including its key names — cannot be put in an error.
  validation {
    condition = length(setsubtract([
      "PROMA_MEMBERS",
      "DATABASE_URL",
      "CASE_WINDOW_DATABASE_URL",
      "CASE_WINDOW_SESSION_SECRET",
      "LINE_CHANNEL_ACCESS_TOKEN",
      "LINE_CHANNEL_SECRET",
      "LINE_LOGIN_CHANNEL_ID",
      "LINE_LOGIN_CHANNEL_SECRET",
      "CLAUDE_CODE_OAUTH_TOKEN",
    ], keys(var.instance-env))) == 0
    error_message = "instance-env is missing a key. It must hold all nine of PROMA_MEMBERS, DATABASE_URL, CASE_WINDOW_DATABASE_URL, CASE_WINDOW_SESSION_SECRET, LINE_CHANNEL_ACCESS_TOKEN, LINE_CHANNEL_SECRET, LINE_LOGIN_CHANNEL_ID, LINE_LOGIN_CHANNEL_SECRET, CLAUDE_CODE_OAUTH_TOKEN — edit it with scripts/secrets-edit.sh proma."
  }

  # Empty is refused for the same reason `required()` refuses it: an endpoint verifying deliveries
  # against an empty secret verifies nothing, and looks exactly like one that does.
  validation {
    condition     = alltrue([for k, v in var.instance-env : trimspace(v) != ""])
    error_message = "instance-env has a key with an empty value. An empty LINE_CHANNEL_SECRET or DATABASE_URL is a deployment that looks configured and is not."
  }

  # The three the module owns. Left in the secret they would be silently overridden by the merge
  # in instance.tf — and a stale LINE_LOGIN_CALLBACK_URL sitting in the secret, being ignored, is
  # a thing somebody will one day read and believe.
  validation {
    condition = length(setintersection([
      "LINE_LOGIN_CALLBACK_URL",
      "PORT",
      "CASE_WINDOW_PORT",
    ], keys(var.instance-env))) == 0
    error_message = "instance-env must not set LINE_LOGIN_CALLBACK_URL, PORT or CASE_WINDOW_PORT — this module derives all three (instance.tf), and a copy in the secret would be ignored rather than obeyed."
  }
}

variable "webhook-hostname" {
  description = "FQDN the LINE platform posts deliveries to. Terminated by Caddy on the instance and reverse-proxied to the webhook process."
  type        = string
}

variable "window-hostname" {
  description = "FQDN 成員 open 案窗 on. Also decides LINE_LOGIN_CALLBACK_URL, which is derived rather than configured — the LINE console compares it byte for byte, so it must not be able to drift from this."
  type        = string
}

variable "github-repo" {
  description = "owner/name of the application repository, cloned over SSH with the deploy key this module generates."
  type        = string
  default     = "jackey8616/proma"

  validation {
    condition     = length(split("/", var.github-repo)) == 2
    error_message = "github-repo must be owner/name — deploy-key.tf takes the name half of it."
  }
}

variable "github-org-name" {
  description = "Owner the github provider acts as, for the deploy key. Same value the github/ module gets."
  type        = string
}

variable "github-token" {
  description = "GitHub PAT (scope: repo) used to register the instance's read-only deploy key."
  type        = string
  sensitive   = true
}

variable "github-ref" {
  description = "Branch the instance is deployed from. The box tracks a branch rather than a tag because there is no build artifact — Node runs the TypeScript directly."
  type        = string
  default     = "main"
}

variable "region" {
  description = "Linode region. Must be one with the Metadata capability — cloud-init is how this instance is built, and a region without it would boot an empty Ubuntu. Tokyo 3 is the newest JP region and the closest to both the LINE platform and the 成員."
  type        = string
  default     = "jp-tyo-3"
}

variable "instance-type" {
  description = "Smallest Linode, deliberately — one 回合 peaks around 400MB (claude ~200 + graph MCP ~60 + the two node processes ~160) and 1GB plus swap holds two of them. doc/LinodeInstanceType.md has the label↔ID map."
  type        = string
  default     = "g6-nanode-1"
}

variable "swap-gb" {
  description = "Swapfile size. Insurance against a burst of concurrent 回合, not a place to run from: a nanode has no swap by default, so without this the OOM killer is the first thing a third simultaneous turn meets."
  type        = number
  default     = 2
}

variable "node-major" {
  description = "Node major from NodeSource. The app runs .ts files directly, which needs the type stripping that is unflagged from 22.18 onwards — a 22.x line is what makes that true without pinning a patch that NodeSource will drop."
  type        = string
  default     = "22"
}

variable "claude-code-version" {
  description = "The engine, pinned. src/engine/engine.ts pins the same string and complains once per 回合 when the CLI reports anything else — seam two's measurements are about this version, so a drift here is a drift away from what was measured."
  type        = string
  default     = "2.1.226"
}
