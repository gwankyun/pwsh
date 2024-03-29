common.ps1

$requirements = "./python/requirements.txt"
$all_packet = "./python/all-packet"
$output = "./python.zip"

remove-any $all_packet

remove-any $requirements

remove-any $output

# remove-any ./python/requirements.txt

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

exit 0
