$config = $args[0]

if (("Debug", "Release") -notcontains $config) {
    Write-Host "未知配置"
    exit 1
}

function build($config) {
    cmake --build build --config $config
}

function install($config) {
    gsudo cmake --build build --target install --config $config
}

build $config
if ($LASTEXITCODE -ne 0) {
    exit 1
}
Write-Output "構建成功"

install $config
if ($LASTEXITCODE -ne 0) {
    exit 1
}
Write-Output "安裝成功"

exit 0
