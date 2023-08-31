function global:winrar_compress([string]$output, [string]$pw, [string[]]$file) {
    $process = Start-Process -FilePath WinRAR -ArgumentList "a $output $file -m5 $pw -t" -NoNewWindow -Wait -PassThru
    return $process.ExitCode
}

function global:rar_compress([string]$output, [string]$pw, [string[]]$file) {
    # $process = Start-Process -FilePath Rar -ArgumentList "a $output $file -m5 $pw -t" -NoNewWindow -Wait -PassThru
    # return $process.ExitCode
    Rar a $output $file -m5 $pw -t
    # Write-Output $LASTEXITCODE
    # return $LASTEXITCODE
}

function global:winrar_expand([string]$file, [string]$pw) {
    $process = Start-Process -FilePath WinRAR -ArgumentList "x $file $pw" -NoNewWindow -Wait -PassThru
    return $process.ExitCode
}

function global:rar_expand([string]$file, [string]$pw) {
    $process = Start-Process -FilePath Rar -ArgumentList "x $file $pw" -NoNewWindow -Wait -PassThru
    return $process.ExitCode
}

function global:remove-test-item([string]$path) {
    if (Test-Path $path -PathType Container) {
        Remove-Item $path -Recurse
    }
    elseif (Test-Path $path) {
        Remove-Item $path
    }
}

function global:remove-any([string]$path) {
    if (Test-Path $path -PathType Container) {
        Remove-Item $path -Recurse
    }
    elseif (Test-Path $path) {
        Remove-Item $path
    }
}

function global:get_password {
    if (Test-Path "$PSScriptRoot/password.txt") {
        $pw = Get-Content "$PSScriptRoot/password.txt"
        $h = "-hp" + $pw
        return $h
    }
    return ""
}

function global:get_config {
    $config = "$PSScriptRoot/config.json"
    $json = $null
    if (Test-Path $config) {
        $json = Get-Content $config -Raw | ConvertFrom-Json
    }
    return $json
}
