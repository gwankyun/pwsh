Write-Host $args
$a, $b = ($args[0]).Split(".")
$ver = $args[1]

$url = "https://marketplace.visualstudio.com/_apis/public/gallery/publishers/${a}/vsextensions/${b}/$ver/vspackage"

if ($args.Length -ge 3) {
    if ($args[2] -ne "false") {
        $url = "${url}?targetPlatform=win32-x64"
    }
}

Set-Clipboard $url
Write-Host $url
