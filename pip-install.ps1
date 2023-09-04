common.ps1

[bool]$folder = $false

if ($args.Count -ge 1)
{
    if ($args[0] -eq "folder")
    {
        $folder = $true
    }
}

$requirements = "./python/requirements.txt"
$all_packet = "./python/all-packet"

if (-not $folder)
{
    if (-not (Test-Path ./python.zip))
    {
        Write-Output "python.zip不存在"
        exit 1
    }

    remove-any $all_packet

    remove-any $requirements

    $r = Expand-Archive ./python.zip -DestinationPath ./python -PassThru
    Write-Output $r
}

python -m pip install --no-index --find-links=$all_packet -r $requirements
if ($LASTEXITCODE -ne 0)
{
    Write-Output "pip install失敗。"
    exit 1
}

Write-Output "成功！"
exit 0
