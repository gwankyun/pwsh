common.ps1

$requirements = "./python/requirements.txt"
$all_packet = "./python/all-packet"
$output = "./python.zip"

Remove-AnyItem $all_packet

Remove-AnyItem $requirements

Remove-AnyItem $output

python -m pip freeze > $requirements

if ($LASTEXITCODE -ne 0) {
    Write-Output "freeze"
    exit 1
}

# setuptools wheel也要下載
python -m pip download -d $all_packet -r $requirements setuptools wheel

if ($LASTEXITCODE -ne 0) {
    Write-Output "download"
    exit 1
}

$compress = @{
    Path = $all_packet, $requirements
    DestinationPath = $output
    CompressionLevel = "Fastest"
}
Compress-Archive @compress

if ($LASTEXITCODE -ne 0) {
    Write-Output "Compress-Archive"
    exit 1
}

exit 0
