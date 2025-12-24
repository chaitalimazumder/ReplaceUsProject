#!/bin/bash
set -e

echo "=== Testing Auto File Creation + Deployment Script ==="

# -----------------------------------------------
# HARD-CODED SAMPLE RESPONSE
# -----------------------------------------------
hardcoded_response='
{
  "files": [
    {
      "path": "force-app/main/default/objects/Customer2__c/fields/TelePhone__c.field-meta.xml",
      "content": "<CustomField xmlns=\"http://soap.sforce.com/2006/04/metadata\"><fullName>TelePhone__c</fullName><label>TelePhone</label><type>Phone</type></CustomField>"
    }
  ]
}
'

echo "=== Parsing Hardcoded JSON ==="
files=$(echo "$hardcoded_response" | jq -c '.files[]')

# -----------------------------------------------
# CREATE FILES + TRACK THEM
# -----------------------------------------------
echo "=== Creating Metadata Files ==="

DEPLOY_PATHS=()

while IFS= read -r file; do
  path=$(echo "$file" | jq -r '.path')
  content=$(echo "$file" | jq -r '.content')

  dir=$(dirname "$path")
  mkdir -p "$dir"

  echo "$content" > "$path"
  DEPLOY_PATHS+=("$path")

  echo "Created: $path"
done <<< "$files"

# -----------------------------------------------
# DEPLOY ONLY CREATED FILES
# -----------------------------------------------
echo "=== Deploying ONLY newly created files ==="

sf project deploy start \
  --source-dir "${DEPLOY_PATHS[@]}" \
  --target-org ciOrg \
  --ignore-conflicts

echo "=== DONE: Only new files deployed ==="
