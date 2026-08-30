<!-- dns-soc-nav:start -->
[🏠 Repository Home](../README.md) · [📁 00 Project Design](README.md)
<!-- dns-soc-nav:end -->

<img src="https://user-images.githubusercontent.com/73097560/115834477-dbab4500-a447-11eb-908a-139a6edaec5c.gif" width="100%" alt="section divider" />

# Scenario DNS Plan

This file separates the permanent public DNS foundation from scenario DNS behavior and the now-completed private defender DNS platform.

For EC2/security-group/network details, see [`scenario-infrastructure-roadmap.md`](scenario-infrastructure-roadmap.md).

## Permanent child-zone baseline

The Route 53 child hosted zone `soclab.abdul4rehman215.tech` keeps five permanent record sets:

| Name | Type | Value | TTL | Purpose |
|---|---|---|---:|---|
| `soclab.abdul4rehman215.tech` | A | `100.49.192.164` | 300 | Main public web target |
| `soclab.abdul4rehman215.tech` | NS | Four Route 53 child nameservers | 172800 | Child-zone authority |
| `soclab.abdul4rehman215.tech` | SOA | Route 53-managed SOA | 900 | Child-zone authority metadata |
| `soclab.abdul4rehman215.tech` | TXT | `"DNS SOC Training Lab"` | 300 | Controlled reconnaissance fixture |
| `www.soclab.abdul4rehman215.tech` | CNAME | `soclab.abdul4rehman215.tech.` | 300 | Secondary public web hostname |

## Scenario 01 — DNS Reconnaissance

**Detection Engineering:** Complete.  
**Official exercise:** ✅ External-adversary SOC/IR run complete; final evidence is maintained in the Scenario 01 repository.

No additional public DNS record is required. The existing A/NS/SOA/TXT/CNAME baseline is sufficient for real public DNS enumeration and optional HTTPS follow-up.

The official attacker operates from a separate AWS account (with optional external Windows traffic) and is not disclosed to the SOC Analyst before the investigation. The attacker may query the existing public records, test likely names and check whether AXFR is exposed; the defender must rely on Route 53 authoritative logs rather than attacker-side telemetry.

## Scenario 02 — DGA / High NXDOMAIN

**Infrastructure status:** Complete.  
**Scenario execution status:** Complete — official DGA run, Detection v1.0, SOC investigation, IR validation, approved RPZ containment, verification, and safe reset are recorded in the dedicated Scenario 02 repository.

Do **not** create random DGA records in Route 53.

Controlled names will conceptually use:

```text
<generated-label>.dga-test.soclab.abdul4rehman215.tech
```

Those names normally do not exist, producing real `NXDOMAIN` through the implemented path:

```text
dns-soc-victim01
10.50.30.20
      |
      v
dns-soc-resolver01 / Unbound
10.50.30.10
      |
      v
AWS VPC Resolver 10.50.0.2
      |
      v
Route 53 authority / Internet DNS
      |
      v
NXDOMAIN when the generated name does not exist
```

This supports later metrics such as:

- NXDOMAIN count and ratio;
- unique names;
- query rate;
- label length/randomness;
- repeated client behavior;
- query type and time pattern.

### Reusable RPZ/sinkhole path

Scenario 02 infrastructure also implemented a private sinkhole at `10.50.30.30` and an Unbound RPZ policy.

Normal/safe state:

```text
controlled generated/test name
        -> Unbound
        -> normal upstream result / NXDOMAIN
```

Approved containment state used during the completed official exercise:

```text
controlled name/pattern
        -> Unbound RPZ match
        -> 10.50.30.30
        -> private Nginx sinkhole
        -> Splunk evidence
```

The infrastructure build first proved this path safely and restored `rpz-action-override: disabled`. During the later official Scenario 02 exercise, Incident Response independently validated the same reusable control after explicit human approval, proved redirect to `10.50.30.30`, verified unrelated DNS remained functional, and returned RPZ to the safe/non-enforcing state. The operational evidence remains in the dedicated Scenario 02 repository.

