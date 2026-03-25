$new = $args[0]
$compare = $args[1]
$output = $args[2]

function Copy-Compare {
    param(
        [string]$new,
        [string]$creation_path,
        [PSCustomObject]$i
    )
    # $creation_path = Join-Path $output "creation"
    if (-not (Test-Path $creation_path -PathType Container)) {
        New-Item -Path $creation_path -ItemType Directory -Force
    }
    if ($i.PSIsContainer -eq $true) {
        $path = Join-Path $creation_path $relative
        New-Item -Path $path -ItemType Directory -Force
    }
    else {
        $from = Join-Path $new $relative
        Copy-Item -Path $from -Destination $creation_path
    }
}

$compare
| ConvertTo-Json
| Out-File -Encoding utf8BOM (Join-Path $output "compare.json")

foreach ($i in $compare) {
    Write-Output $i2
    [string]$relative = $i.Relative
    switch ($i.Status) {
        "deletion" {
            Write-Output "deletion: $relative"
        }
        "creation" {
            Write-Output "creation: $relative"
            $creation_path = Join-Path $output "data"
            Copy-Compare $new $creation_path $i
        }
        "modification" {
            Write-Output "modification: $relative"
            $modification_path = Join-Path $output "data"
            Copy-Compare $new $modification_path $i
        }
        default {
            throw "unknown status: $i.Status"
        }
    }
}