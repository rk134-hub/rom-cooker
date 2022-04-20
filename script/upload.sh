#!/usr/bin/env bash

export my_dir="$HOME"
export device="$(grep unch $my_dir/script/build_rom.sh -m 1 | cut -d ' ' -f 2 | cut -d _ -f 2 | cut -d - -f 1)"
export rom_name="$(grep init $my_dir/script/build_rom.sh -m 1 | cut -d / -f 4)"
export rel_date="$(date "+%Y%m%d")"
export branch_name=$(grep init $my_dir/script/build_rom.sh | awk -F "-b " '{print $2}' | awk '{print $1}')
export rel_date="$(date "+%Y%m%d")"
export shasum="out/target/product/$device/*$rel_date*.zip*sha*"
export ota="out/target/product/$device/*ota*.zip"

cd $my_dir/$rom_name
rm -rf $shasum
rm -rf $ota
cd $my_dir/$rom_name/out/target/product/$device
rclone copy --drive-chunk-size 256M --stats 1s *$rel_date*.zip NFS:$rom_name/$device -P
