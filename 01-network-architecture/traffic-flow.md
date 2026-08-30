<!-- dns-soc-nav:start -->
[🏠 Repository Home](../README.md) · [📁 01 Network Architecture](README.md)
<!-- dns-soc-nav:end -->

<img src="https://user-images.githubusercontent.com/73097560/115834477-dbab4500-a447-11eb-908a-139a6edaec5c.gif" width="100%" alt="section divider" />

# Traffic Flow

The lab has separate paths for public DNS, public scenario activity, SOC administration, Web telemetry, AWS telemetry, the completed defender-controlled DNS path and the shared AI bridge.

## Public DNS resolution path

```mermaid
%%{init: {
  "theme": "base",
  "themeVariables": {
    "background": "#0d1117",
    "primaryColor": "#111827",
    "primaryTextColor": "#ffffff",
    "primaryBorderColor": "#94a3b8",
    "lineColor": "#cbd5e1",
    "secondaryColor": "#111827",
    "tertiaryColor": "#0f172a",
    "fontSize": "22px"
  }
}}%%

sequenceDiagram
    autonumber

    participant C as 🌐 Public Client<br/>Resolver

    box rgb(17, 24, 39) Route 53 DNS Authority
        participant P as 🏠 Parent<br/>Route 53 Zone
        participant D as 🧪 Child<br/>Route 53 Zone
    end

    participant W as 🖥️ Web Target<br/>dns-soc-web01

    Note over C,D: 🔎 TARGET · soclab.abdul4rehman215.tech

    rect rgba(59, 130, 246, 0.16)
        Note over C,P: 1 · DELEGATION DISCOVERY
        C->>P: Parent lookup
        activate P
        Note over P: Delegation for child zone
        P-->>C: Child nameservers
        deactivate P
    end

    rect rgba(168, 85, 247, 0.16)
        Note over C,D: 2 · AUTHORITATIVE RESOLUTION
        C->>D: Record lookup
        activate D
        Note over D: A / TXT / NS / www
        D-->>C: DNS answer
        deactivate D
    end

    rect rgba(34, 197, 94, 0.16)
        Note over C,W: 3 · OPTIONAL APPLICATION FOLLOW-UP
        opt Client follows resolved web address
            C->>W: HTTPS
            activate W
            W-->>C: Response
            deactivate W
        end
    end
```

## Scenario 01 public path

```text
Separate AWS account / Kali
        + optional external Windows
                 |
                 v
              Internet
                 |
                 +--> Route 53 child authority
                 |        +--> authoritative DNS response
                 |        +--> Route 53 query log -> Splunk
                 |
                 +--> optional public Web follow-up
                          +--> Nginx -> UF -> Splunk
                          +--> VPC Flow Logs -> Splunk
```

No attacker-to-SOC private route exists. The official attacker account does not forward its own CloudTrail, Flow Logs or Resolver logs into the defender SIEM. This preserves the information-separation boundary.

## Team management path

```text
Team browser -> Internet -> Splunk Web :8000
                         -> approved team sources only

Team admin   -> AWS Systems Manager -> EC2
             -> no public SSH required
```

## Web telemetry path

```text
dns-soc-web01
   -> Splunk Universal Forwarder
   -> VPC-local TCP 9997
   -> dns-soc-splunk01
   -> index=dns_soc_web
```

## AWS telemetry paths

```text
Route 53 public query logs -> CloudWatch -> Kinesis -> Splunk
VPC Flow Logs              -> S3 -> SQS -> Splunk
CloudTrail                 -> S3 -> SQS -> Splunk
AWS Resolver Query Logs    -> S3 -> SQS -> Splunk
                                              |
                                              v
                                      index=dns_soc_aws
```

Public authoritative DNS logs and AWS VPC Resolver Query Logs are different visibility points and are not expected to contain identical events.

## Completed Scenario 02 normal DNS path

```mermaid
%%{init: {
  "theme": "base",
  "themeVariables": {
    "background": "#070B14",
    "fontSize": "28px",

    "primaryColor": "#111827",
    "primaryTextColor": "#FFFFFF",
    "primaryBorderColor": "#E2E8F0",

    "actorBkg": "#111827",
    "actorBorder": "#F8FAFC",
    "actorTextColor": "#FFFFFF",
    "actorLineColor": "#64748B",

    "signalColor": "#F8FAFC",
    "signalTextColor": "#FFFFFF",

    "labelBoxBkgColor": "#111827",
    "labelBoxBorderColor": "#94A3B8",
    "labelTextColor": "#FFFFFF",

    "noteBkgColor": "#172554",
    "noteBorderColor": "#60A5FA",
    "noteTextColor": "#FFFFFF",

    "sequenceNumberColor": "#FFFFFF"
  }
}}%%

sequenceDiagram
    autonumber

    box rgb(15, 42, 92) CLIENT
        participant V as 🖥️ dns-soc-victim01<br/>10.50.30.20
    end

    box rgb(8, 77, 94) DEFENDER DNS
        participant R as 🛡️ dns-soc-resolver01<br/>Unbound · 10.50.30.10
    end

    box rgb(76, 29, 149) AWS DNS
        participant A as ☁️ AWS VPC Resolver<br/>10.50.0.2
    end

    box rgb(20, 83, 45) AUTHORITY
        participant D as 🌐 DNS Authority
    end

    Note over V,D: ✨ NORMAL DNS RESOLUTION · DEFENDER-CONTROLLED PATH

    rect rgba(37, 99, 235, 0.24)
        Note over V,R: 🔵 1 · CLIENT DNS QUERY
        V->>R: DNS Query · UDP/TCP 53
    end

    rect rgba(147, 51, 234, 0.24)
        Note over R,D: 🟣 2 · RECURSIVE + AUTHORITATIVE LOOKUP

        R->>A: Forward DNS Request
        activate A

        A->>D: Resolve Authoritative Data
        activate D

        D-->>A: Answer / NXDOMAIN
        deactivate D

        deactivate A
    end

    rect rgba(16, 185, 129, 0.24)
        Note over A,V: 🟢 3 · DNS RESPONSE RETURN

        A-->>R: Recursive Result
        activate R

        R-->>V: Final DNS Result
        deactivate R
    end

    Note over V,D: ✅ Query → Resolve → Answer → Return
```

