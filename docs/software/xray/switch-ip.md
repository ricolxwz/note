---
title: 无缝切换ip
comments: true
---

# 无缝切换ip

## POSIX

```bash
#!/usr/bin/env bash

OLD_IP_NAME="Temp-IP"
NEW_IP_NAME="Temp-IP"
INSTANCE_NAME=""
REGION=""

CLOUDFLARE_ZONE_ID=""
CLOUDFLARE_API_TOKEN=""

# 定义多个 DNS 记录信息，每条记录格式为 "DNS_RECORD_ID,DNS_NAME"
dns_records=(
"RECORD_ID_1,example1.com"
"RECORD_ID_2,example2.com"
"RECORD_ID_3,example3.com"
)

echo "Detaching old Static IP: $OLD_IP_NAME"
aws lightsail detach-static-ip \
  --static-ip-name "$OLD_IP_NAME" \
  --region "$REGION" \
  --profile lightsail \
  --no-cli-pager

echo "Releasing old Static IP: $OLD_IP_NAME"
aws lightsail release-static-ip \
  --static-ip-name "$OLD_IP_NAME" \
  --region "$REGION" \
  --profile lightsail \
  --no-cli-pager

echo "Allocating new Static IP: $NEW_IP_NAME"
aws lightsail allocate-static-ip \
  --static-ip-name "$NEW_IP_NAME" \
  --region "$REGION" \
  --profile lightsail \
  --no-cli-pager

echo "Attaching new Static IP: $NEW_IP_NAME to instance: $INSTANCE_NAME"
aws lightsail attach-static-ip \
  --static-ip-name "$NEW_IP_NAME" \
  --instance-name "$INSTANCE_NAME" \
  --region "$REGION" \
  --profile lightsail \
  --no-cli-pager

echo "Done. New Static IP has been attached."

sleep 2

NEW_ALLOCATED_IP=$(aws lightsail get-static-ip \
  --static-ip-name "$NEW_IP_NAME" \
  --region "$REGION" \
  --profile lightsail \
  --output json | jq -r '.staticIp.ipAddress')

echo "New Static IP: $NEW_ALLOCATED_IP"

# 循环更新每条 DNS 记录
for record in "${dns_records[@]}"; do
  # 根据逗号分隔，提取 DNS_RECORD_ID 和 DNS_NAME
  IFS=',' read -r DNS_RECORD_ID DNS_NAME <<< "$record"
  
  echo "Updating DNS record: $DNS_NAME (ID: $DNS_RECORD_ID)"
  
  curl "https://api.cloudflare.com/client/v4/zones/$CLOUDFLARE_ZONE_ID/dns_records/$DNS_RECORD_ID" \
    -X PUT \
    -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{
      "content": "'"$NEW_ALLOCATED_IP"'",
      "name": "'"$DNS_NAME"'",
      "proxied": false,
      "ttl": 1,
      "type": "A"
    }'
done

echo "Done. All Cloudflare DNS records have been updated."
```

## Windows

```powershell
$OLD_IP_NAME = "Temp-IP"
$NEW_IP_NAME = "Temp-IP"
$INSTANCE_NAME = ""
$REGION = ""

$CLOUDFLARE_ZONE_ID = ""
$CLOUDFLARE_API_TOKEN = ""
$dnsRecords = @(
    @{ DNS_RECORD_ID = ""; DNS_NAME = "" },
    @{ DNS_RECORD_ID = ""; DNS_NAME = "" },
    @{ DNS_RECORD_ID = ""; DNS_NAME = "" }
)

Write-Host "Detaching old Static IP: $OLD_IP_NAME"
aws lightsail detach-static-ip `
  --static-ip-name "$OLD_IP_NAME" `
  --region "$REGION" `
  --profile lightsail `
  --no-cli-pager

Write-Host "Releasing old Static IP: $OLD_IP_NAME"
aws lightsail release-static-ip `
  --static-ip-name "$OLD_IP_NAME" `
  --region "$REGION" `
  --profile lightsail `
  --no-cli-pager

Write-Host "Allocating new Static IP: $NEW_IP_NAME"
aws lightsail allocate-static-ip `
  --static-ip-name "$NEW_IP_NAME" `
  --region "$REGION" `
  --profile lightsail `
  --no-cli-pager

Write-Host "Attaching new Static IP: $NEW_IP_NAME to instance: $INSTANCE_NAME"
aws lightsail attach-static-ip `
  --static-ip-name "$NEW_IP_NAME" `
  --instance-name "$INSTANCE_NAME" `
  --region "$REGION" `
  --profile lightsail `
  --no-cli-pager

Write-Host "Done. New Static IP has been attached."

Start-Sleep -Seconds 2

$NEW_ALLOCATED_IP = (aws lightsail get-static-ip `
  --static-ip-name "$NEW_IP_NAME" `
  --region "$REGION" `
  --profile lightsail `
  --output json | ConvertFrom-Json).staticIp.ipAddress

Write-Host "New Static IP: $NEW_ALLOCATED_IP"

$headers = @{
    "Authorization" = "Bearer $CLOUDFLARE_API_TOKEN"
    "Content-Type"  = "application/json"
}

# 循环更新每条 DNS 记录
foreach ($record in $dnsRecords) {
    $payload = @{
        content = $NEW_ALLOCATED_IP
        name    = $record.DNS_NAME
        proxied = $false
        ttl     = 1
        type    = "A"
    } | ConvertTo-Json

    $uri = "https://api.cloudflare.com/client/v4/zones/$CLOUDFLARE_ZONE_ID/dns_records/$($record.DNS_RECORD_ID)"
    Write-Output "Updating DNS record: $($record.DNS_NAME) ($($record.DNS_RECORD_ID))"
    Invoke-RestMethod -Uri $uri -Method Put -Headers $headers -Body $payload
}

Write-Output "Done. All Cloudflare DNS records have been updated."
```
