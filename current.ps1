# 默認當前目錄
$path = $PWD
if ($args.Length -ge 1)
{
    $path = $args[0]
}

$set = @{};
Get-ChildItem -Path $path -Recurse
| ForEach-Object {
    $isDir = $false
    if (Test-Path $_.FullName -PathType Container) {
        $isDir = $true
    }
    $set[$_.FullName] = $isDir
}

return $set
