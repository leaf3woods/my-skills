# My Skills

这是一个个人 Codex skills 仓库，用来沉淀可复用的工作流、团队约定和常用自动化能力。

仓库仍在持续完善中。当前目标是先把高频、容易重复出错、适合标准化的开发流程整理成独立 skill，让 Codex 在触发对应任务时能够按固定规则执行。

## Skills

| Skill | 用途 | 典型触发场景 |
| --- | --- | --- |
| `git-commit` | 分析当前 git diff，按可配置提交风格生成提交信息并执行提交；默认使用 Conventional Commits | 用户要求提交代码、创建 commit，或使用 `/commit`；也可以指定 simple、ticket-prefix、company 等风格 |
| `create-pr-submission` | 根据分支、提交、ticket 和模板生成或提交英文 PR；默认使用 company preset，也支持 personal preset | 需要创建 PR、整理 PR 描述、选择 reviewer，或在个人项目中生成轻量 PR |
| `codereview` | 直接读取本地 Git staged、unstaged、untracked 或指定 commit/range 的代码变更，只报告高置信度 critical 问题及修改方案 | 需要 code review、审查当前本地修改、当前分支、指定 commit/range 或选定源码文件 |
| `developer-self-test-report` | 根据分支、提交、变更文件和需求信息生成英文开发自测报告；默认使用 company QA handoff，也支持 smoke、regression、personal 模板 | 需要给 QA 或测试同事交付 developer self-test report，或生成不同粒度的自测说明 |
| `submit-software-inventory` | 在 Windows、macOS 或 Linux 盘点用户安装的软件，排除系统自带组件、驱动和依赖，并按飞书问卷字段逐条串行提交 | 需要提交公司软件清单、审计电脑安装的软件，或填写禁止并发写入的软件调查问卷 |
| `jira-sprint-card-intake` | 获取当前或下一 Jira 冲刺中分配给自己的卡片，生成卡片笔记、checkout 计划、标准跟踪文本、预判工作仓库和增量评论交接 | 开始 Jira 工作流、需要为冲刺卡片建立笔记，或需要把低 token 成本的卡片上下文交给下一个独立 skill |
| `aws-lambda-dev-deploy` | 只上传到 dev Lambda 的 `$LATEST`，备份原始 ZIP，等待用户测试，通过后还原线上包 | 用户要求在 dev 测试 staged Lambda 改动、避免触碰 alias/tag/staging/production，或需要 guarded update/restore |
| `windows-install` | Windows 软件安装总控，负责安装单个软件、选择模块、协调依赖和排序，再交给子模块执行 | 用户想安装某个软件、补装部分模块，或在重装后一次性安装 basic/work/development/drivers |
| `windows-install-basic` | 安装或核对字体、本地安装包、Typora、Obsidian 和基础应用 | 安装 Typora/Obsidian/字体/基础工具，不包含驱动/固件和微软自带应用 |
| `windows-install-drivers` | 审计或安装缺失/异常的 OEM、固件、芯片组、显卡、网卡、声卡、存储和显示器驱动 | 设备管理器异常、Dell/OEM 电脑需要驱动扫描，或用户明确要求检查驱动；默认不更新正常驱动 |
| `windows-install-work` | 安装或核对沟通、邮箱和远程工作工具 | 安装钉钉、微信、Slack、邮箱、Termius 等工作软件 |
| `windows-install-development` | 安装或核对开发工具链、Python、Miniconda、IDE、Windows Terminal、Oh My Posh、npm 全局包和 Visual Studio 扩展 | 安装 Git、GitHub CLI、AWS CLI、Python、Miniconda、VS Code、Cursor、DBeaver、Bruno、WSL 等开发环境；VS Code 扩展走同步，Visual Studio package 不由 skill 安装 |

## 目录结构

```text
.
├── aws-lambda-dev-deploy/
│   ├── SKILL.md
│   └── agents/
├── create-pr-submission/
│   ├── SKILL.md
│   ├── agents/
│   └── references/
│       ├── presets/
│       └── templates/
├── codereview/
│   ├── SKILL.md
│   ├── agents/
│   └── references/
├── developer-self-test-report/
│   ├── SKILL.md
│   ├── agents/
│   └── references/
│       ├── presets/
│       └── templates/
├── git-commit/
│   ├── SKILL.md
│   ├── agents/
│   └── references/
│       └── styles/
├── submit-software-inventory/
│   ├── SKILL.md
│   ├── agents/
│   ├── scripts/
│   └── references/
├── jira-workflow-suite/
│   └── jira-sprint-card-intake/
│       ├── SKILL.md
│       ├── agents/
│       ├── scripts/
│       └── references/
├── windows-install-suite/
│   ├── windows-install/
│   │   ├── SKILL.md
│   │   └── references/
│   ├── windows-install-basic/
│   │   ├── SKILL.md
│   │   └── references/
│   ├── windows-install-drivers/
│   │   ├── SKILL.md
│   │   └── references/
│   ├── windows-install-work/
│   │   ├── SKILL.md
│   │   └── references/
│   └── windows-install-development/
│       ├── SKILL.md
│       └── references/
└── README.md
```

