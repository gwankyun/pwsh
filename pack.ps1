$num = -1
$pw = ""

$file = Split-Path $PWD -Leaf

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

# 导入rar命令
common.ps1

remove ($file + ".rar")

# 獲取密碼
$h = get_password

Write-Host "file: " $file

$rar = $file

if ($rar.Contains(".")) {
    $rar = $rar + ".rar"
}

Rar a $rar *.patch -m5 $h -t
if ($LASTEXITCODE -ne 0) {
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
    if ($LASTEXITCODE -ne 0) {
        Write-Output "複製失敗"
        exit 1
    }

    Write-Output ("複製到" + $json.path)
    Remove-Item -Path *.rar
    if ($LASTEXITCODE -ne 0) {
        Write-Output "刪除失敗"
    }
}

exit 0
