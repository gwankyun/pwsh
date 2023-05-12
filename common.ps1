function global:winrar_compress([string]$output, [string]$pw, [string[]]$file) {
    $process = Start-Process -FilePath WinRAR -ArgumentList "a $output $file -m5 $pw -t" -NoNewWindow -Wait -PassThru
    return $process.ExitCode
}

function global:winrar_expand([string]$file, [string]$pw) {
    $process = Start-Process -FilePath WinRAR -ArgumentList "x $file $pw" -NoNewWindow -Wait -PassThru
    return $process.ExitCode
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
