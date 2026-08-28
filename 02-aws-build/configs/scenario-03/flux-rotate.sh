#!/bin/bash
set -euo pipefail

REGION="us-east-1"
HOSTED_ZONE_ID="Z0116802C4H563Z159K"
RECORD_NAME="flux.soclab.abdul4rehman215.tech"
TTL="60"

NODE_NAMES=(
  "dns-flux-node01"
  "dns-flux-node02"
  "dns-flux-node03"
)

echo "=============================================="
echo " DNSentinel Scenario 03 - Fast Flux Rotation"
echo "=============================================="

while true; do
  echo
  echo "[+] Refreshing current public IP addresses..."

  IPS=()
  for NODE in "${NODE_NAMES[@]}"; do
    IP=$(aws ec2 describe-instances \
      --region "$REGION" \
      --filters \
        "Name=tag:Name,Values=$NODE" \
        "Name=instance-state-name,Values=running" \
      --query "Reservations[0].Instances[0].PublicIpAddress" \
      --output text)

    if [[ -z "$IP" || "$IP" == "None" ]]; then
      echo "[!] $NODE has no running public IP."
      exit 1
    fi

    IPS+=("$IP")
    echo "    $NODE -> $IP"
  done

  echo
  echo "[+] Starting one rotation cycle..."

  for i in "${!IPS[@]}"; do
    NODE="${NODE_NAMES[$i]}"
    IP="${IPS[$i]}"

    echo
    echo "[$(date -u '+%Y-%m-%dT%H:%M:%SZ')]"
    echo "[+] Setting:"
    echo "    $RECORD_NAME"
    echo "    -> $NODE"
    echo "    -> $IP"

    CHANGE_FILE=$(mktemp)
    cat > "$CHANGE_FILE" <<JSON
{
  "Comment": "DNSentinel Scenario 03 controlled Fast Flux rotation",
  "Changes": [
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "$RECORD_NAME",
        "Type": "A",
        "TTL": $TTL,
        "ResourceRecords": [
          {"Value": "$IP"}
        ]
      }
    }
  ]
}
JSON

    aws route53 change-resource-record-sets \
      --hosted-zone-id "$HOSTED_ZONE_ID" \
      --change-batch "file://$CHANGE_FILE" \
      --output text >/dev/null

    rm -f "$CHANGE_FILE"
    echo "[+] Route 53 UPSERT submitted."
    echo "[+] Waiting 120 seconds before next node..."
    sleep 120
  done
done
