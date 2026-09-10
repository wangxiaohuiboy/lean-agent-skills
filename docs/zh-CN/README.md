# 中文文档

这七个 skill 的 `SKILL.md` 正文是英文，人读的文档是中文。这个分工是刻意的：

- **正文给模型读。**它只在 skill 被激活时加载，英文在同等信息量下 token 更省，而省 token 正是这个仓库的主题之一。
- **文档给人读。**用来判断这个 skill 值不值得装、它到底会改变什么行为、以及怎么改成适合你自己团队的版本。
- **不逐句翻译正文。**正文会随实践修改，逐句翻译的副本一定会过期，而且会让人误以为「读翻译等于读原文」。这里的每篇文档讲的是**为什么这么写、什么时候不适用、怎么改**，不是对照译文。

## 索引

### 省 token 的一组

| Skill | 中文文档 | 一句话 |
| --- | --- | --- |
| `lean-context` | [lean-context.md](lean-context.md) | 每次读文件前先能说清要回答什么问题，能搜就不读 |
| `lean-diff` | [lean-diff.md](lean-diff.md) | 七级解法阶梯，但前提是先把问题搞懂 |
| `lean-answer` | [lean-answer.md](lean-answer.md) | 先给答案，砍掉开场白和收尾复述 |
| `context-handoff` | [context-handoff.md](context-handoff.md) | 把长会话压成一页能续接的简报 |

### 前端的一组

| Skill | 中文文档 | 一句话 |
| --- | --- | --- |
| `frontend-craft` | [frontend-craft.md](frontend-craft.md) | 写结构之前先做设计决策，避开「一眼 AI」的默认长相 |
| `frontend-perf` | [frontend-perf.md](frontend-perf.md) | 先测量再动手，一次只改一处 |
| `frontend-a11y` | [frontend-a11y.md](frontend-a11y.md) | 按优先级排好的 WCAG 2.2 AA 检查，键盘走查排第一 |

## 想改成中文正文？

可以，把 `SKILL.md` 的正文翻成中文即可，模型照样能读。两个代价要知道：

1. **同等信息量下，中文正文的 token 开销通常高于英文。**中文每个字携带的信息多，但分词后占用的 token 数并不便宜。如果你装这个 skill 本来就是为了省 token，改中文正文是在往反方向走。
2. **正文和上游会脱节。**这个仓库的正文会随实践继续改，本地翻一份中文就等于自己维护一个分叉。

如果你的目的是「让模型用中文回我」，不需要改正文：`lean-answer` 里已经写了跟随用户语言，其余 skill 输出的报告也跟随对话语言。要调整的只是正文里的示例文案。

## 怎么改才不容易出事

- **改「不省」清单，别改阶梯。**`lean-diff` 里的七级阶梯是通用判断顺序；真正该按团队调整的是那份「永远不省」的清单（你们特别在意的校验、审计日志、权限边界）。
- **改数值，别改结构。**`frontend-perf` 的 2.5s / 200ms / 0.1 和 170KB 是行业默认警戒线，按你们的产品改；`frontend-craft` 的 token 值同理。
- **改完跑一次验证。**`python3 scripts/validate_skills.py` 会检查 frontmatter、命名和文档里引用的文件是否存在。

## 相关

- [English README](../../README.md)
- [中文 README](../../README.zh-CN.md)
- [Ponytail](https://github.com/DietrichGebert/ponytail) — 解法阶梯这个思路的来源
