#Requires -Version 7.0
<#
.SYNOPSIS
    批量执行 vcpkg install，记录输出与退出码，可选全部成功后关机。

.EXAMPLE
    .\vcpkg-batch-install.ps1 fmt spdlog zlib

.EXAMPLE
    .\vcpkg-batch-install.ps1 -ListFile libs.txt -Triplet x64-windows-static -Shutdown

.NOTES
    -ListFile：UTF-8，一行一个库，空行和 # 开头行忽略；可与命令行库名混用并自动去重。
#>
[CmdletBinding(PositionalBinding = $false)]
param(
    [Parameter(Position = 0, ValueFromRemainingArguments = $true)][string[]]$Libraries = @(),
    [string]$ListFile,
    [string]$Triplet,
    [string]$VcpkgExe,
    [string]$LogPath,
    [string[]]$ExtraArgs = @(),
    [switch]$DryRun,
    [switch]$StopOnError,
    [switch]$Shutdown,
    [switch]$ShutdownAlways,
    [int]$ShutdownDelaySec = 60
)

$ErrorActionPreference = 'Stop'

# 组装库列表：命令行 + 文件，逗号/空格/分号分隔，去重
if ($ListFile) {
    if (-not (Test-Path -LiteralPath $ListFile)) { throw "找不到列表文件: $ListFile" }
    $Libraries += Get-Content -LiteralPath $ListFile -Encoding utf8 |
        ForEach-Object { $_.Trim() } |
        Where-Object { $_ -and -not $_.StartsWith('#') }
}
$Libraries = @(
    $Libraries | ForEach-Object { $_ -split '[\s,;]+' } | Where-Object { $_ } | Select-Object -Unique
)
if ($Libraries.Count -eq 0) { throw '没有指定库列表（位置参数、-Libraries 或 -ListFile）' }

if (-not $VcpkgExe) { $VcpkgExe = (Get-Command vcpkg -ErrorAction Stop).Source }

# 日志文件
if (-not $LogPath) { $LogPath = 'vcpkg-install-{0}.log' -f (Get-Date -Format 'yyyyMMdd-HHmmss') }
if (-not [IO.Path]::IsPathRooted($LogPath)) { $LogPath = Join-Path $PWD.Path $LogPath }
$logDir = Split-Path $LogPath -Parent
if ($logDir -and -not (Test-Path -LiteralPath $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}
New-Item -ItemType File -Path $LogPath -Force | Out-Null   # 每次运行覆盖旧日志

function Log([string]$Message) {
    Add-Content -LiteralPath $LogPath -Value $Message -Encoding utf8
    Write-Host $Message
}

Log ("vcpkg: {0}" -f $VcpkgExe)
Log ("libraries ({0}): {1}" -f $Libraries.Count, ($Libraries -join ', '))

# 逐个安装
$failed = @()
for ($i = 0; $i -lt $Libraries.Count; $i++) {
    $lib  = $Libraries[$i]
    $spec = if ($Triplet -and $lib -notmatch ':') { "${lib}:$Triplet" } else { $lib }
    $argv = @('install', $spec) + $ExtraArgs
    if ($DryRun) { $argv += '--dry-run' }

    Log ''
    Log ("[{0}/{1}] {2}" -f ($i + 1), $Libraries.Count, $spec)
    $sw = [Diagnostics.Stopwatch]::StartNew()
    & $VcpkgExe @argv 2>&1 | Tee-Object -FilePath $LogPath -Append
    $code = $LASTEXITCODE
    $sw.Stop()

    $ok = ($code -eq 0)
    Log ("{0} => {1} (exit={2}, {3:N1}s)" -f $spec, $(if ($ok) { '成功' } else { '失败' }), $code, $sw.Elapsed.TotalSeconds)
    if (-not $ok) {
        $failed += $spec
        if ($StopOnError) { Log '遇到失败，停止后续安装'; break }
    }
}

# 汇总
Log ''
$okCount = $Libraries.Count - $failed.Count
Log ("汇总: 共 {0} 项，成功 {1}，失败 {2}，日志 {3}" -f $Libraries.Count, $okCount, $failed.Count, $LogPath)
if ($failed.Count) { Log ("失败: {0}" -f ($failed -join ', ')) }

# 关机
if ($Shutdown) {
    $delay = [math]::Max(0, $ShutdownDelaySec)
    if ($failed.Count -and -not $ShutdownAlways) {
        Log '有失败项，跳过关机（如需强制关机加 -ShutdownAlways）'
    }
    elseif ($DryRun) {
        Log ("dry-run: 将执行 shutdown /s /t {0}" -f $delay)
    }
    else {
        Log ("{0}s 后关机，取消: shutdown /a" -f $delay)
        & shutdown.exe /s /t $delay /c 'vcpkg batch install finished' | Out-Null
    }
}

exit ([int]($failed.Count -gt 0))
