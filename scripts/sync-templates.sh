#!/bin/bash
# Usage: ./scripts/sync-templates.sh [owner/repo]
# Syncs issue templates from templates/ to all managed repos (or a specific one).

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
TARGET=$1

REPOS=$(python3 -c "
import yaml
with open('$ROOT_DIR/projects.yml') as f:
    projects = yaml.safe_load(f)['projects']
target = '$TARGET'
for p in projects:
    if not target or p['repo'] == target:
        print(p['repo'])
")

for REPO in $REPOS; do
  echo "📄 Syncing issue templates to $REPO..."
  for TEMPLATE in bug_report feature_request quick_idea; do
    CONTENT=$(base64 -i "$ROOT_DIR/templates/${TEMPLATE}.md")
    gh api "repos/$REPO/contents/.github/ISSUE_TEMPLATE/${TEMPLATE}.md" \
      --method PUT \
      --field message="chore: sync ${TEMPLATE} issue template from orchestrator" \
      --field content="$CONTENT" \
      > /dev/null 2>&1 && echo "  ✅ $TEMPLATE" || echo "  ⚠️  $TEMPLATE (skipped)"
  done
  echo ""
done

echo "Done."
