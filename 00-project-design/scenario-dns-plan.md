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

The three temporary Fast Flux EC2 nodes were stopped/deleted/reset after the exercise. Historical Resolver Query Logs did not expose TTL, so the defender record preserves that limitation even though the controlled DNS design used a 60-second TTL and a later live victim check observed TTL 60.

## Scenario 04 — DNS Tunneling

Do **not** create a normal static Route 53 A record just to reserve the tunneling name.

Planned namespace:

```text
tunnel.soclab.abdul4rehman215.tech
```

The final design must be chosen when the scenario is prepared. Reuse the Scenario 02 resolver/victim/sinkhole platform. Add a separate authoritative DNS endpoint/delegation only if the controlled tunneling simulation genuinely needs to receive and interpret the encoded queries.

The traffic must contain harmless lab-generated data only.

## DNS cleanup rule

Temporary scenario DNS changes must be documented with:

- what was added or changed;
- expected TTL/behavior;
- exact scenario purpose;
- before/after validation;
- reset/removal state after the exercise.

The permanent child-zone baseline stays stable unless a project-level change is deliberately approved.

<img src="https://user-images.githubusercontent.com/73097560/115834477-dbab4500-a447-11eb-908a-139a6edaec5c.gif" width="100%" alt="section divider" />

<!-- dns-soc-footer:start -->
<div align="center">

[🏠 Repository Home](../README.md) · [📁 00 Project Design](README.md)

<sub>DNSentinel Lab · Controlled DNS security training documentation</sub>

</div>
<!-- dns-soc-footer:end -->
