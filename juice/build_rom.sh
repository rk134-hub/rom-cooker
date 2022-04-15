# sync rom
repo init --depth=1 --no-repo-verify -u https://github.com/Bootleggers-BrokenLab/manifest.git -b sambunimbo -g default,-mips,-darwin,-notdefault
git clone https://github.com/c3eru/local_manifest --depth 1 -b main .repo/local_manifests
repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync -j8

# build rom
source build/envsetup.sh
export TZ=Asia/Jakarta
export BUILD_USERNAME=mobxprjkt
export BUILD_HOSTNAME=RANDOMBUILD
export ALLOW_MISSING_DEPENDENCIES=true
lunch bootleg_juice-userdebug
 
curl -s -X POST "https://api.telegram.org/bot${tg_token}/sendMessage" -d chat_id="${tg_id}" -d "disable_web_page_preview=true" -d "parse_mode=html" -d text="===================================%0A<b>POCO M3/9T ($device)</b> Building Rom Started%0A<b>ROM:</b>$rom_name%0A$(echo "${var_cache_report_config}")"

mka bacon
 
# end
# set commit : trying lld
