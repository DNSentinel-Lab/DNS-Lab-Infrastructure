<!-- dns-soc-nav:start -->
[🏠 Repository Home](../README.md) · [📁 00 Project Design](README.md)
<!-- dns-soc-nav:end -->

<img src="https://user-images.githubusercontent.com/73097560/115834477-dbab4500-a447-11eb-908a-139a6edaec5c.gif" width="100%" alt="section divider" />

# Scenario Infrastructure Roadmap

**Status:** Scenario 02 defender DNS infrastructure complete; Scenario 03 Fast Flux infrastructure exercised and closed out with the temporary endpoint pool retired; Scenario 04 authoritative-DNS infrastructure complete and Detection Engineering next.

The shared AWS/Splunk/Web/DNS/AI platform is not rebuilt for each scenario. New infrastructure is added only when the scenario needs a real new network/service behavior.

## Shared foundation already complete

- `SOC-LAB-VPC` — `10.50.0.0/16`
- `ATTACK-LAB-VPC` — `10.60.0.0/16` (**historical in-account engineering environment; not the official Scenario 01 information-separated attacker source**)
- Route 53 parent + delegated `soclab` child zone
- `dns-soc-web01` + Nginx/HTTPS + Web UF
- `dns-soc-splunk01` + Splunk Enterprise + project indexes
- Route 53 public query logs
- VPC Flow Logs
- CloudTrail
- AWS VPC Resolver Query Logs
- shared `dns-soc-ai-bridge`
- `dns-attack01` (**historical in-account engineering host**)
- official Scenario 01 Kali adversary in a **separate AWS account**
- optional external Windows adversary source

## Scenario 01 — DNS Reconnaissance

Defender infrastructure requires no additional resource. Scenario 01 uses the existing public DNS, public Web target, AWS telemetry, Splunk and shared AI bridge.

The official adversary boundary is external to the defender account:

```text
Separate AWS account / Kali
        + optional external Windows
                 |
                 | public Internet only
                 v
         Route 53 / public Web
                 |
                 v
            defender telemetry
```

The original in-account `ATTACK-LAB-VPC` is retained only as historical engineering evidence and is not used as the official information-separated attacker source.

## Scenario 02 — DGA + High NXDOMAIN

**Infrastructure: COMPLETE**

### Implemented private hosts

| Host | Address | Subnet | Purpose |
|---|---|---|---|
| `dns-soc-resolver01` | `10.50.30.10` | `SOC-MONITORING-SUBNET` | Unbound defender resolver, RPZ and resolver telemetry |
| `dns-soc-victim01` | `10.50.30.20` | `SOC-MONITORING-SUBNET` | Controlled client for later DGA/high-NXDOMAIN generation |
| `dns-soc-sinkhole01` | `10.50.30.30` | `SOC-MONITORING-SUBNET` | Reusable private Nginx containment/evidence endpoint |

The roles remain separate. Splunk is not used as the DNS resolver, and the victim is not co-hosted with the resolver.

### Private egress

Created `SOC-MONITORING-NAT` in the public `SOC-TARGET-SUBNET` (`us-east-1c`). `SOC-PRIVATE-RT` now provides:

```text
10.50.0.0/16 -> local
0.0.0.0/0    -> SOC-MONITORING-NAT
```

This lets the private Scenario 02 hosts install packages and reach required external management endpoints without public IPv4 addresses.

Normal DNS forwarding is separate and uses AWS VPC Resolver `10.50.0.2`.

### Security groups

```text
SG-DNS
  UDP/TCP 53 <- SG-VICTIM

SG-VICTIM
  no inbound application service

SG-SINKHOLE
  TCP 80 <- SG-VICTIM

SG-SPLUNK
  TCP 9997 <- SG-DNS
  TCP 9997 <- SG-VICTIM   (reserved; victim UF not installed yet)
  TCP 9997 <- SG-SINKHOLE
```

DNS `53` is not exposed publicly.

### Resolver path

```text
Victim 10.50.30.20
       |
       v
Unbound 10.50.30.10
       |
       v
AWS VPC Resolver 10.50.0.2
       |
       v
Route 53 / Internet DNS
```

Unbound logs queries/replies, forwards to `10.50.0.2`, and now includes RPZ support through the `respip iterator` module chain.

### Resolver telemetry

```text
Unbound -> syslog -> rsyslog filtered file
        -> /var/log/dns-soc/unbound.log
        -> Splunk UF -> TCP 9997
        -> index=dns_soc_dns / sourcetype=unbound:dns
```

Validated fields include `event_type`, `client_ip`, `qname`, `qtype`, `rcode`, `response_time`, `cache_flag` and `response_size` where the event provides them.

### Sinkhole path

```text
Unbound RPZ
   -> controlled local-data answer 10.50.30.30
   -> dns-soc-sinkhole01 / Nginx
   -> /var/log/nginx/access.log
   -> Splunk UF
   -> index=dns_soc_web / sourcetype=nginx:access
```

The RPZ path was tested first in disabled/log-only behavior, then with one controlled redirect, then reset to disabled enforcement. The reusable control remains available for future human-approved response testing.

### Completed infrastructure documents

- [`../02-aws-build/08-scenario-02-defender-dns.md`](../02-aws-build/08-scenario-02-defender-dns.md)
- [`../03-splunk-build/07-scenario-02-dns-onboarding.md`](../03-splunk-build/07-scenario-02-dns-onboarding.md)
- [`../01-network-architecture/diagrams/scenario-02-defender-dns.mmd`](../01-network-architecture/diagrams/scenario-02-defender-dns.mmd)

### Work outside the infrastructure layer

