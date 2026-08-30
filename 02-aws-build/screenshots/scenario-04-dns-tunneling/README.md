# Scenario 04 — DNS Tunneling Infrastructure Evidence

This folder contains the curated evidence for the Scenario 04 infrastructure extension implemented by **Lubaba** on 2026-08-29.

| # | Screenshot | What it proves |
|---:|---|---|
| 01 | `01-sg-tunnel-auth-dns-only.png` | The authoritative-server security group allows public DNS on UDP/TCP 53 without exposing SSH. |
| 02 | `02-bind-authoritative-service.png` | BIND is active and running in IPv4-only mode after the authoritative-only cleanup. |
| 03 | `03-authoritative-zone-validation.png` | `named-checkzone` loads the controlled tunnel zone and BIND restarts cleanly. |
| 04 | `04-wildcard-authoritative-answer.png` | Both the zone and arbitrary child labels receive authoritative answers, validating wildcard behavior. |
| 05 | `05-bind-query-logging.png` | `scenario04-queries.log` records a controlled query name as authoritative ground truth. |
| 06 | `06-route53-tunnel-delegation.png` | Route 53 contains the `tunnel` NS delegation and `ns1.tunnel` A record. |
| 07 | `07-public-delegation-validation.png` | A normal recursive lookup reaches the delegated namespace and returns the authoritative answer. |
| 08 | `08-victim-defender-dns-path.png` | `dns-soc-victim01` still uses defender resolver `10.50.30.10` and resolves a fresh tunnel child name. |
| 09 | `09-unbound-client-visibility.png` | Unbound identifies client `10.50.30.20`, qname, qtype and `NOERROR` result. |
| 10 | `10-authoritative-query-receipt.png` | The same fresh qname reaches the BIND authoritative endpoint. |
| 11 | `11-unique-subdomain-smoke-test.png` | Three fresh unique subdomains arrive at the authoritative endpoint. |
| 12 | `12-eip-quota-limitation.png` | AWS refused another Elastic IP because the regional address quota was full; this explains the temporary public-IP constraint. |

## Evidence interpretation

The Unbound and BIND views intentionally show different source identities:

- Unbound sees the actual lab client `10.50.30.20`.
- The public authoritative server sees upstream public recursive-resolver addresses.

That is expected for the deployed recursive-to-authoritative path and is an important attribution boundary for later SOC analysis.

The screenshots are cropped only to remove irrelevant screen area. Technical values, timestamps and results were not edited.
