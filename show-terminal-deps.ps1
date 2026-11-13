# 拿到WT包
$wtPkg = Get-AppxPackage *WindowsTerminal*
# 读取manifest
$manifest = Get-AppxPackageManifest $wtPkg.PackageFullName
# 打印所有PackageDependency（包名、最低版本）
$manifest.Package.Dependencies.PackageDependency | Select-Object Name, MinVersion
