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
Start-Process -FilePath WinRAR -ArgumentList "a ${file} *.patch -m5 ${h} -T" -NoNewWindow -Wait
Remove-Item *.patch