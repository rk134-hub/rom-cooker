# sync rom
repo init --depth=1 --no-repo-verify -u git://github.com/Evolution-X/manifest.git -b snow -g default,-mips,-darwin,-notdefault
git clone https://github.com/rk134/local_manifests.git --depth 1 -b evox .repo/local_manifests
repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync -j$(nproc --all) 

#Build
source build/envsetup.sh
export TZ=Asia/Jakarta
lunch evolution_vince-user
mka evolution
# end

