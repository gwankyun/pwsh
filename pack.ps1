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
if (Test-Path ($file + ".rar")) {
    Remove-Item ($file + ".rar")
}

# 导入rar命令
common.ps1

# 獲取密碼
$h = get_password

# 阻塞運行
if (winrar_compress $file $h *.patch -ne 0) {
    Write-Output "壓縮失敗"
    exit 1
}
Remove-Item *.patch
if ($LASTEXITCODE -ne 0) {
    Write-Output "刪除失敗"
    exit 1
}

# 打包後複製到指定位置
$json = get_config
if ($json -and $json.path -and (Test-Path $json.path)) {
    Copy-Item -Path *.rar -Destination $json.path
    if ($LASTEXITCODE -eq 0) {
        Write-Output ("複製到" + $json.path)
        Remove-Item -Path *.rar
        if ($LASTEXITCODE -ne 0) {
            Write-Output "刪除失敗"
        }
    }
}
