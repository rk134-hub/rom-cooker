#!/usr/bin/env bash

export my_dir="$HOME"
export device="$(grep unch $my_dir/script/build_rom.sh -m 1 | cut -d ' ' -f 2 | cut -d _ -f 2 | cut -d - -f 1)"
export rom_name="$(grep init $my_dir/script/build_rom.sh -m 1 | cut -d / -f 4)"
export command="$(tail $my_dir/script/build_rom.sh -n +$(expr $(grep '# build rom' $my_dir/script/build_rom.sh -n | cut -f1 -d:) - 1)| head -n -1 | grep -v '# end')"
export rel_date="$(date "+%Y%m%d")"


cd $my_dir/$rom_name
export ALLOW_MISSING_DEPENDENCIES=true
export CCACHE_DIR=$my_dir/ccache/$rom_name
export CCACHE_EXEC=/usr/bin/ccache
export USE_CCACHE=1
ccache -o compression=true
ccache -o compression_level=1
ccache -o max_size=150G
ccache -z
bash -c "$command" |& tee -a $HOME/$rom_name/build.log || true
a=$(grep 'FAILED:' build.log -m1 || true)
if [[ $a == *'FAILED:'* ]]
then
curl -s -X POST "https://api.telegram.org/bot${tg_token}/sendMessage" -d chat_id="${tg_id}" -d "disable_web_page_preview=true" -d "parse_mode=html" -d text="<code>${device_model} Build $rom_name</code> <b>Error.</b>[❌]"
curl -F document=@build.log "https://api.telegram.org/bot${tg_token}/sendDocument" -F chat_id="${tg_id}" -F "disable_web_page_preview=true" -F "parse_mode=html"
curl -s -X POST "https://api.telegram.org/bot${tg_token}/sendSticker" -d sticker="CAACAgEAAx0CXv8ybAACHEZiUr7sXBT0axhN942ECnzG_ajoPgACywADpAyuMsUxebdwuHhQIwQ" -d chat_id="${tg_id}"
rm -rf build.log
exit 1
fi