The dedicated Scenario 02 repository now records the **full Scenario 02 lifecycle as complete**: Machine Learning Engineering, Detection Engineering, Dashboard Studio, the frozen rule, scheduled alerting, Rule ↔ ML comparison, AI assistance, official DGA execution, SOC investigation, IR validation, human-approved RPZ containment, before/after verification, and safe reset. The operational case remains outside this infrastructure repository because this repository documents the reusable platform rather than the incident narrative.

- fresh information-separated controlled DGA/high-NXDOMAIN adversary execution;
- private ground-truth record and later reveal;
- independent SOC investigation and disposition;
- IR validation and human-approved response decision;
- RPZ/sinkhole containment only if warranted;
- before/after verification, safe reset and final evidence comparison.

## Scenario 02 operational closeout

The platform documented here was later exercised end to end: `10.50.30.20` generated fresh controlled DGA-style DNS through `10.50.30.10`, Detection v1.0 and ML surfaced the abnormal windows, SOC and IR independently investigated the resolver evidence, and a human-approved RPZ rule redirected the observed Scenario 02 namespace to `10.50.30.30`. After sinkhole and normal-DNS verification, RPZ was returned to its safe/non-enforcing state.

Detailed operational evidence remains in the dedicated Scenario 02 repository.

## Scenario 03 — Fast Flux

**Infrastructure status: ✅ Complete / exercised / temporary endpoint pool retired.**

Scenario 03 reused the Scenario 02 victim/resolver/sinkhole platform and added only the infrastructure needed for controlled Fast Flux behavior:

- `SG-FLUX-ENDPOINTS` in `ATTACK-LAB-VPC` with public HTTP/80 only;
- `dns-flux-node01` — `10.60.10.21`;
- `dns-flux-node02` — `10.60.10.22`;
- `dns-flux-node03` — `10.60.10.23`;
- `flux.soclab.abdul4rehman215.tech` A record with 60-second TTL;
- a controlled Route 53 UPSERT rotation process that refreshes current node public IPs;
- authoritative DNS, resolver TTL, victim follow-up and VPC Flow validation.

The infrastructure implementation is documented in [`../02-aws-build/09-scenario-03-fast-flux.md`](../02-aws-build/09-scenario-03-fast-flux.md).

The official Scenario 03 operator/SOC/IR exercise is complete in the separate scenario repository. The frozen detection surfaced the official run; SOC escalated the real Fast Flux-like behavior without inventing malicious attribution; IR independently recovered the answer history and host context, classified the activity as controlled/expected, and did not activate RPZ because containment was not proportionate. Resolver/RPZ safe state was verified.

The live controller and victim follow-up were stopped cleanly, and the three temporary Fast Flux EC2 nodes were stopped/deleted/reset after the exercise. The shared repository retains their historical addressing/configuration as implementation evidence rather than as a claim that those temporary nodes remain deployed.

## Scenario 04 — DNS Tunneling

**Infrastructure status: ✅ Complete / Detection Engineering next.**

Scenario 04 reuses the Scenario 02 defender DNS platform and adds one controlled public authoritative endpoint because the final design needs a real service that can receive fresh synthetic labels.

Implemented extension:

```text
Existing defender path
  dns-soc-victim01   10.50.30.20
        |
        v
  dns-soc-resolver01 10.50.30.10 / Unbound
        |
        v
  AWS/public recursive DNS
        |
        v
  Route 53 nested tunnel delegation
        |
        v
  dns-tunnel-auth01  10.60.10.30 / BIND authoritative-only
```

New resources/configuration:

- `SG-TUNNEL-AUTH` in `ATTACK-LAB-VPC`;
- public inbound TCP/UDP 53 only; no public SSH;
- `dns-tunnel-auth01`, Ubuntu 24.04, `t3.small`, 20 GiB gp3, private IP `10.60.10.30`, SSM-managed;
- BIND 9.20.18 configured as authoritative-only with recursion disabled and IPv4-only operation;
- authoritative zone `tunnel.soclab.abdul4rehman215.tech` with wildcard A response and query logging;
- Route 53 `tunnel` NS delegation and `ns1.tunnel` A record;
- public recursive, victim/Unbound and authoritative receipt validation;
- three-fresh-subdomain smoke test.

The authoritative query log is operator ground truth. Defender detection continues to use the existing Unbound/Splunk DNS path.

Operational limitation: an additional Elastic IP could not be allocated because the regional EIP quota was full. The build used the auto-assigned public IPv4 `98.93.89.38`; it must be rechecked before the official run and any changed address must be synchronized across Route 53 and the BIND zone.

The existing Scenario 02 RPZ/sinkhole remains the reusable response path. It has **not** been activated for Scenario 04 yet.

Implementation: [`../02-aws-build/10-scenario-04-dns-tunneling.md`](../02-aws-build/10-scenario-04-dns-tunneling.md).

## Infrastructure discipline

For every new scenario resource:

1. record the reason it is needed;
2. keep addressing and SG rules inside the locked network plan;
3. validate service and telemetry before detection engineering;
4. preserve repository-safe configuration/evidence;
5. reset temporary DNS/containment changes after the exercise;
6. never publish credentials, API keys, private keys or sensitive account details.

<img src="https://user-images.githubusercontent.com/73097560/115834477-dbab4500-a447-11eb-908a-139a6edaec5c.gif" width="100%" alt="section divider" />

<!-- dns-soc-footer:start -->
<div align="center">

[🏠 Repository Home](../README.md) · [📁 00 Project Design](README.md)

<sub>DNSentinel Lab · Controlled DNS security training documentation</sub>

</div>
<!-- dns-soc-footer:end -->
