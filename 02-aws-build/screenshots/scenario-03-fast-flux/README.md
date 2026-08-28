# Scenario 03 Fast Flux Infrastructure Evidence

| File | What it proves |
|---|---|
| `01-sg-flux-endpoints-created.png` | public HTTP-only controlled endpoint SG created |
| `02-flux-node-address-discovery.png` | three controlled nodes and current public/private addresses |
| `03-route53-flux-record-ttl60.png` | Fast Flux A record with 60-second TTL |
| `04-rotation-script-upserts.png` | live node refresh + Route 53 UPSERT rotation |
| `05-authoritative-answer-validation.png` | direct authoritative A-answer validation |
| `06-victim-follows-rotating-answers.png` | victim follows DNS-returned address and reaches node |
| `07-vpc-flow-fast-flux-destinations.png` | Splunk/VPC Flow sees changing victim destinations |
