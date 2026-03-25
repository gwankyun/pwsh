$path = $PWD

if ($args.Count -gt 0) {
    $path = $args[0]
}

$block = { $true }

if ($args.Count -gt 1) {
    $block = $args[1]
}

Get-ChildItem -Path $path -Recurse
| Sort-Object FullName
| ForEach-Object {
    $relativePath = Resolve-Path -Path $_.FullName `
        -Relative -RelativeBasePath $path
    [PSCustomObject]@{
        Relative      = $relativePath.TrimEnd('\')
        PSIsContainer = $_.PSIsContainer
        Length        = $_.Length
        LastWriteTime = $_.LastWriteTime.Ticks
    }
}
| Where-Object $block
