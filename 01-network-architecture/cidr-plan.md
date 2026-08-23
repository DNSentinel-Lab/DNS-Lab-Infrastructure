<!-- dns-soc-nav:start -->
[🏠 Repository Home](../README.md) · [📁 01 Network Architecture](README.md)
<!-- dns-soc-nav:end -->

<img src="https://user-images.githubusercontent.com/73097560/115834477-dbab4500-a447-11eb-908a-139a6edaec5c.gif" width="100%" alt="section divider" />

# CIDR and Address Plan

The defender CIDRs remain stable. The repository also preserves the original in-account attack-VPC CIDR as historical engineering evidence, but the official Scenario 01 attacker now runs in a separate AWS account and its private addressing is intentionally not part of the defender CIDR plan.

## VPCs

| VPC | CIDR | Purpose |
|---|---|---|
| `SOC-LAB-VPC` | `10.50.0.0/16` | Target, SIEM and monitoring/defense services |
| `ATTACK-LAB-VPC` | `10.60.0.0/16` | Historical in-account engineering attack environment — not the official Scenario 01 attacker |

## Subnets

| VPC | Subnet | CIDR | Route type | Purpose |
|---|---|---|---|---|
| SOC | `SOC-TARGET-SUBNET` | `10.50.10.0/24` | Public | Public Web target + public monitoring NAT placement |
| SOC | `SOC-SIEM-SUBNET` | `10.50.20.0/24` | Public/restricted | Splunk / AI services with restricted inbound access |
| SOC | `SOC-MONITORING-SUBNET` | `10.50.30.0/24` | Private + NAT egress | Defender resolver, victim and sinkhole |
| Historical Attack | `ATTACK-PUBLIC-SUBNET` | `10.60.10.0/24` | Public | Historical engineering attack host |

## Assigned private addresses

| Address | Deployed role | State |
|---|---|---|
| `10.50.10.10` | `dns-soc-web01` | Deployed |
| `10.50.20.10` | `dns-soc-splunk01` | Deployed |
| `10.50.30.10` | `dns-soc-resolver01` | **Deployed** |
| `10.50.30.20` | `dns-soc-victim01` | **Deployed** |
| `10.50.30.30` | `dns-soc-sinkhole01` | **Deployed** |
| `10.60.10.10` | `dns-attack01` | Deployed — historical engineering host |


## Official external attacker addressing

The official Kali adversary runs in a separate AWS account. Its private VPC/subnet addressing and account identifiers are deliberately omitted from this defender repository because they are not required for the SOC investigation. Defender-visible identity begins at the public Internet boundary.

## Monitoring subnet egress

`SOC-MONITORING-SUBNET` remains private. Its route table uses `SOC-MONITORING-NAT` for `0.0.0.0/0`, while `10.50.0.0/16` stays local.

This supports package updates/management without assigning public IPv4 addresses to the Scenario 02 hosts.

<img src="https://user-images.githubusercontent.com/73097560/115834477-dbab4500-a447-11eb-908a-139a6edaec5c.gif" width="100%" alt="section divider" />

<!-- dns-soc-footer:start -->
<div align="center">

[🏠 Repository Home](../README.md) · [📁 01 Network Architecture](README.md)

<sub>DNSentinel Lab · Controlled DNS security training documentation</sub>

</div>
<!-- dns-soc-footer:end -->
