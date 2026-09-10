# frontend-perf

> 没有测量就没有优化。动手前先能说出三件事：哪个指标坏了、现在是多少、时间花在哪。

## 它解决什么问题

性能优化是最容易靠直觉跑偏的一类工作。典型翻车：

- 还没 profile 就给整个代码库铺 `useMemo` / `React.memo`，而真正慢的原因是别的地方。
- 为了让 Lighthouse 分数好看去优化，而真实用户的瓶颈完全在另一处。
- 把一个 4KB 的依赖换掉，而 LCP 的 3MB 大图原封不动。

「感觉有点慢」不是结论，跟「Lighthouse 说 71 分」一样不是。

## 什么时候会触发

页面卡、包体积变大、LCP/INP 回退、上线性能敏感改动之前。

## 核心规则

### 先测量，再动手

动手前必须能说出：**哪个指标坏**（LCP / INP / CLS / TTFB / 包体积 / 某个具体交互）、**当前数字**、**时间花在哪**（trace、火焰图或打包报告里的头号元凶）。

**字段数据**（RUM、`web-vitals` 上报、CrUX）反映用户真实体验；**实验室数据**（Lighthouse、Performance 面板）解释原因。两者冲突时信任字段数据，用实验室数据去解释它。

Lighthouse 分数每次跑都有波动——**跑三次取中位数**，不要拿单次分数当依据。

警戒线：LCP < 2.5s，INP < 200ms，CLS < 0.1；单路由初始 JS 大约 170KB gzip 是个提醒线，不是法律。

### 按指标分头排查

**LCP** —— 先确定 LCP 元素是什么，修法完全取决于它是图片、文字还是被阻塞的渲染：

- 图片：正确尺寸和格式（AVIF/WebP）、hero 图加 `fetchpriority="high"` 并 preload、**首屏永远不要懒加载**。
- 文字：字体阻塞 → `font-display: swap`、自托管、子集化、只 preload 实际用到的那一个字重。
- 阻塞渲染的工作：关键 CSS 内联、非关键 CSS 延后、JS 拆包并 defer、第三方脚本等主内容之后再加载。

**INP** —— 通常源于超过 50ms 的长任务：

- 在 Performance 面板或 `PerformanceObserver` 的 `longtask` 里找到它们。
- 拆分长任务：`await scheduler.yield()` 让出主线程，或用 `setTimeout` 分片。
- 减少渲染量：把 state 放到真正用到它的组件里（一次按键不要重渲染整棵树）、把非紧急更新放进 `startTransition`。
- **只有在 DOM 节点数确实是测量出来的瓶颈时才上虚拟列表**，不要默认上。
- `useMemo` / `memo` 只加在 profile 显示重渲染确实昂贵的地方。**大面积 memo 化本身有成本，还会掩盖真正的问题。**

**CLS** —— 在内容到达之前把位置留出来：

- 所有图片和嵌入内容都设 `width`/`height` 或 `aspect-ratio`。
- 永远不要在已有内容上方插入横幅、广告或通知。
- 字体替换导致位移 → 用带 `size-adjust` 的度量兼容回退字体，或者 preload。

### 包体积：先量再砍

```bash
npx vite build && npx vite-bundle-visualizer        # Vite
npx next build                                       # 逐路由表格
npx webpack --profile --json | npx webpack-bundle-analyzer
npx source-map-explorer 'dist/assets/*.js'
npm ls <package>                                     # 有没有装了两份
```

按收益排序的常见做法：从具体模块导入而不是从 barrel 文件导入；用平台能力换掉重依赖（`moment` → `Intl`/`Temporal`）；把首屏之下的东西动态导入（弹窗、编辑器、图表、后台页）；砍掉目标浏览器不需要的 polyfill；**检查同一个库是否存在两个不同版本**（很常见）；生产环境不发 source map。

### 把它保持成一个循环

基线数字 → **只改一处** → 用同样的方法重测 → 保留或回退。一次改多处就无法归因。没有推动数字的改动要回退，哪怕它看起来是好实践。

## 怎么算做完了

报告**改动前后的数字**和**测量方法**。没能测量，就说这次改动未经测量验证，不要暗示它优化了性能。

## 什么情况下别用它

后端、数据库性能不在范围内。前端里如果问题是「这个交互写错了」，那属于 bug 而不是性能优化——先把测量做出来再判断。

## 怎么改成适合你的

- 把 2.5s / 200ms / 0.1 / 170KB 换成你们产品的目标（已上线的成熟产品往往该比这更严）。
- 如果你们有固定的性能预算工具（Lighthouse CI、bundlesize、Size Limit），把命令替换成你们真实在跑的那条，并把「改完要跑一遍」写进验收标准。
