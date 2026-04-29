# My Skills

这是一个个人 Codex skills 仓库，用来沉淀可复用的工作流、团队约定和常用自动化能力。

仓库仍在持续完善中。当前目标是先把高频、容易重复出错、适合标准化的开发流程整理成独立 skill，让 Codex 在触发对应任务时能够按固定规则执行。

## Skills

| Skill | 用途 | 典型触发场景 |
| --- | --- | --- |
| `git-commit` | 分析当前 git diff，按 Conventional Commits 生成提交信息并执行提交 | 用户要求提交代码、创建 commit，或使用 `/commit` |
| `developer-self-test-report` | 根据分支、提交、变更文件和需求信息生成英文开发自测报告 | 需要给 QA 或测试同事交付 developer self-test report |

## 目录结构

```text
.
├── developer-self-test-report/
│   └── SKILL.md
├── git-commit/
│   └── SKILL.md
└── README.md
```

每个 skill 以独立目录保存，目录名与 `SKILL.md` frontmatter 中的 `name` 保持一致。

## 使用方式

将需要启用的 skill 目录放到 Codex 可发现的 skills 目录中，例如：

```powershell
$skillsHome = "$env:USERPROFILE\.codex\skills"
New-Item -ItemType Directory -Force -Path $skillsHome
Copy-Item -Path .\git-commit, .\developer-self-test-report -Destination $skillsHome -Recurse -Force
```

如果希望仓库更新后立即生效，可以使用目录链接代替复制：

```powershell
$skillsHome = "$env:USERPROFILE\.codex\skills"
New-Item -ItemType Directory -Force -Path $skillsHome
New-Item -ItemType Junction -Path "$skillsHome\git-commit" -Target "$PWD\git-commit"
New-Item -ItemType Junction -Path "$skillsHome\developer-self-test-report" -Target "$PWD\developer-self-test-report"
```

安装后，在 Codex 中用自然语言描述任务即可触发对应 skill。例如：

```text
帮我提交当前修改
```

```text
根据当前分支生成 developer self-test report
```

## Skill 编写约定

- 每个 skill 必须包含 `SKILL.md`。
- `SKILL.md` frontmatter 必须包含 `name` 和 `description`。
- `description` 要写清楚 skill 的能力和触发场景，因为它是 Codex 判断是否启用 skill 的主要依据。
- `SKILL.md` 正文只保留执行任务必要的流程、规则和判断依据。
- 复杂资料放到 `references/`，可执行的稳定逻辑放到 `scripts/`，输出模板或素材放到 `assets/`。
- 不在单个 skill 目录中放 README、安装说明、变更日志等面向人的附加文档，避免增加触发后的上下文噪音。
- skill 名称使用小写字母、数字和连字符，例如 `developer-self-test-report`。

## 维护流程

新增或更新 skill 时，建议按这个顺序处理：

1. 明确 skill 要解决的具体任务和触发语句。
2. 编写或更新 `SKILL.md` 的 frontmatter，优先打磨 `description`。
3. 将稳定、重复、容易出错的步骤固化成明确 workflow。
4. 如果内容开始变长，把细节拆到 `references/`，让 `SKILL.md` 保持精简。
5. 用真实任务跑一遍，确认 Codex 会在正确场景触发，并且输出符合预期。

## 当前状态

这个仓库是个人工作流沉淀，不保证所有 skill 都适合通用场景。后续会根据实际使用继续调整触发描述、执行步骤和资源组织方式。
