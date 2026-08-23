# External Adversary Boundary — Official Scenario 01

## Current operating decision

The official Scenario 01 attacker is **not** a workload inside the defender AWS account.

The live adversary side is:

```text
Separate AWS account
    └── Kali attacker EC2

Optional second source
    └── external Windows machine
```

The defender/SOC side remains in the project AWS account.

## Trust boundary

```text
External attacker account / Windows
        |
        | public Internet only
        v
Route 53 public authoritative DNS
        |
        +--> public DNS responses to attacker
        |
        +--> Route 53 query logs -> Splunk

Optional HTTPS follow-up
        |
        v
dns-soc-web01 public endpoint
        |
        +--> Nginx logs -> Splunk
        +--> VPC Flow Logs -> Splunk
```

There is no:

- cross-account VPC peering;
- Transit Gateway trust;
- private route from attacker to `10.50.0.0/16`;
- defender inventory record that identifies the official attacker host;
- attacker-account CloudTrail/VPC Flow/Resolver telemetry supplied to the SOC Analyst.

This makes the defender investigation depend on **what the target side actually observed**, not on attacker-side ground truth.

## Historical attack VPC

The repository still contains build evidence for:

```text
ATTACK-LAB-VPC 10.60.0.0/16
dns-attack01  10.60.10.10
```

That environment was created during early infrastructure engineering and remains useful historical evidence. It is **superseded operationally for the official Scenario 01 blind exercise** by the separate-account attacker.

Historical screenshots/configuration are not rewritten to pretend they were created in another account.

## Why this matters for SOC realism

The SOC Analyst cannot simply look at same-account EC2 inventory and decide that the source is a lab attacker.

Instead, the analyst must reason from:

- Route 53 authoritative queries;
- source/resolver semantics;
- time and frequency;
- names and record types;
- baseline comparison;
- optional Nginx/VPC follow-up;
- AI assistance that is also blind to attacker ground truth.

The attacker public IP, commands and exact execution times remain private until the defender investigation is locked.

## Scenario 01 framework position

- **MITRE ATT&CK:** `T1590.002 — Gather Victim Network Information: DNS`
- **ATT&CK tactic:** Reconnaissance
- **Cyber Kill Chain:** Reconnaissance

Scenario 01 stops at information gathering. Exploitation, credential attacks, destructive actions and denial of service are outside this scenario boundary.
