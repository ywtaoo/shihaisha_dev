# 支配者 (shihaisha_dev)

Cross-project dev automation orchestrator. Manages backlogs, runs coding agents, and keeps projects moving — while you just review.

```
shihaisha_dev (this repo)
    │
    │  GitHub API (cross-repo)
    │
    ├── trading_disciplinerr
    ├── project-b
    └── project-c
```

Each managed project stays clean. All orchestration logic lives here.

---

## How It Works

1. You create issues in any managed project and label them `status:ready` or `status:needs-spec`
2. Scheduled workflows in this repo pick them up automatically
3. A Claude Code agent implements, analyzes, or reviews — then opens a PR
4. You review and merge

---

## Workflows

| Workflow | Trigger | What it does |
|---|---|---|
| `process-ready-issues` | Weekdays 9am UTC | Picks up `status:ready` issues, implements them, opens PRs |
| `analyze-unclear-issues` | Wednesdays 10am UTC | Analyzes `status:needs-spec` issues, comments with proposals |
| `daily-digest` | Weekdays 8am UTC | Posts a status summary issue: ready/in-progress/open PRs |
| `setup-project` | Manual | Syncs labels and issue templates to a new project |

All workflows can also be triggered manually via `workflow_dispatch`.

---

## Project Registry

Managed projects are declared in [`projects.yml`](./projects.yml). Each entry controls:

```yaml
- repo: owner/repo
  tech_stack: typescript
  auto_implement: true    # process ready issues
  auto_analyze: true      # analyze needs-spec issues
  auto_review: true       # auto review PRs
  schedule:
    implement: "0 9 * * 1-5"
    analyze: "0 10 * * 3"
```

---

## Label System

Labels are defined once in `projects.yml` and synced to all managed repos.

| Label | Meaning |
|---|---|
| `status:ready` | Well-defined, agent can execute |
| `status:needs-spec` | Needs analysis before implementation |
| `status:in-progress` | Agent is working on it |
| `type:bug` / `type:feature` / `type:improvement` / `type:idea` | Issue type |
| `priority:high` / `priority:low` | Priority |

---

## Adding a New Project

```bash
# 1. Add entry to projects.yml

# 2. Sync labels and issue templates
./scripts/setup-project.sh owner/new-repo

# 3. Add CLAUDE.md to the new repo with project-specific guidelines
```

Or trigger the `setup-project` workflow manually from GitHub Actions.

---

## Required Secrets

Set these in this repo's Settings → Secrets:

| Secret | Purpose |
|---|---|
| `ANTHROPIC_API_KEY` | Claude API access for coding agents |
| `GH_PAT` | Personal Access Token with cross-repo read/write access |

---

## Daily Workflow

**Anytime (30 seconds):**
```bash
gh issue create --repo owner/project \
  --title "idea: some feature" \
  --label "type:idea,status:needs-spec"
```

**Daily (~5 min):** Check the digest issue → review open PRs → approve or comment.

**Weekly (~20 min):** Read agent analysis on `needs-spec` issues → confirm approach → flip label to `status:ready`.
