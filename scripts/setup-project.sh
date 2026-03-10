#!/bin/bash
# Usage: ./scripts/setup-project.sh owner/repo
# Syncs labels and issue templates to a target repo.

set -e

REPO=$1

if [ -z "$REPO" ]; then
  echo "Usage: $0 owner/repo"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

echo "Setting up $REPO..."
echo ""

# 1. Sync labels
echo "📌 Syncing labels..."
python3 -c "
import yaml, subprocess
with open('$ROOT_DIR/projects.yml') as f:
    labels = yaml.safe_load(f)['labels']
for label in labels:
    result = subprocess.run([
        'gh', 'label', 'create', label['name'],
        '--repo', '$REPO',
        '--color', label['color'],
        '--description', label['description'],
        '--force'
    ], capture_output=True, text=True)
    status = '✅' if result.returncode == 0 else '❌'
    print(f\"{status} {label['name']}\")
"

echo ""

# 2. Sync issue templates
echo "📄 Syncing issue templates..."
for TEMPLATE in bug_report feature_request quick_idea; do
  CONTENT=$(base64 -i "$ROOT_DIR/templates/${TEMPLATE}.md")
  gh api "repos/$REPO/contents/.github/ISSUE_TEMPLATE/${TEMPLATE}.md" \
    --method PUT \
    --field message="chore: add ${TEMPLATE} issue template from orchestrator" \
    --field content="$CONTENT" \
    > /dev/null 2>&1 && echo "✅ $TEMPLATE" || echo "⚠️  $TEMPLATE (skipped, may already exist)"
done

echo ""
echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "  1. Create CLAUDE.md in $REPO with project-specific guidelines"
echo "  2. Add $REPO to projects.yml in this orchestrator if not already there"
echo "  3. Ensure GH_PAT and ANTHROPIC_API_KEY secrets are set in the orchestrator repo"
