function remove-item_safe([string]$path) {
    if (Test-Path $path -PathType Container) {
        Remove-Item $path -Recurse
    }
    elseif (Test-Path $path) {
        Remove-Item $path
    }
}

remove-item_safe ./python/all-packet

remove-item_safe ./python/requirements.txt

if (-not (Test-Path ./python.zip)) {
    Write-Output "python.zip不存在"
    exit 1
}

Expand-Archive ./python.zip -DestinationPath ./python

if ($LASTEXITCODE -ne 0) {
    Write-Output "解壓失敗。"
    exit 1
}

Set-Location ./python

python -m pip install --no-index --find-links=./all-packet -r requirements.txt

if ($LASTEXITCODE -ne 0) {
    Write-Output "pip install失敗。"
    exit 1
}

Set-Location ..
