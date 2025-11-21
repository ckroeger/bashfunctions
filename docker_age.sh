#!/bin/bash

# Konstanten
#readonly REGISTRY="registry-1.docker.io"
readonly REGISTRY="mirror.gcr.io"

# Funktion: Ruft das Erstellungsdatum eines Docker-Images von Docker Hub ab.
# Nutzung: get_docker_image_age <image_name> [tag]
get_docker_image_age() {
    # ... [Ihr kompletter Code der Funktion, wie zuvor definiert] ...
    if ! command -v curl &> /dev/null || ! command -v jq &> /dev/null; then
        echo "ERROR: This function requires 'curl' and 'jq'. Please install them." >&2
        return 1
    fi

    # Standardwert für Tag ist 'latest'
    if [ "$#" -eq 0 ] || [ "$#" -gt 2 ]; then
        echo "ERROR: Please specify at least the image name." >&2
        echo "Usage: get_docker_image_age <image_name> [tag]" >&2
        return 1
    fi

    local IMAGE_NAME="$1"
    local IMAGE_TAG="${2:-latest}"
    local REGISTRY="registry-1.docker.io"

    echo "▶️ Trying to fetch age of $IMAGE_NAME:$IMAGE_TAG..."

    # 1. Manifest abrufen und Konfigurations-Digest extrahieren
    local ACCEPT="application/vnd.oci.image.index.v1+json, application/vnd.docker.distribution.manifest.list.v2+json, application/vnd.docker.distribution.manifest.v2+json"
    echo "   🔍 Fetching manifest list for $IMAGE_NAME:$IMAGE_TAG ..."
    local MANIFEST_LIST=$(curl -s "https://${REGISTRY}/v2/${IMAGE_NAME}/manifests/${IMAGE_TAG}" -H "Accept: ${ACCEPT}")

    # Digest für amd64 extrahieren
    local AMD64_DIGEST=$(echo "$MANIFEST_LIST" | jq -r '.manifests[] | select(.platform.architecture=="amd64") | .digest' | head -n1)
    if [ -z "$AMD64_DIGEST" ] || [ "$AMD64_DIGEST" == "null" ]; then
        echo "❌ ERROR: Could not find a matching digest for amd64." >&2
        return 1
    fi
    echo "   ✅ Digest for amd64: $AMD64_DIGEST"

    # Hole das Image-Manifest für diesen Digest
    local IMAGE_MANIFEST=$(curl -s "https://${REGISTRY}/v2/${IMAGE_NAME}/manifests/${AMD64_DIGEST}" -H "Accept: application/vnd.oci.image.manifest.v1+json, application/vnd.docker.distribution.manifest.v2+json")
    
    # debug IMAGE_MANIFEST with jq
    # echo "   🐳 IMAGE_MANIFEST: $(echo "$IMAGE_MANIFEST" | jq '.') "

    # search any attribute-name ends with "created"
    # jq -r 'paths(scalars) as $p | select($p[-1] | test("created$")) | getpath($p)' <<< "$IMAGE_MANIFEST"
    
    # Hole das Config-Blob und extrahiere das Erstellungsdatum
    local CREATION_DATE=$(jq -r 'paths(scalars) as $p | select($p[-1] | test("created$")) | getpath($p)' <<< "$IMAGE_MANIFEST")
    if [ -z "$CREATION_DATE" ] || [ "$CREATION_DATE" == "null" ]; then
        echo "❌ ERROR: Could not retrieve creation date." >&2
        echo "🐳 IMAGE_MANIFEST: $(echo "$IMAGE_MANIFEST" | jq '.') "
        return 1
    fi

    echo "✨ The image $IMAGE_NAME:$IMAGE_TAG was created at: $CREATION_DATE"
    
    # Berechne das Alter in Tagen
    local CREATED_EPOCH=$(date -d "$CREATION_DATE" +%s 2>/dev/null || date -j -f "%Y-%m-%dT%H:%M:%S" "$CREATION_DATE" +%s 2>/dev/null)
    local NOW_EPOCH=$(date +%s)
    local AGE_SECONDS=$((NOW_EPOCH - CREATED_EPOCH))
    local AGE_DAYS=$((AGE_SECONDS / 86400))
    
    if [ $AGE_DAYS -lt 30 ]; then
        echo "📅 Age: $AGE_DAYS days"
    else
        local AGE_MONTHS=$((AGE_DAYS / 30))
        local REMAINING_DAYS=$((AGE_DAYS % 30))
        echo "📅 Age: $AGE_MONTHS month(s) and $REMAINING_DAYS days"
    fi
    return 0
}