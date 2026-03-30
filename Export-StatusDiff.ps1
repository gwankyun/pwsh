param(
    [string]$Path,
    [PSCustomObject]$Compare,
    [string]$Destination = $PWD
)

# $new = $args[0]
# $compare = $args[1]
# $output = $args[2]

function Copy-Compare {
    param(
        [string]$Path,
        [string]$creation_path,
        [PSCustomObject]$i
    )
    [string]$relative = $i.Relative

    # 不是目錄可以直接刪除
    # if (-not (Test-Path $creation_path -PathType Container)) {
    #     New-Item -Path $creation_path -ItemType Directory -Force
    # }


    if ($i.PSIsContainer) {
        $dest = Join-Path $creation_path $relative -Resolve
        New-Item -Path $dest -ItemType Directory -Force -Force
    }
    else {
        $src = Join-Path $Path $relative
        Copy-Item -Path $src -Destination $creation_path -Force
    }
}

$compareJson = Join-Path $Destination "compare.json"

$Compare
| ConvertTo-Json
| Out-File -Encoding utf8BOM -FilePath $compareJson

Write-Output "compare.json: $compareJson"

if (-not (Test-Path $compareJson -PathType Leaf)) {
    throw "compare.json not found"
}

foreach ($i in $Compare) {
    Write-Output $i
    [string]$relative = $i.Relative
    switch ($i.Status) {
        "deletion" {
            # Write-Output "deletion: $relative"
        }
        "creation" {
            # Write-Output "creation: $relative"
            $creation_path = Join-Path $Output "data"
            if (-not (Test-Path $creation_path -PathType Container)) {
                New-Item -Path $creation_path -ItemType Directory -Force
            }
            Copy-Compare $Path $creation_path $i
        }
        "modification" {
            # Write-Output "modification: $relative"
            $modification_path = Join-Path $Output "data"
            if (-not (Test-Path $modification_path -PathType Container)) {
                New-Item -Path $modification_path -ItemType Directory -Force
            }
            Copy-Compare $Path $modification_path $i
        }
        default {
            throw "unknown status: $i.Status"
        }
    }
}