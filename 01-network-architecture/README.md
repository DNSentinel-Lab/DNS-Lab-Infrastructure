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
%%{init: {
  "theme": "base",
  "themeVariables": {
    "background": "#0d1117",
    "fontSize": "26px",
    "primaryTextColor": "#ffffff",
    "lineColor": "#cbd5e1"
  },
  "flowchart": {
    "nodeSpacing": 40,
    "rankSpacing": 55,
    "curve": "basis"
  }
}}%%

flowchart LR

    %% =====================================================
    %% MAIN SYSTEM NODES
    %% =====================================================
    A["🌍 External Attacker<br/>Account / Windows"]
    P["🌐 Public Lab<br/>Surface"]

    S["🏰 SOC-LAB-VPC"]
    SPL["📊 Splunk"]

    V["💻 Victim"]
    R["🛡️ Defender DNS<br/>Resolver"]
    U["☁️ Upstream DNS"]

    X["⛔ NO PEERING<br/>NO PRIVATE ROUTE"]


    %% =====================================================
    %% LARGE CONNECTION LABEL CARDS
    %% =====================================================
    L1["🌐 PUBLIC DNS<br/>INTERNET"]
    L2["🚪 PUBLIC ENTRY"]
    L3["📡 TELEMETRY<br/>SOC ACCESS"]

    L4["🔎 SYSTEM DNS"]
    L5["↗️ FORWARDED<br/>QUERIES"]


    %% =====================================================
    %% PUBLIC / SOC PATH
    %% =====================================================
    A --> L1 --> P
    P --> L2 --> S
    S --> L3 --> SPL


    %% =====================================================
    %% DEFENDER DNS PATH
    %% =====================================================
    V --> L4 --> R
    R --> L5 --> U


    %% =====================================================
    %% BLOCKED TRUST PATH
    %% =====================================================
    A -.-> X
    X -.-> S


    %% =====================================================
    %% MAIN NODE STYLES
    %% =====================================================
    classDef external fill:#450a0a,stroke:#fb7185,stroke-width:4px,color:#ffffff,font-size:26px;

    classDef public fill:#7c2d12,stroke:#fb923c,stroke-width:4px,color:#ffffff,font-size:26px;

    classDef trusted fill:#172554,stroke:#60a5fa,stroke-width:4px,color:#ffffff,font-size:26px;

    classDef splunk fill:#052e16,stroke:#4ade80,stroke-width:4px,color:#ffffff,font-size:26px;

    classDef victim fill:#1f2937,stroke:#cbd5e1,stroke-width:4px,color:#ffffff,font-size:26px;

    classDef resolver fill:#083344,stroke:#22d3ee,stroke-width:4px,color:#ffffff,font-size:26px;

    classDef upstream fill:#164e63,stroke:#2dd4bf,stroke-width:4px,color:#ffffff,font-size:26px;

    classDef blocked fill:#450a0a,stroke:#f87171,stroke-width:4px,color:#ffffff,font-size:24px;


    %% =====================================================
    %% CONNECTION CARD STYLES
    %% =====================================================
    classDef orangeLabel fill:#422006,stroke:#fb923c,stroke-width:3px,color:#ffffff,font-size:22px;

    classDef blueLabel fill:#172554,stroke:#60a5fa,stroke-width:3px,color:#ffffff,font-size:22px;

    classDef greenLabel fill:#052e16,stroke:#4ade80,stroke-width:3px,color:#ffffff,font-size:22px;

    classDef cyanLabel fill:#083344,stroke:#22d3ee,stroke-width:3px,color:#ffffff,font-size:22px;

    classDef tealLabel fill:#134e4a,stroke:#2dd4bf,stroke-width:3px,color:#ffffff,font-size:22px;


    %% =====================================================
    %% APPLY CLASSES
    %% =====================================================
    class A external;
    class P public;

    class S trusted;
    class SPL splunk;

    class V victim;
    class R resolver;
    class U upstream;

    class X blocked;

    class L1 orangeLabel;
    class L2 blueLabel;
    class L3 greenLabel;
    class L4 cyanLabel;
    class L5 tealLabel;


    %% =====================================================
    %% COLORED CONNECTIONS
    %% =====================================================
    linkStyle 0,1 stroke:#fb923c,stroke-width:5px
    linkStyle 2,3 stroke:#60a5fa,stroke-width:5px
    linkStyle 4,5 stroke:#4ade80,stroke-width:5px

    linkStyle 6,7 stroke:#22d3ee,stroke-width:5px
    linkStyle 8,9 stroke:#2dd4bf,stroke-width:5px

    linkStyle 10,11 stroke:#f87171,stroke-width:4px,stroke-dasharray:8 6
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


## Scenario-specific implemented diagrams

- [`diagrams/scenario-03-fast-flux.mmd`](diagrams/scenario-03-fast-flux.mmd) — implemented Scenario 03 answer rotation, victim follow-up and Splunk telemetry path.

<img src="https://user-images.githubusercontent.com/73097560/115834477-dbab4500-a447-11eb-908a-139a6edaec5c.gif" width="100%" alt="section divider" />

[🧭 Previous: Project Design](../00-project-design/README.md) · [🏠 Repository Home](../README.md) · [☁️ Next: AWS Build](../02-aws-build/README.md)
