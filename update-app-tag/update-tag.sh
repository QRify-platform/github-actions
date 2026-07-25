# Usage: update-tag.sh <new-tag> <values.yaml path>

set -e

NEW_TAG=$1
VALUES_FILE=$2

echo "🔧 Updating $VALUES_FILE with imageTag=$NEW_TAG"

# Always quote — tags like 650959e5 are valid YAML floats (6.50959e+10) if bare.
sed -i.bak -E "s/(imageTag:[[:space:]]*).*/\1\"${NEW_TAG}\"/" "$VALUES_FILE"

echo "✅ Updated:"
grep "imageTag:" "$VALUES_FILE"
