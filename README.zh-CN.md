# lean-agent-skills

七个给 AI 编程助手用的 skill：既省钱，也管出活的质量。

四个用来压低一次编码会话的成本——读的上下文更少、写的代码更少、回复的字更少、交接时带的包袱更少。另外三个是前端方向的：让界面摆脱「一眼 AI」的模板感、真正测量并修掉性能瓶颈、通过一轮 WCAG AA 无障碍检查。

支持 Codex、Claude Code，以及任何读取 `SKILL.md` 的助手。每个 skill 在没被真正用到之前，只有一行简短描述占用上下文，所以七个全装上，闲着的时候几乎不花 token。

[English](README.md)

## 内容

### 省 token 的一组

| Skill | 做什么 | 什么时候触发 |
| --- | --- | --- |
| [`lean-context`](skills/lean-context) | 每次读文件之前先挂一个「要回答什么问题」，先搜后读、只读最窄的区间、独立查询合并成一批、绝不重复读 | 熟悉陌生代码库、追一个 bug、找一个符号 |
| [`lean-diff`](skills/lean-diff) | 七级解法阶梯（YAGNI → 复用 → 标准库 → 平台能力 → 已有依赖 → 一行 → 最小实现），bug 修根因不修症状，主动降级的方案必须标明上限 | 任何需要控制范围的开发、修 bug、重构 |
| [`lean-answer`](skills/lean-answer) | 结论先行、去掉开场白和收尾复述、给路径引用而不是贴代码、结构跟着内容走 | 你要简洁，或者连续问一堆小问题 |
| [`context-handoff`](skills/context-handoff) | 把长会话压缩成可续接的简报：目标、状态、决策、试过且失败的路、下一步动作、坑 | 换新对话前、上下文快满时、交接给别人时 |

### 前端的一组

| Skill | 做什么 | 什么时候触发 |
| --- | --- | --- |
| [`frontend-craft`](skills/frontend-craft) | 先把设计系统定下来再写结构；列出那些「看着就像生成的」反模式；覆盖各种状态、动效、窄屏布局。附一份可直接用的 `tokens.css` | 新建或改造页面 / 组件 |
| [`frontend-perf`](skills/frontend-perf) | 先测量再动手，围绕 LCP、INP、CLS 和包体积排查，给出每个指标对应的具体修法 | 页面卡、包变大、指标回退 |
| [`frontend-a11y`](skills/frontend-a11y) | 按优先级排序的 WCAG 2.2 AA 检查：键盘、语义、名称、焦点、表单、对比度、动效、实时区域 | 上线 UI、review 组件、有人反馈用不了 |

## 安装

### Codex

```bash
git clone https://github.com/wangxiaohuiboy/lean-agent-skills
./lean-agent-skills/scripts/install.sh --target codex
```

会把每个 skill 拷贝到 `${CODEX_HOME:-~/.codex}/skills/`。遇到同名 skill 会带上时间戳挪到一边，不会直接删。加 `--link` 改成软链接，这样改 clone 里的文件会立刻生效。装完重启会话。

### Claude Code

```bash
./lean-agent-skills/scripts/install.sh --target claude
```

拷贝到 `~/.claude/skills/`，`--link` 同理。

### 其他助手

把 skill 目录拷到你的助手会扫描的位置，或者直接把 `SKILL.md` 的正文粘进规则文件。这些就是普通的 Markdown，带 `name` 和 `description` 两行 frontmatter，`references/` 里的文件只在 skill 明确需要时才读取。

## 设计取舍

Skill 是助手按需加载的指令，所以标准跟一条好的代码 review 意见一样：只说那些不显然的，砍掉那些废话。

- **不写正确但没用的话。**「写出干净的代码」「记得测试」不会改变任何决策。这里每一条都带具体触发条件、具体例外或具体数字。
- **该反对就反对。**`lean-diff` 会告诉你什么时候不该省，`frontend-perf` 会告诉你什么时候加 `memo` 是错的。只会点头的 skill 没有价值。
- **成本按使用量摊。**名字和描述在选择阶段可见，正文只在激活时加载，更细的分支说明放在 `references/` 里按需读取。
**激活成本很小。**每个正文在激活时大约 700-1250 token，不激活时为零。更细的分支说明放在 `references/`，只有走到那个分支才会读。
- **例外写清楚。**信任边界上的输入校验、防止数据丢失的错误处理、安全、无障碍、真实硬件的行为，这些永远不是省 token 省掉的对象。

### 致谢

解法阶梯、以及「主动降级必须标注上限」这两个思路，改编自 Dietrich Gebert 的 [Ponytail](https://github.com/DietrichGebert/ponytail)（MIT），它把「懒高级工程师」这个框架讲透了。这里的四个省 token skill 把那个思路重新按 token 的实际去向拆开——读进来的上下文、写出去的代码、返回的文字、带走的会话状态——前端那三个是独立的一组。

## 贡献

一个 skill 只有能改变决策才配存在。如果某条规则不会改变助手的行为，它该待在 README 里，而不是 skill 里。

## License

MIT，见 [LICENSE](LICENSE)。
