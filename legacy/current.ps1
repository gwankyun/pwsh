# 將當前狀態輸出到文件

# 默認當前目錄
$path = $PWD
if ($args.Length -ge 1)
{
    $path = $args[0]
}

$dest = ""
if ($args.Length -ge 2)
{
    $dest = $args[1]
}

function max($a, $b) {
    if ($a -gt $b) {
        return $a
    }
    else {
        return $b
    }
}

$set = @{};
$lastWrite = $null
Get-ChildItem -Path $path -Recurse
| ForEach-Object {
    $isDir = $false
    if (Test-Path $_.FullName -PathType Container)
    {
        $isDir = $true
    }
    $set[$_.FullName] = $isDir
    if ($lastWrite -eq $null) {
        $lastWrite = $_.LastWriteTime
    }
    else {
        $lastWrite = max $lastWrite $_.LastWriteTime
    }
}

# 寫入到本地目錄
if ($dest -ne "") {
    $set
    | ConvertTo-Json
    | Out-File -Encoding utf8BOM (Join-Path $dest "state.json")

    # [System.Convert]::ToDateTime(
    $lastWrite.ToString()
    | Out-File -Encoding utf8BOM (Join-Path $dest "LastWriteTime.txt")
}

# 返回文件列表和最後修改時間
return $set, $lastWrite
