# mirror-toxiproxy

OCX mirror for [Toxiproxy](https://github.com/Shopify/toxiproxy).
Publishes GitHub releases to `ocx.sh/toxiproxy` with cascade tags after a
smoke test per `(variant, version, platform)`.

Three variants are published from each upstream release:

| Variant | Tags | Ships |
|---------|------|-------|
| default (full) | `2.12.0`, `2.12`, `2`, `latest` | `toxiproxy-server` + `toxiproxy-cli` |
| client | `client-2.12.0`, `client-2.12`, … | `toxiproxy-cli` only |
| server | `server-2.12.0`, `server-2.12`, … | `toxiproxy-server` only |

Upstream ships statically linked Go binaries (no musl/glibc split) and no
`windows/arm64` build, so every variant covers the same five platforms:
`linux/{amd64,arm64}`, `darwin/{amd64,arm64}`, `windows/amd64`.

## Editing

| File | Edit | Regenerate after |
|------|------|------------------|
| `mirror.yml` | hand | `ocx-mirror pipeline generate ci` |
| `tests/smoke.star` | hand | — |
| `metadata*.json`, `CATALOG.md`, `logo.*` | hand | — |
| `.github/workflows/*.yml` | generated | re-run when `mirror.yml` changes |

CI fails on drift via `ocx-mirror pipeline generate ci --check`.

## Required secrets

| Secret | Use |
|--------|-----|
| `OCX_MIRROR_REGISTRY_TOKEN` + `OCX_MIRROR_REGISTRY_USER` | `ocx package push` to `ocx.sh` |
| `OCX_MIRROR_DISCORD_HOOK` | notify-stage Discord webhook URL |

(Inherited from the `ocx-contrib` org with visibility ALL.)

## License

Apache-2.0 — see [`LICENSE`](LICENSE). Upstream assets are out of
scope; see [`NOTICE.md`](NOTICE.md).
