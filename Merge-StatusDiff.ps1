$diff = $args[0]

$path = $PWD

if ($args.Count -gt 1) {
    $path = $args[1]
}

$compare_path = Join-Path $diff "compare.json"

$compare = Get-Content -Path $compare_path -Raw -Encoding utf8BOM
| ConvertFrom-Json

foreach ($i in $compare) {
    Write-Output $i
    # 是否文件夾
    $isContainer = $i.PSIsContainer
    # 目標路徑
    $target = Join-Path $path $i.Relative -Resolve
    # 源路徑
    $file = Join-Path $diff "data" $i.Relative
    switch ($i.Status) {
        "creation" {
            if ($isContainer) {
                # 目錄就創建
                New-Item -Path $target -ItemType Directory -Force
            } else {
                # 文件就複製
                Copy-Item -Path $file -Destination $target -Force
            }
        }
        "deletion" {
            # 直接刪除，無論是文件還是文件夾
            if (Test-Path -Path $target -PathType Container) {
                Remove-Item -Path $target -Recurse -Force
            } else {
                Remove-Item -Path $target -Force
            }
        }
        "modification" {
            $targetIsContainer = Test-Path -Path $target -PathType Container
            if ($isContainer) {
                if ($targetIsContainer) {
                    throw "PSIsContainer" # 已經過濾了，不可能
                } else { # 目標是文件
                    # 先刪文件再建文件夾
                    Remove-Item -Path $target -Force
                    New-Item -Path $target -ItemType Directory -Force
                }
            } else {
                if ($targetIsContainer) { # 目標是文件夾
                    # 先刪文件夾再複製文件
                     Remove-Item -Path $target -Recurse -Force
                     Copy-Item -Path $file -Destination $target -Force
                } else { # 目標是文件
                    Remove-Item -Path $target -Force
                    Copy-Item -Path $file -Destination $target -Force
                }
            }
        }
        default {
            throw "Status"
        }
    }
}
