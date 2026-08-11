# PROMA

One Linode nanode running [`jackey8616/proma`](https://github.com/jackey8616/proma) — the
pre-sales PM agent that interviews a 企業主 over a LINE group and turns what they said into a
需求圖譜. Two systemd units, Caddy in front of them, $5/month.

## Why a machine, and not Cloud Run like Silverfish

Four things in the application decide this, and each of them on its own is enough:

- **The work happens after the response.** `webhook-server.ts` answers the platform 200 and then
  runs the 回合 detached, because a 投遞 held open until an interview turn finishes is a 投遞
  the platform redelivers. Cloud Run with `cpu_idle` — which is what `silverfish/main.tf` sets —
  would throttle the CPU the moment that 200 goes out, mid-turn.
- **The engine is a child process.** `engine-process.ts` spawns `claude`, and that CLI spawns a
  second Node process per turn to serve the 需求圖譜 over MCP. It needs a `claude` on PATH and a
  subscription token, not an HTTP client.
- **`--resume` is a file on disk.** 對話 live under `~/.claude`; a filesystem that resets between
  requests would make every case's every turn a first turn.
- **There can be exactly one.** `cases.ts` holds 哪些群組已成案 in memory and says outright that a
  second instance would have a second copy and no way to hear about the first one's cases.

The 案窗 half could be serverless on its own. It is not, because ADR-0005 §4 asks for a second
*process*, not a second bill.

## What this module builds

| | |
|---|---|
| `instance.tf` | `g6-nanode-1` (1GB) in Tokyo 3, built entirely by `templates/init.sh.tpl` at first boot |
| `firewall.tf` | 22 from `often-login-ips`; **80 and 443 from anywhere**, because LINE publishes no source range |
| `deploy-key.tf` | Read-only deploy key on the application repository — declared here, not in `github/`, because it has to exist before the box boots and clones |
| `templates/init.sh.tpl` | Node, `claude` pinned to the version `src/engine/engine.ts` expects, the repo, two units, Caddy |

On the box: the app at `/home/proma/app`, configuration at `/etc/proma/env` (`root:proma 0640`),
`proma-webhook.service` on :8080 and `proma-window.service` on :8081, and `proma-deploy` to pull
and restart.

## The secret

`private-cloud/proma`, edited with `scripts/secrets-edit.sh proma`. One key, `instance-env`, an
object whose members become `/etc/proma/env` verbatim:

```json
{
  "instance-env": {
    "PROMA_MEMBERS": "U0000…,U0000…",
    "DATABASE_URL": "postgresql://…@ep-….neon.tech/proma?sslmode=require",
    "CASE_WINDOW_DATABASE_URL": "postgresql://readonly:…@ep-…-replica.neon.tech/proma?sslmode=require",
    "CASE_WINDOW_SESSION_SECRET": "…",
    "LINE_CHANNEL_ACCESS_TOKEN": "…",
    "LINE_CHANNEL_SECRET": "…",
    "LINE_LOGIN_CHANNEL_ID": "…",
    "LINE_LOGIN_CHANNEL_SECRET": "…",
    "CLAUDE_CODE_OAUTH_TOKEN": "…"
  }
}
```

`.env.example` in the application repository is the authority on what each one means; every value
above except the last is documented there at length. `CLAUDE_CODE_OAUTH_TOKEN` is not, because a
developer's machine logs in interactively and a box cannot — make one with `claude setup-token`.

**Three keys are derived and must not be put here**: `LINE_LOGIN_CALLBACK_URL` (computed from
`window-hostname`, so the DNS record, the certificate and the console value cannot drift apart),
`PORT` and `CASE_WINDOW_PORT` (the module owns both, because Caddy has to agree with them).

**The two Neon URLs are not the same credentials, and nothing in the code can tell.**
`CASE_WINDOW_DATABASE_URL` has to be a read replica endpoint with a `select`-only role — pasting
`DATABASE_URL` into both removes an entire layer of protection and looks identical from every
angle the application can see. `.env.example` spends a paragraph on this; it is true or false at
this file, and nowhere else.

## Before the first apply

1. **Neon**: the database, plus a read replica endpoint and a `select`-only role for 案窗
   (`grant select` **and** `alter default privileges`, or the window goes quietly blind the day a
   new table appears).
2. **LINE**: the official account's channel (access token + channel secret) and a **LINE Login
   channel under the same provider** — different providers hand out userIds that do not match,
   and ADR-0005 §3 rests entirely on them matching.
3. **The secret**, as above.
4. `claude setup-token` on a machine where you are logged in.

## Apply

```bash
terraform apply -target=module.Proma   # deploy key, then the box; ~3 minutes, most of it apt
terraform apply -target=module.DNS     # the two A records
```

The full `terraform apply` does the same thing in one shot. The instance is built before the
records that point at it, so **Caddy's first certificate attempt fails** — nothing resolves to
that IP yet. It retries on its own; `systemctl restart caddy` asks it to try again now.

Then, by hand, in consoles Terraform cannot reach:

- LINE Developers → the OA channel → Webhook URL: `https://proma.dev.clo5de.info/line/webhook`,
  webhook **enabled**, auto-reply **off**.
- LINE Developers → the Login channel → Callback URL:
  `https://proma-window.dev.clo5de.info/login/line/callback`, byte for byte. Delete any local
  development callback you are no longer using — every line on that list is a key.

## Operating it

```bash
ssh root@$(terraform output -json proma | jq -r .instance.public_ipv4)

journalctl -u proma-webhook -f     # 紀錄 — one line per 回合, and 痕跡 counts
journalctl -u proma-window -f
proma-deploy                       # pull the tracked branch, reinstall, restart both
```

**`proma-deploy` kills whatever 回合 is in flight**, because the engine is a child of the webhook
process — that group gets silence instead of an answer. Deploy when nobody is being interviewed.

**A configuration change replaces the instance.** `user_data` is read once, at first boot, so
rotating `LINE_CHANNEL_SECRET` or adding a 成員 is `secrets-edit.sh` followed by an apply that
rebuilds the box. Everything that must outlive it is in Neon; what does not survive is
`/home/proma/.claude`, so every case's next 回合 starts a fresh 對話 rather than continuing one
(ADR-0001 §4 prices that as 語氣, not 需求). Editing `/etc/proma/env` in place would avoid the
rebuild and cost the guarantee that the state describes the box.

## Known caveats

- **`user_data` holds every secret in this module, and the instance's own metadata service will
  hand it to anything that can run code on the box.** `/etc/proma/env` being `0640 root:proma` is
  therefore not the boundary — the boundary is that nothing untrusted runs here. It is the same
  class of caveat as secrets being copied into the Terraform state, which the root `CLAUDE.md`
  already states.
- **1GB is deliberate and not generous.** One 回合 peaks around 400MB (engine ~200, its MCP server
  ~60, the two Node processes ~160), and the 2GB swapfile is what makes a burst of concurrent
  interviews survivable rather than an OOM kill. If 成案 counts grow past a handful of
  simultaneous conversations, the next size up is the answer, not a tuning flag.
- **No second instance, ever** — see `cases.ts`. Scaling this box out is a change to the
  application first.
- **80 is open to the world** and stays open: it is where Let's Encrypt validates. What guards
  the endpoint is 來源證明, not the firewall.
