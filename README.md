# ProfileReplayer

Android 平板 App：回放 Decaid DE1 萃取的全点曲线。数据来自两个 Decaid 插件的导出——
[HyperEx Pulse Filter](https://github.com/ladiosupp/decenthyperexplugin)（它介入的杯）与
[Profile Recorder](https://github.com/ladiosupp/profilerecorder)（其余杯），按 runId 去重合并，源头不重叠。

## 功能

- 帧重放：顺放 / 倒放 / 暂停 / 逐帧 / 事件跳 / 变速 / 循环。
- 三张图：杯流（decaid 杯流 + RAW dW/dt）、秤重（秤重 + 插件累计）、压力（压力 + 机器流量 + 目标指令）。
- 取数三路：贴 Decaid 地址抓 / 自动抓（默认 2 分钟，后台前台服务也抓）/ 本地 JSON 导入。
- 双源抓取：HyperEx 导出 + recorder 导出（recorder 未装时静默跳过）。
- 选杯列表：时间 · 曲线标题 · 状态。HyperEx 杯显示 HyperEx Pulse Filter (auto/on/off)，recorder 杯显示记录的真实曲线名。
- 启动插件检测：经 Decaid /api/v1/plugins 查两支插件安装状态，缺任一支弹窗引导去 GitHub Release 安装；装齐不打扰。
- 归档存 IndexedDB，不设杯数上限；**150MB 体积门槛**到点提示压缩备份（gzip + 系统分享，可传夸克等网盘）或清理最旧一半。
- 后台累积：FetchService 每轮把两路导出合并进持久 buffer（最近 60 杯），几天不开 App 数据也不丢；回前台自动并入归档。
- 电池白名单检测：不在白名单显示警示条，一键跳系统设置。
- 中英文切换（持久化）。

## 安装

下载 Release 里的 `ProfileReplayer-vX.Y-debug.apk` 装到平板（与 Decaid 同机，取数走回环）。

## 构建

需 JDK 17 + Android SDK（compileSdk 34）+ Gradle 8.7。`local.properties` 里 `sdk.dir` 指向你的 SDK。

```
gradle -p . assembleDebug
```

改 `app/www/` 后必须 `Copy-Item app/www/* app/src/main/assets/www/` 再构建（assets 是打包来源）。

## 目录

- `app/www/`：网页源（app.js / index.html / archive-core.js）。
- `app/src/main/`：WebView 壳 + FetchService（后台双源抓）+ HxBridge（JS 桥，含 shareFile 分享）。
- `sim/`：PC 帧重放（server.js + public/replay.*，/replay 页与 /api/frame/* 只读接口）。
- `app/tools/`：tablet-connect.ps1（无线调试接入）/ tablet-sync.ps1（PC 轮询）/ tablet-pull-app-archive.js（取回 App 归档）。
- `sim/archive-core.js`：合并内核（与 PC 归档同口径，runId 去重、分量取最长）。

## 验证

`node sim/tests/archive-core-check.cjs`（合并内核 13 项）；`node sim/tests/frame-replay-check.cjs`（帧重放接口 18 项，需 sim 服务在 4780 跑）。

## License

PolyForm Noncommercial 1.0.0（见 LICENSE）。

