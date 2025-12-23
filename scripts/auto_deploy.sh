#!/bin/bash
set -e

echo "=== Testing Auto File Creation + Deployment Script ==="

# -----------------------------------------------
# HARD-CODED SAMPLE RESPONSE (SIMULATING AI OUTPUT)
# -----------------------------------------------
hardcoded_response='
{
  "files": [
    {
      "path": "force-app/main/default/objects/Customer2__c/Customer2__c.object-meta.xml",
      "content": "<CustomObject xmlns=\"http://soap.sforce.com/2006/04/metadata\"><label>Customer2</label><pluralLabel>Customers2</pluralLabel><nameField><type>Text</type><label>Customer2 Name</label></nameField><deploymentStatus>Deployed</deploymentStatus><sharingModel>ReadWrite</sharingModel></CustomObject>"
    },
    {
      "path": "force-app/main/default/objects/Customer2__c/fields/Phone__c.field-meta.xml",
      "content": "<CustomField xmlns=\"http://soap.sforce.com/2006/04/metadata\"><fullName>Phone__c</fullName><label>Phone</label><type>Phone</type></CustomField>"
    }
  ]
}
'

echo "=== Parsing Hardcoded JSON ==="

# Convert string to JSON using jq
files=$(echo "$hardcoded_response" | jq -c '.files[]')

# -----------------------------------------------
# CREATE FILES
# -----------------------------------------------
echo "=== Creating Metadata Files ==="

while IFS= read -r file; do
  path=$(echo "$file" | jq -r '.path')
  content=$(echo "$file" | jq -r '.content')

  dir=$(dirname "$path")
  mkdir -p "$dir"

  echo "$content" > "$path"

  echo "Created: $path"
done <<< "$files"

# -----------------------------------------------
# DEPLOY TO SALESFORCE
# -----------------------------------------------
echo "=== Deploying to Salesforce ==="

sf project deploy start --target-org vscodeOrg --ignore-conflicts

echo "=== DONE: Files Created and Deployment Triggered ==="


# '
# {
#   "files": [
#     {
#       "path": "force-app/main/default/objects/Customer1__c/Customer1__c.object-meta.xml",
#       "content": "<CustomObject xmlns=\"http://soap.sforce.com/2006/04/metadata\"><label>Customer1</label><pluralLabel>Customers1</pluralLabel><nameField><type>Text</type><label>Customer1 Name</label></nameField><deploymentStatus>Deployed</deploymentStatus><sharingModel>ReadWrite</sharingModel></CustomObject>"
#     },
#     {
#       "path": "force-app/main/default/objects/Customer1__c/fields/Phone__c.field-meta.xml",
#       "content": "<CustomField xmlns=\"http://soap.sforce.com/2006/04/metadata\"><fullName>Phone__c</fullName><label>Phone</label><type>Phone</type></CustomField>"
#     },
#     {
#       "path": "force-app/main/default/classes/Customer1Helper.cls",
#       "content": "public class Customer1Helper { public static void hello() { System.debug(\"Hello Customer\"); } }"
#     },
#     {
#       "path": "force-app/main/default/classes/Customer1Helper.cls-meta.xml",
#       "content": "<ApexClass xmlns=\"http://soap.sforce.com/2006/04/metadata\"><apiVersion>60.0</apiVersion><status>Active</status></ApexClass>"
#     }
#   ]
# }
# '
