$path = $PWD

if ($args.Length -lt 2)
{
    exit 1
}

$date = $args[0]
$target = $args[1]

if ($args.Length -ge 3)
{
    $path = $args[2]
}

Get-ChildItem -Path $path -Recurse
| Where-Object { $_.LastWriteTime -gt [datetime]$date }
| ForEach-Object {
    $relative = [IO.Path]::GetRelativePath($pwd, $_.FullName)
    $dest = Join-Path $target $relative
    Copy-Item -Path $_.FullName -Destination $dest -Force
}
