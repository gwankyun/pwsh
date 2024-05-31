# 避免中文亂碼
$utf8 = [Text.Encoding]::UTF8
if ([Console]::OutputEncoding -ne $utf8) {
    [Console]::OutputEncoding = $utf8
}
