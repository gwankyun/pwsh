$path = $PWD

if ($args.Length -lt 1)
{
    exit 1
}

$dest = $args[0] # 目標路徑

if (-not (Test-Path $dest -PathType Container))
{
    exit 1
}

if ($args.Length -gt 2)
{
    $path = $args[1]
}

if (-not (Test-Path $path -PathType Container))
{
    exit 1
}

$zip = Join-Path $path "bt.zip"

if (-not (Test-Path $zip -PathType Leaf))
{
    exit 1
}

# 解壓文件
Expand-Archive $zip -DestinationPath $dest -Force

$delete = Join-Path $path "delete.txt"

if (-not (Test-Path $delete -PathType Leaf))
{
    exit 1
}

# 刪除文件
[IO.File]::ReadAllLines($delete)
| ForEach-Object { Join-Path $dest $_ }
| Where-Object { (Test-Path $_) -and ($_ -ne $dest) }
| ForEach-Object { Remove-Item $_ -Recurse }
