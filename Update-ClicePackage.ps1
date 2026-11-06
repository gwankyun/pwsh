#Requires -Version 7.6
<#
.SYNOPSIS
    解压最新的 clice-*.zip（剥离 clice/ 顶层目录），并安装最新的 clice-*.vsix。

.DESCRIPTION
    SourceDir 默认当前目录；TargetDir 指向 clice 安装目录本身，例如 D:\application\clice。
    先解压到临时目录，确认 clice/ 存在后才备份旧目录，坏包不会影响现有安装。
    旧目录改名为 <目录名>.bak_<yyyyMMdd_HHmmss>；code.cmd 需在 PATH 中。

.PARAMETER SourceDir
    查找 zip / vsix 的目录，默认当前目录。

.PARAMETER TargetDir
    clice 安装目录，例如 D:\application\clice。目录名必须是 clice，且必须是绝对路径。

.PARAMETER ZipPattern
    zip 文件名模式，默认 clice-*.zip。

.PARAMETER VsixPattern
    vsix 文件名模式，默认 clice-*.vsix。
#>
[CmdletBinding()]
param(
    [string]$SourceDir = '.',
    [Parameter(Mandatory = $true)][string]$TargetDir,
    [string]$ZipPattern = 'clice-*.zip',
    [string]$VsixPattern = 'clice-*.vsix'
)

# 7.6：原生命令非 0 退出也变成终止错误，统一交给下面的 trap
$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $true

# 全局兜底：任何终止错误都打印一行 [FAIL] 并以 1 退出
trap {
    Write-Host "[FAIL] $_" -ForegroundColor Red
    exit 1
}

# 按最后修改时间取最新的匹配文件；-Top 需要较新的 PowerShell 7
function Get-LatestFile([string]$Pattern) {
    Get-ChildItem -LiteralPath $SourceDir -File -Filter $Pattern |
        Sort-Object LastWriteTimeUtc -Descending -Top 1
}

# 解压 zip 并替换 Target：
# 先解到临时目录并确认 clice/ 存在，成功后才备份旧目录。
function Expand-CliceZip([string]$ZipPath, [string]$Target) {
    # 目标目录必须叫 clice，防止把内容解到 D:\application 这类父目录
    if ((Split-Path -Leaf $Target) -ine 'clice') { throw "TargetDir 应指向 clice 目录: $Target" }

    # 临时目录放在 Target 旁边，保证最后移动在同一磁盘卷内
    $temp = "$Target.extract_$([guid]::NewGuid().ToString('N'))"
    New-Item -ItemType Directory -Path $temp -Force | Out-Null
    try {
        # PS7 直接调用 .NET 解压，不经过 Expand-Archive 模块
        [System.IO.Compression.ZipFile]::ExtractToDirectory($ZipPath, $temp)

        # zip 约定只有一个 clice/ 顶层目录
        $newDir = Join-Path $temp 'clice'
        if (-not (Test-Path -LiteralPath $newDir -PathType Container)) { throw 'zip 中没有 clice 顶层目录' }

        # 解压成功后再备份旧目录；同一秒内重名则安全失败
        if (Test-Path -LiteralPath $Target) {
            $backup = "$Target.bak_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
            if (Test-Path -LiteralPath $backup) { throw "备份路径已存在: $backup" }
            Move-Item -LiteralPath $Target -Destination $backup
            Write-Host "[OK] 旧目录已改名为: $backup" -ForegroundColor Green
        }

        # 用 .NET Move：目标必须不存在，避免 Move-Item 把目录嵌套进去
        [System.IO.Directory]::Move($newDir, $Target)
    } finally {
        # 无论成功失败都清理临时目录
        if (Test-Path -LiteralPath $temp) {
            Remove-Item -LiteralPath $temp -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}

# 源目录：默认当前目录，确认存在后转成绝对路径
if (-not (Test-Path -LiteralPath $SourceDir -PathType Container)) {
    throw "源目录不存在: $SourceDir"
}
$SourceDir = (Resolve-Path -LiteralPath $SourceDir).ProviderPath

# TargetDir 约定为绝对路径；GetFullPath 只做规范化，不依赖 PowerShell 当前目录
$TargetDir = ([System.IO.Path]::GetFullPath($TargetDir)).TrimEnd([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar)

# 不允许直接替换磁盘根目录
if ($TargetDir -match '^[A-Za-z]:$') {
    throw "TargetDir 不能是磁盘根目录: $TargetDir"
}

# 先找齐两个包，缺任意一个都不开始解压
$zipFile = Get-LatestFile $ZipPattern
if (-not $zipFile) { throw "未找到 $ZipPattern" }
$vsixFile = Get-LatestFile $VsixPattern
if (-not $vsixFile) { throw "未找到 $VsixPattern" }

Write-Host "ZIP : $($zipFile.FullName)"
Write-Host "VSIX: $($vsixFile.FullName)"
Write-Host "目标: $TargetDir"

# 解压/替换 clice 目录；失败时旧目录仍然保留
Expand-CliceZip -ZipPath $zipFile.FullName -Target $TargetDir

# code.cmd 由使用环境保证在 PATH 中；失败会抛异常，由顶层 trap 处理
& code.cmd --install-extension $vsixFile.FullName --force

Write-Host '[OK] 全部完成' -ForegroundColor Green
