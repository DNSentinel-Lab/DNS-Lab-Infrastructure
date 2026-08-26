<!-- dns-soc-nav:start -->
[🏠 Repository Home](../README.md) · [📁 00 Project Design](README.md)
<!-- dns-soc-nav:end -->

<img src="https://user-images.githubusercontent.com/73097560/115834477-dbab4500-a447-11eb-908a-139a6edaec5c.gif" width="100%" alt="section divider" />

# Scenario Matrix

The four scenario repositories use one shared infrastructure and one documentation standard. The table separates **scenario behavior** from the infrastructure already available to support it.

| # | Scenario | Primary MITRE ATT&CK | Detection focus | Response objective | Infrastructure state |
|---|---|---|---|---|---|
| 01 | DNS Reconnaissance & Enumeration | `T1590.002` — Gather Victim Network Information: DNS | query volume, unique names, record-type diversity, source identity and Web/network follow-up | investigate source/scope and verify the approved response | Scenario 01 complete: Detection Engineering + external-adversary execution + SOC + IR + final comparison |
| 02 | DGA + High NXDOMAIN | `T1568.002` — Dynamic Resolution: Domain Generation Algorithms | NXDOMAIN count/ratio, unique generated names, rate, label length/randomness, client/time behavior | human-confirm DGA-like behavior, enable approved RPZ/sinkhole response and prove before/after | **Complete: resolver/victim/sinkhole + telemetry + ML + Detection Engineering + Dashboard/Alert + Scenario AI + official DGA/SOC/IR exercise + approved RPZ containment + safe reset** |
| 03 | Fast Flux DNS | `T1568.001` — Dynamic Resolution: Fast Flux DNS | answer/IP churn, TTL, changing destinations and client follow-up | identify controlled flux behavior and verify containment | Reuse Scenario 02 platform; temporary flux resources later |
| 04 | DNS Tunneling | `T1071.004` — Application Layer Protocol: DNS; `T1572` only where implemented behavior fits | label structure/length, frequency, query type, unique subdomains and client behavior | investigate encoded DNS behavior and prove block/sinkhole result | Reuse Scenario 02 platform; authoritative endpoint only if final design requires it |

## Scenario 02 status boundary

Infrastructure validation has already proven:

```text
victim -> Unbound -> normal DNS / NXDOMAIN
resolver logs -> Splunk
RPZ match -> Splunk
controlled RPZ redirect -> private Nginx sinkhole
sinkhole access log -> Splunk
reset -> NXDOMAIN / safe disabled enforcement
```

The Scenario 02 exercise is now **complete** in the separate Scenario 02 repository. The final case includes Machine Learning Engineering, Detection Engineering, Dashboard Studio, Detection v1.0, scheduled alerting, Rule ↔ ML comparison, AI assistance, fresh information-separated DGA execution, independent SOC/IR decisions, human-approved RPZ containment, before/after verification, and safe reset.

## Common completion rule

A scenario is complete only after the repository can reproduce and defend the full chain:

**Adversary/Operator Activity → Telemetry → Detection → Alert → AI Assistance → Independent Human Investigation → IR Decision → Response Verification → Evidence Review → Lessons Learned.**

<img src="https://user-images.githubusercontent.com/73097560/115834477-dbab4500-a447-11eb-908a-139a6edaec5c.gif" width="100%" alt="section divider" />

<!-- dns-soc-footer:start -->
<div align="center">

[🏠 Repository Home](../README.md) · [📁 00 Project Design](README.md)

<sub>DNSentinel Lab · Controlled DNS security training documentation</sub>

</div>
<!-- dns-soc-footer:end -->
