$preset = ""
$mode = "config"

if ($args.Count -ge 1) {
    $preset = $args[0]
}

if ($args.Count -ge 2) {
    $c = $args[1]
    if ($c -eq "b") {
        $mode = "build"
    }
}

if ($mode -eq "build") {
    cmake --build --preset=$preset
}
else {
    cmake --preset=$preset
}
