#!/usr/bin/env bash

export my_dir="$HOME"
export device="$(grep unch $my_dir/script/build_rom.sh -m 1 | cut -d ' ' -f 2 | cut -d _ -f 2 | cut -d - -f 1)"
export rom_name="$(grep init $my_dir/script/build_rom.sh -m 1 | cut -d / -f 4)"
export branch_name=$(grep init $my_dir/script/build_rom.sh | awk -F "-b " '{print $2}' | awk '{print $1}')
cd $my_dir/$rom_name
export rel_date="$(date "+%Y%m%d")"
export file_name="$(basename out/target/product/$device/*.zip)"
telegram_message() {
         curl -s -X POST "https://api.telegram.org/bot${tg_token}/sendMessage" \
         -d chat_id="${tg_id}" \
         -d parse_mode="HTML" \
         -d text="$1"
}
DL_LINK="https://rombuilder.projek.workers.dev/$rom_name/$device/$file_name"
DATE_L="$(date +%d\ %B\ %Y)"
DATE_S="$(date +"%T")"
echo -e \
"
✅ Build Completed Successfully!

🚀 Info Rom: "${rom_name}"
📱 Device: "${device}"
🖥 Branch Build: "${branch_name}"
⬇️ Download Link: <a href=\"${DL_LINK}\">Here</a>
📅 Date: "$(date +%d\ %B\ %Y)"
⏱ Time: "$(date +%T)"
" > tg.html
TG_TEXT=$(< tg.html)
telegram_message "$TG_TEXT"
curl -s -X POST "https://api.telegram.org/bot${tg_token}/sendSticker" -d sticker="CAACAgEAAx0CXv8ybAACHEJiUr3Z7W87PImIy1cs_dVTw2hdOAACqgADpAyuMtYfNzJONI2kIwQ" -d chat_id="${tg_id}"
echo " "
#rm -rf $my_dir/$rom_name/out/target/product/$device
cd $my_dir
rm -rf .repo*
