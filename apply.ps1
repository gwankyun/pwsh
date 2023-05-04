# 导入rar命令
common.ps1

$path = ""
$json = get_config
if ($json -and $json.path -and (Test-Path $json.path)) {
    $path = $json.path
}
Write-Output ("path: " + $path)

# 是否重置時間
[bool]$ignore_date = $false
if ($json -and $null -ne $json.ignore_date) {
    $ignore_date = $json.ignore_date
}

$patch = Get-ChildItem *.patch

function Get-Path {
    $path = (Get-Location).Path.ToString()
    $idx = $path.LastIndexOf("\")
    if ($idx -eq -1) {
        return ""
    }
    $file = $path.Substring($idx + 1)
    return $file
}
$file = Get-Path
if ($file -eq "") {
    $file = "file"
}

# 獲取密碼
$h = get_password

# 目錄沒有patch文件就使用配置位置的rar包
if ($patch.Length -eq 0)
{
    if ($path -ne "") {
        if (winrar_expand ($path + $file) $h -ne 0) {
            Write-Output "解壓失敗"
            exit 1
        }
    }
}

if (-not (Test-Path *.patch)) {
    Write-Output "找不到patch文件"
    exit 1
}

$am = "am"

if ($args.Contains("-3") -or ($file -eq "sm18-lazy-package"))
{
    $am = $am + " --3way --ignore-space-change --keep-cr"
}

if ($args.Contains("-i") -or $ignore_date)
{
    $am = $am + " --ignore-date"
}

$patch = Get-ChildItem *.patch

$r = Start-Process -FilePath git -ArgumentList "${am} ${patch}" -NoNewWindow -Wait -PassThru
Write-Output $r.ExitCode

# 暫停一秒
Start-Sleep -Seconds 1

Remove-Item *.patch
