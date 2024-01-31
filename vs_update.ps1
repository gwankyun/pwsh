$buildtools = ".\vs_BuildTools.exe"
$layout = ".\build_tools\"

if ($args.Length -ge 2) {
    $buildtools = $args[0]
    $layout = $args[1]
}

if (-not (Test-Path $layout)) {
    Write-Host "${layout}不存在"
    exit 1
}

function vs_update($buildtools, $layout) {
    $r = Start-Process -FilePath $buildtools -ArgumentList "--layout $layout" -NoNewWindow -Wait -PassThru
    return $r.ExitCode
}

function vs_clean($buildtools, $layout) {
    $ret = 1
    $archive = Join-Path $layout "Archive"
    foreach ($i in (Get-ChildItem $archive)) {
        $catalog = Join-Path $i "Catalog.json"
        if (Test-Path $catalog) {
            $r = Start-Process -FilePath $buildtools -ArgumentList "--layout $layout --clean $catalog" -NoNewWindow -Wait -PassThru
            $ret = $r.ExitCode
            break
        }
    }
    return $ret
}

function vs_verify($buildtools, $layout) {
    $r = Start-Process -FilePath $buildtools -ArgumentList "--layout $layout --verify" -NoNewWindow -Wait -PassThru
    return $r.ExitCode
}

$ret = vs_update $buildtools $layout
if ($ret -ne 0) {
    Write-Output "更新失敗"
    exit 1
}
Write-Output "更新成功"

$ret = vs_clean $buildtools $layout
if ($ret -ne 0) {
    Write-Output "刪除失敗"
    exit 1
}
Write-Output "刪除成功"

$ret = vs_verify $buildtools $layout
if ($ret -ne 0) {
    Write-Output "驗證失敗"
    exit 1
}
Write-Output "驗證成功"

exit 0
