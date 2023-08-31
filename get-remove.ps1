$path = $PWD

if ($args.Length -lt 1)
{
    exit 1
}

$set = $args[0]

if ($args.Length -ge 2)
{
    $path = $args[1]
}

Get-ChildItem -Path $path -Recurse
| ForEach-Object { $set.Remove($_.FullName) }

$delete =
    $set.Keys
    | Select-Object { [IO.Path]::GetRelativePath($pwd, $_) }

return $delete
