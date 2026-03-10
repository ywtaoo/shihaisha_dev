# Dev Orchestrator

跨项目自动化迭代框架。管理所有被编排项目的 workflows、prompts 和配置。

## 结构

- `projects.yml` — 注册的项目列表和 label 定义
- `prompts/` — 共享 agent 指令模板（implement, analyze-spec, review-pr, daily-digest）
- `templates/` — 共享 issue 模板（会同步到被管理项目）
- `scripts/` — 本地运行的辅助脚本
- `.github/workflows/` — 所有自动化 workflows

## 添加新项目

1. 在 `projects.yml` 的 `projects:` 下添加一条记录
2. 运行 `./scripts/setup-project.sh owner/new-repo`（或触发 `setup-project` workflow）
3. 在新项目中创建 `CLAUDE.md`

## Secrets（必须在此 repo 配置）

- `GH_PAT` — 有跨 repo 读写权限的 Personal Access Token
- `ANTHROPIC_API_KEY` — Claude API Key

## 日常操作

```bash
# 手动触发处理所有 ready issues
gh workflow run process-ready-issues.yml

# 只处理特定项目
gh workflow run process-ready-issues.yml -f target_repo=ywtaoo/disciplinerr

# 手动触发分析 needs-spec issues
gh workflow run analyze-unclear-issues.yml

# 为新项目初始化 labels 和模板
./scripts/setup-project.sh owner/new-repo
```

## Agent 注意事项

- 修改 `projects.yml` 时注意 YAML 格式
- `prompts/` 中的 `{{repo}}` 和 `{{issue}}` 是 workflow 运行时替换的占位符
- 不要在此 repo 放置被管理项目的业务代码
