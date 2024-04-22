$config = $args[0]

function build($config) {
    cmake --build build --config $config
}

function install($config) {
    gsudo cmake --build build --target install --config $config
}

function build_install_config($config, [ref]$r) {
    Write-Host "config: $config"
    $r.Value = 0
    build $config
    if ($LASTEXITCODE -ne 0) {
        $r.Value = 1
        return
    }
    Write-Output "構建成功"

    install $config
    if ($LASTEXITCODE -ne 0) {
        $r.Value = 1
        return
    }
    Write-Output "安裝成功"
    return
}

if (("Debug", "Release", "All") -notcontains $config) {
    Write-Host "未知配置"
    exit 1
}

$config_list = @()

if ($config -eq "All") {
    $config_list += "Debug"
    $config_list += "Release"
}
else {
    $config_list += $config
}

foreach ($i in $config_list) {
    $r = 0
    build_install_config $i ([ref]$r)
    if ($r -ne 0) {
        Write-Host "error: $i"
        exit 1
    }
}

exit 0
