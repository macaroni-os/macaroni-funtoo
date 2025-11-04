<p align="center">
  <img src="https://github.com/macaroni-os/macaroni-site/blob/master/site/static/images/logo.png">
</p>

# macaroni-funtoo

Anise Macaroni Repository Tree used to create Phoenix, Eagle and Terragon packages.

Macaroni Phoenix, Eagle and Terragon using MARK as build toolchain and generate binary packages.

Branches behavior:
* `phoenix`: branch for Phoenix release (MARK III based).

* `terragon`: Container oriented and with openRC (MARK XL based)

* `eagle`: branch for Eagle release (MARK XL based).

* `master`: branch for Phoenix release (Funtoo 1.4-prime). EOL end 2023.

* `systemd`: branch for Eagle release (Funtoo 1.4-prime). EOL end 2023.


## Generate packages with `anise-portage-converter`

To generate specs for all packages defined on rules and their dependencies (runtime and buildtime):
```bash
$> anise-portage-converter generate -t ./packages/  --to . --rules portage-converter/office.yaml --ignore-missing-deps  --with-portage-pkg   --enable-stage4 --disable-conflicts
```

To generate specs for a specific package defined on rules and their dependencies (runtime and buildtime):

```bash
$> anise-portage-converter generate -t ./packages/  --to . --rules portage-converter/office.yaml --ignore-missing-deps  --with-portage-pkg   --enable-stage4 --disable-conflicts --pkg app/foo
```

NOTE: The `kit_cache` could be generated with:

```
$> cd packages/seeds/mark-kits/
$> # This command update the local kits-versions/kits.yaml too.
$> mark-devkit kit clone --concurrency 30 \
        --kit-cache-dir kit_cache/ \
        --specfile ~/dev/macaroni/kit-fixups-mark-iii/merge.distfiles.d/mark-iii.yml \
        --write-summary-file kits-versions/kits.yaml \
        --generate-reposcan-files
$> cp kit_cache/* -rf ../../../kit_cache/
$> rm -rf kit_cache/ output/
```

