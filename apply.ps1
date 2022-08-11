$patch = Get-ChildItem *.patch

# 目錄沒有patch文件就退出
if ($patch.Length -eq 0)
{
    exit
}

$am = "am"

if ($args.Contains("-3"))
{
    $am = $am + " --3way --ignore-space-change --keep-cr"
}

if ($args.Contains("-i"))
{
    $am = $am + " --ignore-date"
}

$r = Start-Process -FilePath git -ArgumentList "${am} ${patch}" -NoNewWindow -Wait -PassThru
Write-Output $r.ExitCode

# 暫停一秒
Start-Sleep -Seconds 1

Remove-Item *.patch
