$diff = $args[0]

$path = $PWD

if ($args.Count -gt 1) {
    $path = $args[1]
}

$compare_path = Join-Path $diff "compare.json"

$compare = Get-Content -Path $compare_path -Raw -Encoding utf8BOM
| ConvertFrom-Json

foreach ($i in $compare) {
    Write-Output $i
    switch ($i.Status) {
        "creation" {
            $rela = Join-Path $path $i.Relative -Resolve
            Write-Output $rela.ToString()
        }
        "deletion" { }
        "modification" {
            $rela = Join-Path $path $i.Relative -Resolve
            Write-Output $rela.ToString()
        }
        default {
            throw "Status"
        }
    }
}
