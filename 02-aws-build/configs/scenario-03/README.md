# Scenario 03 Infrastructure Configuration Artifacts

- [`flux-rotate.sh`](flux-rotate.sh) — preserved Route 53 Fast Flux rotation script used by the Scenario 03 control host.
- [`iam/DNSentinel-Scenario03-Flux-Rotation.json`](iam/DNSentinel-Scenario03-Flux-Rotation.json) — least-privilege IAM policy used to discover the three current node public IPs and UPSERT only the Scenario 03 Fast Flux A record.

The public addresses of the temporary flux nodes are discovered at runtime rather than hard-coded into the script.

- [`ARTIFACT-MANIFEST.md`](ARTIFACT-MANIFEST.md) / [`ARTIFACT-MANIFEST.csv`](ARTIFACT-MANIFEST.csv) — SHA-256 integrity index for Scenario 03 infrastructure artifacts.
