#!/bin/bash

set -uo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'
REVERSE='\033[7m'

for cmd in aws jq; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "Error: '$cmd' is required but not installed." >&2
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

declare -a SELECTED=()
for ((i=0; i<TOTAL; i++)); do
    SELECTED[$i]=0
done

CURSOR=0

draw_menu() {
    tput clear
    echo -e "${BOLD}AWS API Gateway Manager${NC}  region: ${CYAN}${REGION}${NC}"
    echo ""
    echo -e "${BOLD}Controls:${NC} [↑/↓] Navigate   [Space] Toggle select   [Enter] Delete selected   [q] Quit"
    echo ""
    printf "${BOLD}%-5s %-22s %-38s %-10s %-12s${NC}\n" "Sel" "API ID" "Name" "Type" "Created"
    printf '%s\n' "$(printf '%.0s─' {1..92})"

    for ((i=0; i<TOTAL; i++)); do
        if [ "${SELECTED[$i]}" -eq 1 ]; then
            mark="[x]"
        else
            mark="[ ]"
        fi

        line=$(printf "%-5s %-22s %-38s %-10s %-12s" "$mark" "${API_IDS[$i]}" "${API_NAMES[$i]}" "${API_TYPES[$i]}" "${API_CREATED[$i]}")

        if [ "$i" -eq "$CURSOR" ] && [ "${SELECTED[$i]}" -eq 1 ]; then
            echo -e "${REVERSE}${RED}${line}${NC}"
        elif [ "$i" -eq "$CURSOR" ]; then
            echo -e "${REVERSE}${line}${NC}"
        elif [ "${SELECTED[$i]}" -eq 1 ]; then
            echo -e "${RED}${line}${NC}"
        else
            echo "$line"
        fi
    done

    echo ""
    SELECTED_COUNT=0
    for v in "${SELECTED[@]}"; do [ "$v" -eq 1 ] && ((SELECTED_COUNT++)) || true; done
    echo -e "Selected: ${YELLOW}${SELECTED_COUNT}${NC} of ${TOTAL} APIs"
}

read_key() {
    IFS= read -rsn1 key
    if [[ "$key" == $'\x1b' ]]; then
        read -rsn2 -t 0.1 rest || true
        key="${key}${rest}"
    fi
    printf '%s' "$key"
}

while true; do
    draw_menu
    key=$(read_key)

    case "$key" in
        $'\x1b[A')
            [ "$CURSOR" -gt 0 ] && ((CURSOR--)) || true
            ;;
        $'\x1b[B')
            [ "$CURSOR" -lt $((TOTAL-1)) ] && ((CURSOR++)) || true
            ;;
        ' ')
            if [ "${SELECTED[$CURSOR]}" -eq 0 ]; then
                SELECTED[$CURSOR]=1
            else
                SELECTED[$CURSOR]=0
            fi
            ;;
        '')
            SELECTED_COUNT=0
            for v in "${SELECTED[@]}"; do [ "$v" -eq 1 ] && ((SELECTED_COUNT++)) || true; done

            if [ "$SELECTED_COUNT" -eq 0 ]; then
                tput clear
                echo "No APIs selected. Exiting."
                exit 0
            fi

            tput clear
            echo -e "${RED}${BOLD}The following APIs will be PERMANENTLY DELETED:${NC}"
            echo ""
            for ((i=0; i<TOTAL; i++)); do
                if [ "${SELECTED[$i]}" -eq 1 ]; then
                    echo -e "  - ${BOLD}${API_NAMES[$i]}${NC}  (${API_IDS[$i]})  [${API_TYPES[$i]}]"
                fi
            done
            echo ""
            echo -n "Type 'yes' to confirm deletion: "
            read -r confirm

            if [ "$confirm" != "yes" ]; then
                echo "Cancelled. No APIs were deleted."
                exit 0
            fi

            echo ""
            for ((i=0; i<TOTAL; i++)); do
                if [ "${SELECTED[$i]}" -eq 1 ]; then
                    id="${API_IDS[$i]}"
                    name="${API_NAMES[$i]}"
                    type="${API_TYPES[$i]}"
                    printf "  Deleting %-35s ... " "$name ($id)"
                    if [ "$type" == "REST" ]; then
                        aws apigateway delete-rest-api --rest-api-id "$id" \
                            && echo -e "${GREEN}done${NC}" || echo -e "${RED}failed${NC}"
                    else
                        aws apigatewayv2 delete-api --api-id "$id" \
                            && echo -e "${GREEN}done${NC}" || echo -e "${RED}failed${NC}"
                    fi
                fi
            done
            echo ""
            echo "Done."
            exit 0
            ;;
        'q'|'Q')
            tput clear
            echo "Exiting. No changes made."
            exit 0
            ;;
    esac
done
