<img src="https://capsule-render.vercel.app/api?type=rect&color=gradient&customColorList=12,19,24&height=135&section=header&text=Project%20Design&fontSize=34&fontColor=ffffff&animation=fadeIn&desc=Scope%20%7C%20Scenarios%20%7C%20Roles%20%7C%20Roadmaps&descSize=15&descAlignY=68" width="100%" alt="Project Design" />

[🏠 Repository Home](../README.md) · **🧭 Project Design** · [🌐 Network Architecture](../01-network-architecture/README.md)

This folder is the **source of truth for what the lab is building and why**. It keeps scope, team model, scenario boundaries and implementation sequencing separate from low-level AWS/Splunk configuration.

<img src="https://user-images.githubusercontent.com/73097560/115834477-dbab4500-a447-11eb-908a-139a6edaec5c.gif" width="100%" alt="section divider" />

## 📚 Design Documents

| Document | Purpose |
|---|---|
| 🎯 [`project-scope.md`](project-scope.md) | Objective, boundaries, technology choices and success criteria |
| 👥 [`team-roles.md`](team-roles.md) | Four rotating roles and shared responsibilities |
| 🧪 [`scenario-matrix.md`](scenario-matrix.md) | Side-by-side view of all four DNS scenarios |
| 🚦 [`project-roadmap.md`](project-roadmap.md) | Build sequence and current progress |
| 📡 [`scenario-dns-plan.md`](scenario-dns-plan.md) | Permanent child-zone baseline and later scenario-specific DNS changes |
| 🏗️ [`scenario-infrastructure-roadmap.md`](scenario-infrastructure-roadmap.md) | Implemented Scenario 02 defender-DNS resources, completed Scenario 03 Fast Flux extension, and completed Scenario 04 authoritative-DNS preparation |
| 📋 [`scenario-documentation-standard.md`](scenario-documentation-standard.md) | Required 20-part scenario workflow, network/MITRE discipline and dashboard standard |

## 🧭 How This Section Fits

```mermaid
flowchart LR

    %% =====================================================
    %% PROJECT ENTRY
    %% =====================================================
    P["🧭 Project<br/>Design"]

    %% =====================================================
    %% SHARED PLATFORM PATH
    %% =====================================================
    N["🌐 Network<br/>Architecture"]
    A["☁️ AWS<br/>Build"]
    S["📊 Splunk<br/>Build"]
    AI["🤖 Shared<br/>AI"]

    P --> N
    N --> A
    A --> S
    S --> AI

    %% =====================================================
    %% SCENARIO BRANCH
    %% =====================================================
    R["🗂️ Separate Scenario<br/>Repositories"]

    P -. "Scenario-specific work" .-> R


    %% =====================================================
    %% STYLING
    %% =====================================================
    classDef project fill:#172554,stroke:#60a5fa,stroke-width:3px,color:#ffffff;
    classDef network fill:#083344,stroke:#22d3ee,stroke-width:2px,color:#ffffff;
    classDef aws fill:#3f2a0a,stroke:#f59e0b,stroke-width:2px,color:#ffffff;
    classDef splunk fill:#052e16,stroke:#4ade80,stroke-width:2px,color:#ffffff;
    classDef ai fill:#3b0764,stroke:#c084fc,stroke-width:2px,color:#ffffff;
    classDef repo fill:#1f2937,stroke:#f472b6,stroke-width:2px,color:#ffffff;

    class P project;
    class N network;
    class A aws;
    class S splunk;
    class AI ai;
    class R repo;

    linkStyle 0 stroke:#38bdf8,stroke-width:3px
    linkStyle 1 stroke:#f59e0b,stroke-width:3px
    linkStyle 2 stroke:#4ade80,stroke-width:3px
    linkStyle 3 stroke:#c084fc,stroke-width:3px
    linkStyle 4 stroke:#f472b6,stroke-width:2px
```

Detailed VPC, subnet, routing, DNS authority and traffic decisions belong in [`../01-network-architecture/`](../01-network-architecture/) so project scope does not become a duplicate architecture manual.

## 🚦 Current Design State

- The **four-scenario model** remains the shared baseline.
- The **shared AI foundation** is complete.
- The **official Scenario 01 adversary boundary** is a separate AWS account, the original in-account attack VPC remains historical engineering evidence.
- The **Scenario 02 defender-DNS infrastructure** is complete.
- The **Scenario 03 Fast Flux extension** is complete.
- **Scenario 04 is now complete end to end:** authoritative-DNS preparation, Detection Engineering, the information-separated operator/SOC/IR exercise, human-approved RPZ containment verification, safe reset and final closeout are maintained in the dedicated Scenario 04 repository.
- Scenario implementation/evidence is maintained in separate scenario repositories.

[`scenario-infrastructure-roadmap.md`](scenario-infrastructure-roadmap.md) records what is already implemented across the scenario-specific infrastructure extensions and what remains operationally conditional. [`scenario-documentation-standard.md`](scenario-documentation-standard.md) keeps all four scenario repositories reproducible and consistent.

<img src="https://user-images.githubusercontent.com/73097560/115834477-dbab4500-a447-11eb-908a-139a6edaec5c.gif" width="100%" alt="section divider" />

[🏠 Repository Home](../README.md) · [🌐 Next: Network Architecture](../01-network-architecture/README.md)
