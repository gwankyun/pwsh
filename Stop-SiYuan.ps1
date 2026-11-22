# 查找 SiYuan-Kernel 进程
$proc = Get-Process -Name SiYuan-Kernel -ErrorAction SilentlyContinue

if (-not $proc) {
    Write-Host "未找到 SiYuan-Kernel 进程" -ForegroundColor Yellow
    exit 0
}

Write-Host "找到 SiYuan-Kernel 进程，PID：$($proc.Id)" -ForegroundColor Green
$choice = Read-Host "是否关闭该进程？(y/n)"

if ($choice -eq 'y' -or $choice -eq 'Y') {
    Stop-Process -Id $proc.Id -Force
    Write-Host "已终止进程 PID $($proc.Id)" -ForegroundColor Green
} else {
    Write-Host "取消操作" -ForegroundColor Gray
}
