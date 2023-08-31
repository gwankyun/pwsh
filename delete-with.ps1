$path = $PWD

if ($args.Length -lt 1)
{
    exit 1
}

$fileList = $args[0]

if ($args.Length -ge 2)
{
    $path = $args[1]
}

[IO.File]::ReadAllLines($fileList)
| ForEach-Object { Join-Path $dest $_ }
| Where-Object { (Test-Path $_) -and ($_ -ne $path) }
| ForEach-Object { Remove-Item $_ -Recurse }