Normal victim applications use the Ubuntu local stub (`127.0.0.53`), whose validated upstream is `10.50.30.10`.

## Resolver telemetry path

```text
Unbound
  -> syslog
  -> rsyslog filter
  -> /var/log/dns-soc/unbound.log
  -> Resolver UF
  -> 10.50.20.10:9997
  -> index=dns_soc_dns / sourcetype=unbound:dns
```

## RPZ/sinkhole response path

Safe default:

```text
victim query -> Unbound RPZ match -> match logged -> enforcement disabled -> normal upstream result
```

Controlled response when deliberately enabled:

```text
victim query
    -> Unbound RPZ
    -> A 10.50.30.30
    -> dns-soc-sinkhole01:80
    -> Nginx access log
    -> Sinkhole UF
    -> index=dns_soc_web / sourcetype=nginx:access
```

The infrastructure test proved this once and then restored disabled enforcement. Future scenario containment still requires a human decision.

## Monitoring-subnet egress

```text
dns-soc-resolver01 / victim / sinkhole
    -> SOC-PRIVATE-RT 0.0.0.0/0
    -> SOC-MONITORING-NAT in SOC-TARGET-SUBNET
    -> SOC-LAB-IGW
    -> Internet
```

This path supports package/management egress and does not make the three hosts public.

## Shared AI path

```text
Splunk scheduled alert
    -> internal webhook
    -> dns-soc-ai-bridge
    -> OpenAI Responses API
    -> internal HTTPS HEC
    -> index=dns_soc_ai
    -> human SOC validation
```

AI output is advisory; raw telemetry remains the evidence source.

## Scenario 03 — implemented Fast Flux traffic path

Scenario 03 reuses the Scenario 02 defender DNS path and reaches the controlled Fast Flux nodes through public addressing. There is still **no VPC peering** between the SOC and attacker VPCs.

```text
dns-soc-victim01 10.50.30.20
        ↓ DNS
dns-soc-resolver01 10.50.30.10
        ↓
flux.soclab.abdul4rehman215.tech / TTL 60
        ↓ public DNS answer
13.220.94.188 / 52.73.218.100 / 54.81.98.44 (exercise-time values)
        ↓ HTTP/80
controlled flux nodes in ATTACK-LAB-VPC
        ↓
VPC Flow + Resolver logs → Splunk
```

The three public IP values above are observed validation values; the control script refreshes current node public IPs before rotation. Detailed build evidence: [`../02-aws-build/09-scenario-03-fast-flux.md`](../02-aws-build/09-scenario-03-fast-flux.md).

## Scenario 04 authoritative DNS path

Scenario 04 reuses the Scenario 02 victim/resolver/sinkhole path and now adds a controlled public authoritative endpoint in the existing `ATTACK-LAB-VPC`. No VPC peering or private attacker-to-SOC route was introduced.

```text
dns-soc-victim01 10.50.30.20
        | system DNS
        v
dns-soc-resolver01 10.50.30.10 / Unbound
        | recursive upstream
        v
AWS/public recursive DNS
        |
        v
Route 53: tunnel.soclab... NS delegation
        |
        v
dns-tunnel-auth01 10.60.10.30 / BIND authoritative-only
        |
        +--> /var/log/named/scenario04-queries.log

Defender telemetry: Unbound -> Splunk
Later response: Unbound RPZ -> 10.50.30.30 sinkhole
```

Unbound sees the original private client. The public authoritative service sees upstream recursive-resolver source addresses. Those two views must not be confused during investigation.

<img src="https://user-images.githubusercontent.com/73097560/115834477-dbab4500-a447-11eb-908a-139a6edaec5c.gif" width="100%" alt="section divider" />

<!-- dns-soc-footer:start -->
<div align="center">

[🏠 Repository Home](../README.md) · [📁 01 Network Architecture](README.md)

<sub>DNSentinel Lab · Controlled DNS security training documentation</sub>

</div>
<!-- dns-soc-footer:end -->
