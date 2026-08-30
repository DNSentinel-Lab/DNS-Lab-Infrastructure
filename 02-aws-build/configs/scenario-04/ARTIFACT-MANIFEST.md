# Scenario 04 — Infrastructure Artifact Manifest

## Ownership

| Artifact area | Owner / source |
|---|---|
| Scenario 04 infrastructure implementation | Lubaba |
| Shared defender resolver/victim/sinkhole platform | Existing Scenario 02 infrastructure |
| Authoritative BIND endpoint | `dns-tunnel-auth01` |
| Public delegation | Route 53 child zone `soclab.abdul4rehman215.tech` |
| Authoritative ground truth | `/var/log/named/scenario04-queries.log` |
| Defender client attribution | Unbound journal on `dns-soc-resolver01` |

## Preserved configuration

| File | Purpose |
|---|---|
| `bind/named.conf.options` | Authoritative-only listener/recursion policy |
| `bind/named-default-options` | IPv4-only BIND service option |
| `bind/named.conf.local` | Zone + query logging |
| `bind/db.tunnel.soclab` | Controlled tunnel child zone |
| `COMMAND-LEDGER.md` | Reproducible implementation/validation commands |

## Curated screenshots

The associated screenshot set is stored at:

`../../screenshots/scenario-04-dns-tunneling/`

Only final-state or decision-relevant evidence is retained. Repeated navigation screens and copy/paste mistakes are intentionally excluded.

## Not implemented in this phase

- no decoder/reassembly application for encoded labels;
- no Scenario 04 Detection v1.0;
- no Scenario 04 dashboard or scheduled alert;
- no official operator run;
- no SOC/IR result;
- no Scenario 04 RPZ enforcement event;
- no BIND Universal Forwarder/onboarding as a defender detection source.

Those belong to later scenario phases and must be documented only after they occur.
