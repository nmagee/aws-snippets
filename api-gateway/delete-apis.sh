#!/bin/bash

# This script lists your API Gateways and lets you select one or more at a time.
# It assumes you have the following CLI tools installed: aws jq fzf

set -uo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

for cmd in aws jq fzf; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "Error: '$cmd' is required but not installed." >&2
        [[ "$cmd" == "fzf" ]] && echo "  Install with: brew install fzf" >&2
        exit 1
    fi
done

REGION=$(aws configure get region 2>/dev/null || echo "us-east-1")
echo -e "Fetching API Gateways in region ${CYAN}${REGION}${NC}..."

REST_APIS=$(aws apigateway get-rest-apis --query 'items[*].[id,name,`REST`,createdDate]' --output json 2>/dev/null || echo "[]")
HTTP_APIS=$(aws apigatewayv2 get-apis --query 'Items[*].[ApiId,Name,ProtocolType,CreatedDate]' --output json 2>/dev/null || echo "[]")

declare -a API_IDS=()
declare -a API_NAMES=()
declare -a API_TYPES=()
declare -a API_CREATED=()

while IFS= read -r line; do
    id=$(echo "$line" | jq -r '.[0]')
    name=$(echo "$line" | jq -r '.[1]')
    type=$(echo "$line" | jq -r '.[2]')
    created_raw=$(echo "$line" | jq -r '.[3] // "unknown"')
    if [[ "$created_raw" =~ ^[0-9]+$ ]]; then
        created=$(date -r "$created_raw" +%Y-%m-%d 2>/dev/null || date -d "@$created_raw" +%Y-%m-%d 2>/dev/null || echo "$created_raw")
    else
        created=$(echo "$created_raw" | cut -c1-10)
    fi
    API_IDS+=("$id")
    API_NAMES+=("$name")
    API_TYPES+=("$type")
    API_CREATED+=("$created")
done < <({ echo "$REST_APIS" | jq -c '.[]'; echo "$HTTP_APIS" | jq -c '.[]'; } 2>/dev/null)

TOTAL=${#API_IDS[@]}

if [ "$TOTAL" -eq 0 ]; then
    echo "No API Gateways found in region ${REGION}."
    exit 0
fi

# Each entry is tab-separated: ID<TAB>TYPE<TAB>DISPLAY
# fzf shows only the DISPLAY field (--with-nth=3) but returns the full line,
# so we can parse ID and TYPE from the selection.
ENTRIES=()
for ((i=0; i<TOTAL; i++)); do
    display=$(printf '%-22s  %-38s  %-10s  %-12s' \
        "${API_IDS[$i]}" "${API_NAMES[$i]}" "${API_TYPES[$i]}" "${API_CREATED[$i]}")
    ENTRIES+=("${API_IDS[$i]}"$'\t'"${API_TYPES[$i]}"$'\t'"${display}")
done

FZF_HEADER="$(printf '  %-22s  %-38s  %-10s  %-12s' 'API ID' 'Name' 'Type' 'Created')
  TAB=select/deselect   ENTER=delete selected   ESC=quit"

SELECTED=$(printf '%s\n' "${ENTRIES[@]}" | \
    fzf --multi \
        --delimiter=$'\t' \
        --with-nth=3 \
        --header="${FZF_HEADER}" \
        --header-first \
        --prompt="Region: ${REGION} > " \
        --marker=">" \
        --border \
        --bind='tab:toggle+down') || true

if [ -z "$SELECTED" ]; then
    echo "No selection made. Exiting."
    exit 0
fi

declare -a DEL_IDS=()
declare -a DEL_NAMES=()
declare -a DEL_TYPES=()

while IFS=$'\t' read -r id type _; do
    DEL_IDS+=("$id")
    DEL_TYPES+=("$type")
    for ((i=0; i<TOTAL; i++)); do
        if [[ "${API_IDS[$i]}" == "$id" ]]; then
            DEL_NAMES+=("${API_NAMES[$i]}")
            break
        fi
    done
done <<< "$SELECTED"

echo ""
echo -e "${RED}${BOLD}The following APIs will be PERMANENTLY DELETED:${NC}"
echo ""
for ((i=0; i<${#DEL_IDS[@]}; i++)); do
    echo -e "  - ${BOLD}${DEL_NAMES[$i]}${NC}  (${DEL_IDS[$i]})  [${DEL_TYPES[$i]}]"
done
echo ""
echo -n "Type 'yes' to confirm deletion: "
read -r confirm

if [[ "$confirm" != "yes" ]]; then
    echo "Cancelled. No APIs were deleted."
    exit 0
fi

echo ""
for ((i=0; i<${#DEL_IDS[@]}; i++)); do
    id="${DEL_IDS[$i]}"
    name="${DEL_NAMES[$i]}"
    type="${DEL_TYPES[$i]}"
    printf "  Deleting %-35s ... " "$name ($id)"
    if [[ "$type" == "REST" ]]; then
        aws apigateway delete-rest-api --rest-api-id "$id" \
            && echo -e "${GREEN}done${NC}" || echo -e "${RED}failed${NC}"
    else
        aws apigatewayv2 delete-api --api-id "$id" \
            && echo -e "${GREEN}done${NC}" || echo -e "${RED}failed${NC}"
    fi
    if (( i < ${#DEL_IDS[@]} - 1 )); then
        echo "  Waiting 20s before next request..."
        sleep 20
    fi
done

echo ""
echo "Done."
