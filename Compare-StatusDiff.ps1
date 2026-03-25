$old = $args[0]
$new = $args[1]

Compare-Object -ReferenceObject $old -DifferenceObject $new `
    -Property Relative, PSIsContainer, Length, LastWriteTime
| Group-Object -Property Relative
| ForEach-Object {
    $count = $_.Count
    $group_old = $_.Group[0]
    $item = $group_old
    $status = "modification"
    if ($count -eq 2) {
        $group_new = $_.Group[1]
        # 以新文件為準
        if ($group_new.SideIndicator -eq "=>") {
            $item = $group_new
        }
        # 都是目錄，不處理
        if (($group_old.PSIsContainer -eq $true) -and
            ($group_new.PSIsContainer -eq $true)) {
            $status = ""
        }
    }
    if ($count -eq 1) {
        switch ($item.SideIndicator) {
            "<=" { # 舊有新無，刪除
                $status = "deletion"
            }
            "=>" { # 舊無新有，創建
                $status = "creation"
            }
            default { # 不可能
                throw "SideIndicator"
            }
        }
    }
    [pscustomobject]@{
        Relative      = $item.Relative
        PSIsContainer = $item.PSIsContainer
        Length        = $item.Length
        LastWriteTime = $item.LastWriteTime
        Status        = $status
    }
}
| Where-Object { $_.Status -ne "" } # 過濾出有狀態的項目
