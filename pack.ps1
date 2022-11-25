$num = -1
$pw = ""

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
if ($args.Count -ge 1) {
    $num = $args[0]
}
if ($args.Count -ge 2) {
    $pw = $args[1]
}
Remove-Item *.patch
git format-patch $num
if (Test-Path logseq.rar) {
    Remove-Item logseq.rar
}

$h = ""

if (Test-Path "$PSScriptRoot/password.txt") {
    $pw = Get-Content "$PSScriptRoot/password.txt"
    $h = "-hp" + $pw
}

# 阻塞運行
$process = Start-Process -FilePath WinRAR -ArgumentList "a ${file} *.patch -m5 ${h} -T" -NoNewWindow -Wait -PassThru
Write-Output $process.ExitCode # 進程返回值
if ($process.ExitCode -ne 0) {
    Write-Output "壓縮失敗"
    exit 1
}
Remove-Item *.patch

# 打包後複製到指定位置
$config = "$PSScriptRoot/config.json"
if (Test-Path $config) {
    $json = Get-Content $config -Raw | ConvertFrom-Json
    if ($json.path -and (Test-Path $json.path)) {
        Write-Output ("複製到" + $json.path)
        Copy-Item -Path *.rar -Destination $json.path
    }
}
