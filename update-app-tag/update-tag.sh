# Usage: update-tag.sh <new-tag> <values.yaml path>

set -e

NEW_TAG=$1
VALUES_FILE=$2

echo "🔧 Updating $VALUES_FILE with imageTag=$NEW_TAG"


sed -i.bak -E "s/(imageTag: ).*/\1$NEW_TAG/" "$VALUES_FILE"

echo "✅ Updated:"
grep "imageTag:" "$VALUES_FILE"
