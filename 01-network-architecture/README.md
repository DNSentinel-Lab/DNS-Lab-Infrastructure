<img src="https://capsule-render.vercel.app/api?type=rect&color=gradient&customColorList=6,12,19&height=135&section=header&text=Network%20Architecture&fontSize=34&fontColor=ffffff&animation=fadeIn&desc=VPCs%20%7C%20DNS%20Authority%20%7C%20Trust%20Boundaries%20%7C%20Traffic%20Flow&descSize=15&descAlignY=68" width="100%" alt="Network Architecture" />

[🏠 Repository Home](../README.md) · [🧭 Project Design](../00-project-design/README.md) · **🌐 Network Architecture** · [☁️ AWS Build](../02-aws-build/README.md)

This folder is the **network and DNS blueprint** for the lab. It explains how traffic moves, how the public namespace is delegated, how the official external adversary is separated from the defender AWS account, and how the defender-controlled DNS path fits into the locked design.

<img src="https://user-images.githubusercontent.com/73097560/115834477-dbab4500-a447-11eb-908a-139a6edaec5c.gif" width="100%" alt="section divider" />

## 🗺️ Architecture Documents

| Document | Purpose |
|---|---|
| 🏗️ [`base-network.md`](base-network.md) | Overall AWS network design and trust boundaries |
| 🧮 [`cidr-plan.md`](cidr-plan.md) | Defender CIDRs plus the historical in-account attack-VPC record |
| 🕶️ [`external-adversary-boundary.md`](external-adversary-boundary.md) | Official Scenario 01 separate-account attacker trust boundary |
| 🔐 [`security-groups.md`](security-groups.md) | Baseline and Scenario 02 service exposure / SG-to-SG access |
| 🌍 [`dns-authority-and-delegation.md`](dns-authority-and-delegation.md) | Registrar, parent zone, child zone and public DNS delegation |
| 🔀 [`traffic-flow.md`](traffic-flow.md) | Management, DNS, public target, logging, defender DNS and response paths |
| 🧩 [`diagrams/`](diagrams/) | Editable Mermaid source used by architecture documentation |

## 🔐 Trust Boundary at a Glance

```mermaid
flowchart LR

    %% =====================================================
    %% EXTERNAL / UNTRUSTED SIDE
    %% =====================================================
    A["🌍 External Attacker<br/>Account / Windows"]

    %% =====================================================
    %% PUBLIC EXPOSURE
    %% =====================================================
    P["🌐 Public Lab<br/>Surface"]

    %% =====================================================
    %% TRUSTED SOC SIDE
    %% =====================================================
    S["🏰 SOC-LAB-VPC"]
    SPL["📊 Splunk"]

    %% =====================================================
    %% DEFENDER DNS PATH
    %% =====================================================
    V["💻 Victim"]
    R["🛡️ Defender DNS<br/>Resolver"]
    U["☁️ Upstream DNS"]

    %% =====================================================
    %% ALLOWED PATHS
    %% =====================================================
    A -->|"Public DNS / Internet Only"| P
    P -->|"Public Entry"| S
    S -->|"Telemetry / SOC Access"| SPL

    V -->|"System DNS"| R
    R -->|"Forwarded Queries"| U

    %% =====================================================
    %% BLOCKED TRUST PATH
    %% =====================================================
    A -. "❌ No Peering / No Private Route" .-> S


    %% =====================================================
    %% STYLING
    %% =====================================================
    classDef external fill:#450a0a,stroke:#f87171,stroke-width:3px,color:#ffffff;
    classDef public fill:#7c2d12,stroke:#fb923c,stroke-width:2px,color:#ffffff;
    classDef trusted fill:#172554,stroke:#60a5fa,stroke-width:3px,color:#ffffff;
    classDef splunk fill:#052e16,stroke:#4ade80,stroke-width:3px,color:#ffffff;

    classDef victim fill:#1f2937,stroke:#94a3b8,stroke-width:2px,color:#ffffff;
    classDef resolver fill:#083344,stroke:#22d3ee,stroke-width:3px,color:#ffffff;
    classDef upstream fill:#164e63,stroke:#2dd4bf,stroke-width:2px,color:#ffffff;

    class A external;
    class P public;
    class S trusted;
    class SPL splunk;

    class V victim;
    class R resolver;
    class U upstream;

    %% Allowed paths
    linkStyle 0 stroke:#fb923c,stroke-width:3px
    linkStyle 1 stroke:#60a5fa,stroke-width:3px
    linkStyle 2 stroke:#4ade80,stroke-width:3px
    linkStyle 3 stroke:#22d3ee,stroke-width:3px
    linkStyle 4 stroke:#2dd4bf,stroke-width:3px

    %% Blocked / no-trust path
    linkStyle 5 stroke:#f87171,stroke-width:3px,stroke-dasharray:6 5
```

Implementation evidence stays in [`../02-aws-build/`](../02-aws-build/); Splunk-side data onboarding stays in [`../03-splunk-build/`](../03-splunk-build/).

## 🛡️ Scenario Platform State

`SOC-MONITORING-SUBNET` is active and hosts the Scenario 02 defender DNS platform:

| Host | Address | Role |
|---|---:|---|
| `dns-soc-resolver01` | `10.50.30.10` | Unbound resolver / defender DNS |
| `dns-soc-victim01` | `10.50.30.20` | Controlled victim endpoint |
| `dns-soc-sinkhole01` | `10.50.30.30` | Private sinkhole target |

The subnet remains private and uses `SOC-MONITORING-NAT` for outbound package/management egress. No private attacker-to-SOC route exists. The official Scenario 01 adversary is outside the defender account and uses public Internet paths only.

<img src="https://user-images.githubusercontent.com/73097560/115834477-dbab4500-a447-11eb-908a-139a6edaec5c.gif" width="100%" alt="section divider" />

[🧭 Previous: Project Design](../00-project-design/README.md) · [🏠 Repository Home](../README.md) · [☁️ Next: AWS Build](../02-aws-build/README.md)