每个 skill 以独立目录保存，目录名与 `SKILL.md` frontmatter 中的 `name` 保持一致。

`windows-install-suite/` 是仓库内的分组目录，不是单独 skill。启用时仍然要把其中每个 `windows-install*` 子目录分别复制或链接到 Codex skills 目录，让它们可以单独触发。

`jira-workflow-suite/` 同样是分组目录。启用时需要把其中每个 `jira-*` 子目录分别复制或链接到 Codex skills 目录，后续工作流步骤会继续添加为独立 skill。

## 使用方式

将需要启用的 skill 目录放到 Codex 可发现的 skills 目录中，例如：

```powershell
$skillsHome = "$env:USERPROFILE\.codex\skills"
New-Item -ItemType Directory -Force -Path $skillsHome
Copy-Item -Path .\git-commit, .\create-pr-submission, .\codereview, .\developer-self-test-report, .\submit-software-inventory, .\aws-lambda-dev-deploy -Destination $skillsHome -Recurse -Force
```

如果希望仓库更新后立即生效，可以使用目录链接代替复制：

```powershell
$skillsHome = "$env:USERPROFILE\.codex\skills"
New-Item -ItemType Directory -Force -Path $skillsHome
New-Item -ItemType Junction -Path "$skillsHome\git-commit" -Target "$PWD\git-commit"
New-Item -ItemType Junction -Path "$skillsHome\create-pr-submission" -Target "$PWD\create-pr-submission"
New-Item -ItemType Junction -Path "$skillsHome\codereview" -Target "$PWD\codereview"
New-Item -ItemType Junction -Path "$skillsHome\developer-self-test-report" -Target "$PWD\developer-self-test-report"
New-Item -ItemType Junction -Path "$skillsHome\submit-software-inventory" -Target "$PWD\submit-software-inventory"
New-Item -ItemType Junction -Path "$skillsHome\aws-lambda-dev-deploy" -Target "$PWD\aws-lambda-dev-deploy"
```

按需启用 Windows 安装类 skill：

```powershell
$skillsHome = "$env:USERPROFILE\.codex\skills"
$suite = Join-Path $PWD "windows-install-suite"
New-Item -ItemType Directory -Force -Path $skillsHome
New-Item -ItemType Junction -Path "$skillsHome\windows-install" -Target "$suite\windows-install"
New-Item -ItemType Junction -Path "$skillsHome\windows-install-basic" -Target "$suite\windows-install-basic"
New-Item -ItemType Junction -Path "$skillsHome\windows-install-drivers" -Target "$suite\windows-install-drivers"
New-Item -ItemType Junction -Path "$skillsHome\windows-install-work" -Target "$suite\windows-install-work"
New-Item -ItemType Junction -Path "$skillsHome\windows-install-development" -Target "$suite\windows-install-development"
```

按需启用 Jira 工作流类 skill：

```powershell
$skillsHome = "$env:USERPROFILE\.codex\skills"
$suite = Join-Path $PWD "jira-workflow-suite"
New-Item -ItemType Directory -Force -Path $skillsHome
New-Item -ItemType Junction -Path "$skillsHome\jira-sprint-card-intake" -Target "$suite\jira-sprint-card-intake"
```

安装后，在 Codex 中用自然语言描述任务即可触发对应 skill。例如：

```text
帮我提交当前修改
```

```text
用 git-commit 使用 simple 风格提交当前修改
```

```text
用 create-pr-submission 使用 company preset 生成 PR
```

```text
用 codereview 审查当前本地 Git 修改，只报告 critical issues
```

```text
根据当前分支生成 developer self-test report
```

```text
用 developer-self-test-report 使用 regression 模板生成自测报告
```

```text
用 submit-software-inventory 盘点这台电脑的软件并串行填写公司飞书问卷
```

```text
用 jira-sprint-card-intake 获取我当前冲刺的卡片并生成笔记和交接文件
```

```text
用 aws-lambda-dev-deploy 备份线上 Lambda，上传 staged 改动到 $LATEST 测试，通过后还原
```

```text
用 windows-install 安装 Typora
```

```text
用 windows-install 帮我选择模块并安装这台 Windows 电脑需要的软件
```

```text
用 windows-install-drivers 帮我单独检查驱动和固件
```

```text
用 windows-install-development 帮我安装开发环境
```

## Skill 编写约定

- 每个 skill 必须包含 `SKILL.md`。
- `SKILL.md` frontmatter 必须包含 `name` 和 `description`。
- `description` 要写清楚 skill 的能力和触发场景，因为它是 Codex 判断是否启用 skill 的主要依据。
- `SKILL.md` 正文只保留执行任务必要的流程、规则和判断依据。
- 团队和个人差异、reviewer 规则、ticket 规则、输出 section、提交风格等可变内容放到 `references/` 下的 `presets/`、`templates/` 或 `styles/`，`SKILL.md` 只说明默认选择和加载顺序。
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
