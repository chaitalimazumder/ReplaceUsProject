#!/bin/bash
set -e

echo "=== Auto File Creation + Deployment Script ==="

# -----------------------------------------------
# CONFIG
# -----------------------------------------------
PROMPT_JSON="metadata-output/prompt-response.json"
ORG_ALIAS="ciOrg"

# -----------------------------------------------
# VALIDATION
# -----------------------------------------------
if [ ! -f "$PROMPT_JSON" ]; then
  echo "Prompt response JSON not found at: $PROMPT_JSON"
  exit 1
fi

if ! command -v jq &> /dev/null; then
  echo "jq is required but not installed"
  exit 1
fi

# -----------------------------------------------
# PARSE JSON
# -----------------------------------------------
echo "=== Reading Prompt Template JSON ==="
files=$(jq -c '.files[]' "$PROMPT_JSON")

# -----------------------------------------------
# CREATE FILES + TRACK DEPLOY DIRS
# -----------------------------------------------
echo "=== Creating Metadata Files ==="

DEPLOY_DIRS=()

while IFS= read -r file; do
  path=$(echo "$file" | jq -r '.path')
  content=$(echo "$file" | jq -r '.content')

  dir=$(dirname "$path")
  mkdir -p "$dir"

  echo "$content" > "$path"
  echo "✔ Created: $path"

  # Track parent folder (IMPORTANT for Salesforce)
  DEPLOY_DIRS+=("$dir")
done <<< "$files"

# -----------------------------------------------
# REMOVE DUPLICATE DIRS
# -----------------------------------------------
DEPLOY_DIRS=($(printf "%s\n" "${DEPLOY_DIRS[@]}" | sort -u))

# -----------------------------------------------
# DEPLOY ONLY GENERATED METADATA
# -----------------------------------------------
echo "=== Deploying ONLY Generated Metadata ==="

DEPLOY_CMD="sf project deploy start --target-org $ORG_ALIAS"

for dir in "${DEPLOY_DIRS[@]}"; do
  DEPLOY_CMD="$DEPLOY_CMD --source-dir $dir"
done

echo "Running: $DEPLOY_CMD"
eval "$DEPLOY_CMD"

echo "=== DONE: Deployment Successful ==="
