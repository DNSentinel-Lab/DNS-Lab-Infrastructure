<!-- dns-soc-nav:start -->
[🏠 Repository Home](../README.md) · [📁 01 Network Architecture](README.md)
<!-- dns-soc-nav:end -->

<img src="https://user-images.githubusercontent.com/73097560/115834477-dbab4500-a447-11eb-908a-139a6edaec5c.gif" width="100%" alt="section divider" />

# Security Group Design

Security Groups are the primary service-level network control. Ports are added only for real service paths.

## `SG-WEB`

| Direction | Protocol / Port | Source / Destination | Reason |
|---|---|---|---|
| Inbound | TCP 80 | `0.0.0.0/0` | Public HTTP / redirect path |
| Inbound | TCP 443 | `0.0.0.0/0` | Public HTTPS target |
| Inbound | SSH 22 | None | Administration uses SSM |

## `SG-SPLUNK`

| Direction | Protocol / Port | Source | Reason |
|---|---|---|---|
| Inbound | TCP 8000 | Approved team public IPs only | Splunk Web |
| Inbound | TCP 9997 | `SG-WEB`, `SG-DNS`, `SG-VICTIM`, `SG-SINKHOLE` | Private Universal Forwarder receiver |
| Inbound | TCP 8088 | No public rule | HEC is internal-only for the AI bridge |
| Inbound | TCP 8089 | No public rule | Splunk management interface |
| Inbound | SSH 22 | None | SSM administration |

`SG-VICTIM -> 9997` is reserved for a future victim forwarder path. No victim UF was installed during the Scenario 02 infrastructure build.

## `SG-ATTACKER` — historical in-account engineering host

This security group belongs to the original defender-account `ATTACK-LAB-VPC` build and is retained as historical infrastructure evidence. The official Scenario 01 Kali adversary now runs in a separate AWS account, so its security-group configuration is outside the defender repository.

The historical attack host used no unnecessary public inbound management rule, relied on SSM, and used scenario-required outbound paths.

## `SG-DNS`

| Direction | Protocol / Port | Source | Reason |
|---|---|---|---|
| Inbound | UDP 53 | `SG-VICTIM` | Victim DNS queries |
| Inbound | TCP 53 | `SG-VICTIM` | TCP DNS fallback/queries |

There is no `0.0.0.0/0` DNS rule. The resolver is not an Internet-facing recursive resolver.

## `SG-VICTIM`

No inbound application service is required for Scenario 02.

The victim uses outbound DNS to `10.50.30.10`, private HTTP to the sinkhole during validation/response, VPC-local Splunk receiver access only if a forwarder is later enabled, and NAT egress where management/package access requires it.

## `SG-SINKHOLE`

| Direction | Protocol / Port | Source | Reason |
|---|---|---|---|
| Inbound | TCP 80 | `SG-VICTIM` | Private RPZ containment HTTP evidence |

The sinkhole has no public IP and no public inbound service.

## Security rule

The Scenario 02 defender DNS design relies on private addressing, SG-to-SG rules and SSM. A victim host-firewall rule to prevent deliberate direct AWS DNS bypass was discussed during planning but was **not implemented**, so it is not part of the deployed control set.

## Scenario 03 — SG-FLUX-ENDPOINTS

Scenario 03 added one shared security group in `ATTACK-LAB-VPC` for the controlled Fast Flux destination pool.

| Direction | Protocol | Port | Source / destination | Purpose |
|---|---|---:|---|---|
| Inbound | TCP | 80 | `0.0.0.0/0` | allow the victim to reach whichever public Fast Flux node DNS returns |
| Inbound | TCP | 22 | **not public** | SSM preferred for administration |
| Outbound | All during build/validation | all | `0.0.0.0/0` | package/bootstrap and controlled lab operations |

The nodes are **not DNS servers**. Port 53 and Splunk receiver ports were not opened on this group.


## Scenario 04 — `SG-TUNNEL-AUTH`

Scenario 04 adds one public authoritative DNS security group in `ATTACK-LAB-VPC`. This is intentionally different from the private `SG-DNS` recursive resolver.

| Direction | Protocol / Port | Source | Reason |
|---|---|---|---|
| Inbound | UDP 53 | `0.0.0.0/0` | Public authoritative DNS queries |
| Inbound | TCP 53 | `0.0.0.0/0` | TCP DNS / fallback to the authoritative service |
| Inbound | SSH 22 | None | Administration uses SSM |

BIND recursion is disabled on `dns-tunnel-auth01`, so the public DNS listener is authoritative-only rather than an open recursive resolver.

<img src="https://user-images.githubusercontent.com/73097560/115834477-dbab4500-a447-11eb-908a-139a6edaec5c.gif" width="100%" alt="section divider" />

<!-- dns-soc-footer:start -->
<div align="center">

[🏠 Repository Home](../README.md) · [📁 01 Network Architecture](README.md)

<sub>DNSentinel Lab · Controlled DNS security training documentation</sub>

</div>
<!-- dns-soc-footer:end -->
