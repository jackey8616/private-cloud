# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A single Terraform root that provisions the author's personal multi-cloud infrastructure across AWS, GCP, Cloudflare, and Linode. There is no application code here — every `.tf` file is infra-as-code. The root `main.tf` instantiates per-app child modules and wires their outputs together (e.g. ClodeClaw's public IP and Clode-Tools' VPN IP both feed into the `DNS` module).

State is stored remotely in S3 (`terraform-state20240420133633131400000001`, key `build-instance/terraform.tfstate`, region `ap-northeast-1`) with DynamoDB lock table `terraform_lock`. The bucket and lock table themselves are managed by `storage.tf` in this same root — bootstrap chicken-and-egg is already resolved; do not recreate them.

## Common commands

All commands run from the repo root unless noted. There is no Makefile, lint config, or test suite — Terraform is the only tool.

```bash
terraform init                              # after cloning or when provider versions change
terraform plan                              # full plan across every module
terraform plan -target=module.ClodeClaw     # scope to one module — useful, modules are large
terraform apply -target=module.DNS          # same scoping works for apply
terraform fmt -recursive                    # editorconfig is 2-space, LF, final newline
terraform validate
terraform output -json clode-claw           # sensitive outputs — must pass the name
```

Single-module work: you can also `cd <module>/ && terraform ...` only for `validate`/`fmt`. Real `plan`/`apply` must run from root because state, backend, and cross-module wiring live there.

## Required local files (gitignored, must exist before `init`/`plan`)

- `.aws_credentials` — AWS shared-credentials file. Referenced by *both* the AWS provider (`provider.tf`) and the S3 backend (`version.tf`). Default profile is used.
- Sensitive variables are **not** stored locally — they live in AWS Secrets Manager (one secret per module; see the "Secrets" section below). There is no `terraform.tfvars.json` anymore. `.aws_credentials` remains gitignored — never commit it.
- `~/.ssh/github.pub` — read by `credentials.tf` and injected as the MacBook Air SSH key into Linode.

(`.aws_credentials` and `~/.ssh/github.pub` are the only local files now — there is no local cert or tfvars anymore.)

## Secrets (AWS Secrets Manager)

All sensitive configuration lives in AWS Secrets Manager (region `ap-northeast-1`, same account/creds as the S3 backend), one secret per `private-cloud/<name>`, read by the `data "aws_secretsmanager_secret_version"` blocks in `secrets.tf` and exposed as `local.<name>`. References use bracket indexing (`local.clode_tools["gcp-project-id"]`) because `jsondecode` keeps the hyphenated keys.

There are 13 secrets: the former `terraform-management` catch-all is split by provider (`cloudflare`, `linode`, `mongodbatlas`, `github`) plus a shared `common` (holds `often-login-ips`), and one per app module (`clode-tools`, `pyfun`, `seeker`, `fomo-bot`, `morpheus`, `groceries-nz`, `silverfish`, `clode-claw`).

- Terraform only *reads* these; the plaintext never comes from a Terraform input, so there is no local tfvars file.
- Edit one value: `scripts/secrets-edit.sh <name>` (fetch → `$EDITOR` → push a new version).
- Bulk-seed from a `terraform.tfvars.json` (first-time migration or disaster recovery): `scripts/secrets-push.sh`.
- Caveat: read values are copied into the S3 state. The state's encryption + access control is the real security boundary — not the absence of a local file.

### PyFun TLS certificate

PyFun's API Gateway custom domain (`pyfun-backend-v2.clo5de.info`) uses an **ACM-issued, DNS-validated** certificate defined at root in `pyfun-cert.tf`. It spans two providers — `aws` for issuance (must be in the API Gateway's region, `ap-northeast-1`) and `cloudflare` for the validation record in the `clo5de.info` zone — so it lives at root and its validated ARN is injected into `module.PyFun`. ACM auto-renews it; no private key is stored in Terraform or on disk.

