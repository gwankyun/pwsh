common.ps1

$requirements = "./requirements.txt"
$all_packet = "./all-packet"
$output = "./python.zip"

remove-test-item ./python/all-packet

remove-test-item ./python/requirements.txt

Set-Location ./python

python -m pip freeze > $requirements

if ($LASTEXITCODE -ne 0) {
    Write-Output "freeze"
    exit 1
}

python -m pip download -d $all_packet -r $requirements

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

Set-Location ..

exit 0