## Scenario 02 operational closeout

The Scenario 02 DNS plan has now been exercised successfully. The official case used `dns-soc-victim01` (`10.50.30.20`) through `dns-soc-resolver01` (`10.50.30.10`), produced the planned DGA/high-NXDOMAIN behavior, and later validated the reusable RPZ path to `dns-soc-sinkhole01` (`10.50.30.30`) after explicit human approval. The same test qname was proven as NXDOMAIN before containment, redirected during enforcement, and returned to NXDOMAIN after safe reset.

The evidence and human decision record live in the dedicated Scenario 02 repository; this file remains the shared DNS design reference.

## Scenario 03 — Fast Flux DNS

**Implemented infrastructure state:**

```text
flux.soclab.abdul4rehman215.tech
A record
TTL 60 seconds
controlled Route 53 UPSERT rotation
```

The record was validated against three team-controlled public HTTP endpoints. The rotation process refreshes current node public IPs before changing the A record, so temporary EC2 public addresses are not treated as permanent architecture constants.

Validated chain:

```text
Route 53 UPSERT
→ authoritative answer changes
→ Unbound cache/TTL refresh
→ victim receives new answer
→ victim connects to returned address
→ VPC Flow / Splunk evidence
```

The official Scenario 03 exercise is complete. The rotation controller was stopped cleanly and IR found no Scenario 03 RPZ rule active. After independent DNS/network/host validation, IR classified the behavior as controlled/expected and chose **no containment**, then verified Unbound/RPZ safe state and normal DNS operation from the victim path.

The three temporary Fast Flux EC2 nodes were deleted after the exercise. Historical Resolver Query Logs did not expose TTL, so the defender record preserves that limitation even though the controlled DNS design used a 60-second TTL and a later live victim check observed TTL 60.

## Scenario 04 — DNS Tunneling

**Infrastructure status:** ✅ Complete. **Detection Engineering:** ✅ Complete / SOC-ready. **Official exercise:** ⏳ Pending.

Scenario 04 now uses a real delegated child namespace rather than a fake static reservation:

```text
soclab.abdul4rehman215.tech           Route 53 child zone
    |
    +-- tunnel  NS  ns1.tunnel.soclab.abdul4rehman215.tech.
    +-- ns1.tunnel  A  98.93.89.38   # build-time auto-assigned public IPv4
             |
             v
       dns-tunnel-auth01
       BIND authoritative-only
```

The authoritative host serves `tunnel.soclab.abdul4rehman215.tech` with a 60-second wildcard A response so fresh controlled labels can reach one real DNS service without creating thousands of Route 53 records. BIND query logging preserves the received qnames as operator ground truth.

The public address `98.93.89.38` is **not an Elastic IP**. The regional EIP quota was full during the build. Before the official scenario run, confirm the current EC2 public IPv4; if it changed, update the Route 53 nameserver A record, BIND A records and SOA serial, then repeat the smoke tests.

The defender path remains:

```text
dns-soc-victim01 10.50.30.20
    -> dns-soc-resolver01 10.50.30.10 / Unbound
    -> AWS/public recursive DNS
    -> Route 53 nested delegation
    -> dns-tunnel-auth01 / BIND
```

The existing RPZ/sinkhole path stays available for a later human-approved response. Detection v1.0 is now frozen in the Scenario 04 repository, but no Scenario 04 sinkhole action is claimed yet because the official SOC/IR exercise has not started.

The implementation and evidence are documented in [`../02-aws-build/10-scenario-04-dns-tunneling.md`](../02-aws-build/10-scenario-04-dns-tunneling.md).

<img src="https://user-images.githubusercontent.com/73097560/115834477-dbab4500-a447-11eb-908a-139a6edaec5c.gif" width="100%" alt="section divider" />

<!-- dns-soc-footer:start -->
<div align="center">

[🏠 Repository Home](../README.md) · [📁 00 Project Design](README.md)

<sub>DNSentinel Lab · Controlled DNS security training documentation</sub>

</div>
<!-- dns-soc-footer:end -->