- The previous **imported** cert (arn `eabee32f`, valid to 2039) is no longer managed by Terraform (`state rm`'d, left alive in ACM). Both it and the new cert are `InUseBy` production load balancers in a **separate AWS account** (`969236854626`, `prod-nrt-1-cdtls-*`) — some external TLS-terminating platform auto-attaches ACM certs for this domain. Consequence: the cert auto-renews in place fine, but **cannot be destroyed/replaced while in use** (`terraform destroy` of it fails with `ResourceInUseException` — this is what broke the first migration apply).
- The imported cert's private key + body are cold-backed-up in the `private-cloud/pyfun-legacy-cert` secret (**not** read by Terraform; kept only because ACM cannot export an imported cert's key).

## Architecture: how the modules fit together

Provider aliasing matters. `provider.tf` declares:
- `aws` (default) → `ap-northeast-1` (Tokyo)
- `aws.sydney` → `ap-southeast-2`, passed explicitly to `module.GroceriesNZ` because its data lives in NZ-adjacent region
- `cloudflare`, `linode`, plus `google` configured per child module (`clode-tools/provider.tf`)

Root-level shared resources that downstream modules depend on:
- `aws_iam_openid_connect_provider.GitHub` (in `permissions.tf`) — ARN is passed into `pyfun` and `groceries_nz` so their GitHub Actions can assume push-to-ECR roles via OIDC.
- `aws_iam_policy.AWSLambdaEdgeExecutionRole` — same: passed into Lambda-based modules as `Lambda-EdgeFunctionExecuteRole-Arn`.
- `aws_servicecatalogappregistry_application.terraform` — its `application_tag` is `merge`d into every taggable resource for cost/grouping. Each app module also declares its own appregistry application and tags its resources with that.

Module wiring summary (read `main.tf` first for any change):
- `Clode-Tools` (GCP) → exposes `vpn.ip`, consumed by `DNS`. Runs `hwdsl2/ipsec-vpn-server` on a COS GCE instance; the `use-spot` toggle in the `clode-tools` secret switches preemptible vs standard.
- `ClodeClaw` (Linode + Cloudflare R2) → exposes `instance.public_ipv4`, consumed by `DNS`. The instance is bootstrapped by fetching `templates/init.sh.tpl` from `jackey8616/my-claw` at apply time and rendering it with `var.instance-env` + R2 credentials it generates. The `remote-exec` provisioner waits for cloud-init and greps for `Setup complete!` — if the upstream template changes that sentinel, applies will hang then fail. SSH uses an ephemeral `tls_private_key` for the provisioner; humans log in with the keys in `ssh_public_keys`.
- `DNS` (Cloudflare) → manages the `clo5de.info` zone and writes A records pointing at the two IPs above.
- `PyFun`, `GroceriesNZ` (AWS) → Lambda-on-container apps. Images come from ECR; image SHAs are pinned via the `aws-ecr-image-sha` key in the `pyfun` / `groceries-nz` secrets and must be bumped manually (`scripts/secrets-edit.sh pyfun`) when a new image is pushed. GroceriesNZ is a 6-level Step Function pipeline (`L1_store_dispatcher` → `L6_item_copier` + `view_updater`), scheduled daily at 18:00 UTC by EventBridge.
- `Morpheus`, `Seeker`, `FomoBot` (GCP) → each creates its own GCP project + billing link + service accounts. Morpheus and Seeker define a `vertex_ai_predictor` custom role that grants only `aiplatform.endpoints.predict`.

## Conventions and gotchas

- Linode instance type for `clode-claw` is intentionally `g6-nanode-1` (smallest); see `doc/LinodeInstanceType.md` for the full label↔ID map before changing.
- `clode-claw/firewall.tf` restricts inbound to the `often-login-ips` list (now in the `common` secret). Add a new home/office IP with `scripts/secrets-edit.sh common`.
- Cloudflare R2 tokens in `clode-claw/r2.tf` use `sha256(token.value)` as the secret access key — that's the documented R2 S3-compat scheme, not a bug.
- The groceries-ingestion S3 bucket has a 1-day expiration lifecycle rule; raw scrape data is ephemeral by design.
- Provider versions are pinned (aws 5.46.0, linode 3.10.0, google 7.34.0, cloudflare ~>5). Bumping them requires re-running `terraform init -upgrade` and is likely to surface schema changes — do it deliberately, not as a drive-by.
- Sensitive outputs (`clode-claw`, `clode-tools`) need explicit `terraform output <name>` to view; don't try to print the whole state.
