# 列出新文件
$list = Get-ChildItem e:\test
    | Where-Object { $_.LastWriteTime.AddHours(3.5) -ge (Get-Date) }

foreach ($i in $list) {
    # Write-Host $i
    $path = "c:\Users\ljqic\Documents\GitHub\"
    if ($i.Name -eq "sm18-lazy-package.zip") {
        Write-Host "  !sm18-lazy-package"
        $path = "c:\local\"
    }
    elseif ($i.Name -eq "data.zip") {
        Write-Host "  !data"
        $path = "C:\Users\ljqic\Documents\SiYuan\"
    }
    Write-Host $path
    if (Test-Path (Join-Path $path $i.BaseName)) {
        Write-Host "has" (Join-Path $path $i.BaseName)
        Set-Location (Join-Path $path $i.BaseName)
        apply.ps1
        Write-Host $LASTEXITCODE
    }
    else {
        Write-Host "has not" (Join-Path $path $i.BaseName)
    }
}
