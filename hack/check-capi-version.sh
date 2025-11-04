set -o errexit
set -o nounset
set -o pipefail

# Get the directory of the script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

cd "${REPO_ROOT}"

# Extract the desired CAPI version from go.mod
DESIRED_VERSION=$(grep -E 'sigs.k8s.io/cluster-api v' go.mod | grep -v '/test' | awk '{print $2}')

if [[ -z "${DESIRED_VERSION}" ]]; then
    echo "❌ Could not find cluster-api version in go.mod"
    exit 1
fi

echo "✓ Desired CAPI version from go.mod: ${DESIRED_VERSION}"
echo ""

# Find all non-documentation files with cluster-api/clusterctl version mismatches
# Docs are excluded as they can contain example output that doesn't need to be in sync
if git ls-files | grep -v vendor | grep -v '\.md$' | xargs grep -nH -E '(cluster-api|clusterctl|capi_version)' 2>/dev/null | grep -E 'v1\.[0-9]+\.[0-9]+' | grep -v "${DESIRED_VERSION}"; then
    echo ""
    echo "❌ Version mismatches found! Expected: ${DESIRED_VERSION}"
    echo "Please update the mismatched files to use the version from go.mod"
    exit 1
fi

echo "✅ All CAPI versions are in sync with go.mod (${DESIRED_VERSION})"
