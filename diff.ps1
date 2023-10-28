# 複製給定日期後有修改的文件

$path = $PWD

if ($args.Length -lt 2)
{
    exit 1
}

$package = $args[0] # 狀態記錄
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

$zip = Join-Path $parent.ToString() "update.zip"

if (Test-Path $zip -PathType Leaf)
{
    Remove-Item $zip
}

# 求出狀態
$json = (Get-Content (Join-Path $package "state.json") -Raw | ConvertFrom-Json).psobject.properties

$state = @{}
foreach ($i in $json) {
    $state[$i.Name] = $i.Value
}

# 求出日期
$dateStr = Get-Content -Raw (Join-Path $package "LastWriteTime.txt")
$date = [System.Convert]::ToDateTime($dateStr)

# Get-ChildItem -Path $path -Recurse
# | Where-Object { $_.LastWriteTime -gt $date }
# | ForEach-Object {
#     $relative = [IO.Path]::GetRelativePath($pwd, $_.FullName)
#     $dest = Join-Path $target "update" $relative
#     Copy-Item -Path $_.FullName -Destination $dest -Force
# }

# $compress = @{
#     Path = "$target/*.*"
#     DestinationPath = $zip
#     CompressionLevel = "Fastest"
# }
# Compress-Archive @compress



# return ($state, $date)
Write-Output $state

Write-Output "----------------------------------------------------"

Write-Output $date
