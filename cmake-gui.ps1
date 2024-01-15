$build = "build"

if ($args.Count -ge 1) {
    $build = $args[0]
}

cmake-gui -S . -B $build

exit 0
