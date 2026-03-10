#!/bin/bash
# Usage: ./scripts/sync-labels.sh [owner/repo]
# Syncs labels from projects.yml to all managed repos (or a specific one).

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
  echo "📌 Syncing labels to $REPO..."
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
done

echo "Done."
