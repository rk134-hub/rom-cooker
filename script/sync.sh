#!/usr/bin/env bash

export my_dir="$HOME"
export device="$(grep unch $my_dir/script/build_rom.sh -m 1 | cut -d ' ' -f 2 | cut -d _ -f 2 | cut -d - -f 1)"
export rom_name="$(grep init $my_dir/script/build_rom.sh -m 1 | cut -d / -f 4)"
export command="$(head $my_dir/script/build_rom.sh -n $(expr $(grep '# build rom' $my_dir/script/build_rom.sh -n | cut -f1 -d:) - 1))"
export only_sync=$(grep 'repo sync' $my_dir/script/build_rom.sh)


mkdir -p $my_dir/ccache/$rom_name
mkdir -p $my_dir/$rom_name
cd $my_dir/$rom_name
rm -rf .repo/local_manifests
rm -rf sync.log
bash -c "$command" |& tee -a $HOME/$rom_name/sync.log || true
a=$(grep 'Cannot remove project' sync.log -m1|| true)
b=$(grep "^fatal: remove-project element specifies non-existent project" sync.log -m1 || true)
c=$(grep 'repo sync has finished' sync.log -m1 || true)
d=$(grep 'Failing repos:' sync.log -n -m1 || true)
e=$(grep 'fatal: Unable' sync.log || true)
f=$(grep 'error.GitError' sync.log || true)
g=$(grep 'error: Cannot checkout' sync.log || true)
h=$(grep 'error: Downloading network changes failed.' sync.log || true)
if [[ $a == *'Cannot remove project'* ]]
then
a=$(echo $a | cut -d ':' -f2 | tr -d ' ')
rm -rf $a
repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync -j$(nproc --all)
elif [[ $b == *'remove-project element specifies non-existent'* ]]
then exit 1
elif [[ $c == *'repo sync has finished'* ]]
then true
elif [[ $d == *'Failing repos:'* ]]
then
d=$(expr $(grep 'Failing repos:' sync.log -n -m 1| cut -d ':' -f1) + 1)
d2=$(expr $(grep 'Try re-running' sync.log -n -m1 | cut -d ':' -f1) - 1 )
fail_paths=$(head -n $d2 sync.log | tail -n +$d)
for path in $fail_paths
do
rm -rf $path
aa=$(echo $path|awk -F '/' '{print $NF}')
rm -rf .repo/project-objects/*$aa.git
rm -rf .repo/projects/$path.git
done
repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync -j$(nproc --all)
elif [[ $e == *'fatal: Unable'* ]]
then
fail_paths=$(grep 'fatal: Unable' sync.log | cut -d ':' -f2 | cut -d "'" -f2)
for path in $fail_paths
do
rm -rf $path
aa=$(echo $path|awk -F '/' '{print $NF}')
rm -rf .repo/project-objects/*$aa.git
rm -rf .repo/project-objects/$path.git
rm -rf .repo/projects/$path.git
done
repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync -j$(nproc --all)
elif [[ $f == *'error.GitError'* ]]
then
rm -rf $(grep 'error.GitError' sync.log | cut -d ' ' -f2)
repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync -j$(nproc --all)
elif [[ $g == *'error: Cannot checkout'* ]]
then
echo hi
coerr=$(grep 'error: Cannot checkout' sync.log | cut -d ' ' -f 4| tr -d ':')
for i in $coerr
do
rm -rf .repo/project-objects/$i.git
done
repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync -j$(nproc --all)
elif [[ $h == *'error: Downloading network changes failed.'* ]]
then
repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync -j4
else
exit 1
fi
rm -rf sync.log
