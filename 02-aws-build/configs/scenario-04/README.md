# Scenario 04 — Authoritative DNS Configuration

This folder preserves the **repository-safe final configuration** used to prepare the controlled authoritative DNS endpoint for Scenario 04.

## Implemented host

| Field | Value |
|---|---|
| Host | `dns-tunnel-auth01` |
| Private IPv4 | `10.60.10.30` |
| VPC / subnet | `ATTACK-LAB-VPC` / `ATTACK-PUBLIC-SUBNET` |
| OS | Ubuntu 24.04 LTS |
| DNS service | BIND 9.20.18 |
| Zone | `tunnel.soclab.abdul4rehman215.tech` |
| Service role | Public authoritative DNS only |
| Recursion | Disabled |
| IPv6 BIND operation | Disabled; service launched with `-4` |
| Query log | `/var/log/named/scenario04-queries.log` |

## Files

- [`bind/named.conf.options`](bind/named.conf.options) — authoritative-only options.
- [`bind/named-default-options`](bind/named-default-options) — Ubuntu service options used to force IPv4-only BIND operation.
- [`bind/named.conf.local`](bind/named.conf.local) — zone and Scenario 04 query-log configuration.
- [`bind/db.tunnel.soclab`](bind/db.tunnel.soclab) — authoritative zone used during infrastructure validation.
- [`COMMAND-LEDGER.md`](COMMAND-LEDGER.md) — meaningful build/validation commands from the implementation session.
- [`ARTIFACT-MANIFEST.md`](ARTIFACT-MANIFEST.md) — configuration/evidence ownership and preservation notes.

## Public-IP constraint

The infrastructure build could not allocate another Elastic IP because the regional Elastic-IP quota was already full. The authoritative EC2 therefore used the auto-assigned public IPv4 `98.93.89.38` during this build.

That address is **not a permanent architecture constant**. Before the official Scenario 04 run:

1. confirm the current public IPv4 on `dns-tunnel-auth01`;
2. if it changed, update the Route 53 `ns1.tunnel` A record;
3. update the three A records in `db.tunnel.soclab`;
4. increment the SOA serial;
5. run `named-checkconf` and `named-checkzone`;
6. restart BIND and repeat the public/victim smoke tests.

Do not treat the stored public IPv4 as an Elastic IP.

## Evidence boundary

BIND query logs on this host are **operator/ground-truth evidence**. The defender-side detection path remains the existing Unbound resolver and Splunk DNS telemetry. The authoritative server was not onboarded as a new Splunk detection source during this infrastructure phase.
