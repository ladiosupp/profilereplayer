# ProfileReplayer PC 侧轮询：经 adb forward 抓平板 Decaid 导出 → 落盘 inbox。
# 合并进 PC 归档用 hx-archive.mjs（hyperex-history 技能）：node hx-archive.mjs add <inbox文件>。
# 用法（需提权跑）：.\tablet-sync.ps1            # 抓一次
#                   .\tablet-sync.ps1 -IntervalSec 120   # 每 2 分钟轮询，Ctrl+C 停
# 配置：同目录 tablet.json（tablet-connect.ps1 生成）；adb 路径可用 -Adb 覆盖。
param([int]$IntervalSec = 0, [string]$Inbox = (Join-Path $PSScriptRoot "inbox"), [string]$Adb = "adb")
$cfg = Get-Content -LiteralPath (Join-Path $PSScriptRoot "tablet.json") -Raw | ConvertFrom-Json
& $Adb connect $cfg.connect | Out-Null
& $Adb -s $cfg.connect forward tcp:$($cfg.localPort) tcp:$($cfg.decaidPort) | Out-Null
New-Item -ItemType Directory -Force -Path $Inbox | Out-Null
do {
  $ts = Get-Date -Format "yyyyMMdd-HHmmss"
  $file = Join-Path $Inbox "hyperex-history-tablet-$ts.json"
  try {
    Invoke-WebRequest -UseBasicParsing -NoProxy -TimeoutSec 60 "http://127.0.0.1:$($cfg.localPort)/api/v1/plugins/decenthyperexplugin.reaplugin/history-export" -OutFile $file
  } catch { "抓取失败：$_" }
  # recorder（非 HyperEx 杯）导出：404 表示未装，跳过
  $recFile = Join-Path $Inbox "profilerecorder-tablet-$ts.json"
  try {
    Invoke-WebRequest -UseBasicParsing -NoProxy -TimeoutSec 60 "http://127.0.0.1:$($cfg.localPort)/api/v1/plugins/profilerecorder.reaplugin/history-export" -OutFile $recFile
  } catch { Remove-Item -LiteralPath $recFile -ErrorAction SilentlyContinue }
  if ($IntervalSec -gt 0) { Start-Sleep -Seconds $IntervalSec }
} while ($IntervalSec -gt 0)

