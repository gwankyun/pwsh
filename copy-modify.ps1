﻿# 複製給定日期後有修改的文件

$path = $PWD

if ($args.Length -lt 2)
{
    exit 1
}

$date = $args[0] # 日期
$target = $args[1] # 目標路徑

$parent = (Get-Item $target).Parent

if ($args.Length -ge 3)
{
    $path = $args[2]
}

if (Test-Path $target -PathType Container)
{
    Remove-Item $target -Recurse
}

New-Item $target -ItemType Directory

$zip = Join-Path $parent.ToString() "bt.zip"

if (Test-Path $zip -PathType Leaf)
{
    Remove-Item $zip
}

Get-ChildItem -Path $path -Recurse
# | Where-Object { $_.LastWriteTime -gt [datetime]$date }
| Where-Object { $_.LastWriteTime -gt $date }
| ForEach-Object {
    $relative = [IO.Path]::GetRelativePath($pwd, $_.FullName)
    $dest = Join-Path $target $relative
    Copy-Item -Path $_.FullName -Destination $dest -Force
}

$compress = @{
    Path = "$target/*.*"
    DestinationPath = $zip
    CompressionLevel = "Fastest"
}
Compress-Archive @compress
