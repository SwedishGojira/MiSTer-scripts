#!/bin/sh
version=0.2
#
#  Saturn Updater based on workflow builds  (c) 2022 by SwedishGojira GPLv2
#
#  20220907 initial version.
# 
#  Based on MiSTer-unstable-nightlies Updater (c) 2021 by Akuma GPLv2
#  Also uses nightly.link (c) 2020 Oleh Prypin (https://nightly.link/)
#

corename="Saturn"

self="$(readlink -f "$0")"

conf="${self%.*}.ini"
[ -f "$conf" ] && . "$conf"

trap "result" 0 1 3 15

result(){
  case "$?" in
    0) echo -e "last version: Github says, last commit on $gitversion"
       echo -e "core version: ${corefile##*/}\n";;
   99) echo "self: updated self";;
  100) echo "error: cannot reach url";;
  101) echo "error: cannot write to sdcard";;
  102) echo "error: download failed";;
  103) echo "error: checksum failed";;
  104) echo "error: json parsing failed";;
  105) echo "error: unzip failed";;
  esac
}

makedir(){ [ -d "$1" ] || { mkdir -p "$1" || exit 101;};}
download(){ wget --no-cache -q "$2" -O "$1" || { rm "$1";exit 102;};}
urlcat(){ wget --no-cache -q "$1" -O - || exit 100;}
checksum(){ md5sum "$1"|grep -q "$2" || { rm "$1";exit 103;};}
unpack(){ unzip -j -o "$1" -d "$2" >/dev/null 2>&1 || exit 105;}

selfurl="https://raw.githubusercontent.com/SwedishGojira/MiSTer-scripts/main/saturn-updater-workflow-builds.sh"
selfurl_version="$(urlcat "$selfurl"|sed -n 's,^version=,,;2p')"

[ "$selfurl_version" = "$version" ] || {
  tempfile="$(mktemp -u)"; download "$tempfile" "$selfurl"
  mv "$tempfile" "$self";chmod +x "$self";exec "$self"; exit 99
}

storagedir="/media/fat"
coredir="$storagedir/_Unstable";makedir "$coredir"
gamesdir="$storagedir/games";makedir "$coredir"
basedir="$gamesdir/${corename}";makedir "$basedir"
biosdir="$basedir/.bios";makedir "$biosdir"

biosurl="https://archive.org/download/segasaturnbios/Sega%20Saturn%20BIOS.zip"
bioshash="a8cd8951d07cd9ecdc175e9f0462cfb8"
biosfile="$basedir/saturnbios.zip"
[ -f "$biosfile" ] || download "$biosfile" "$biosurl"
[ -n "$bioshash" ] && checksum "$biosfile" "$bioshash"

[ -f "$basedir/boot.rom" ] || {
  unpack "$biosfile" "$biosdir"
  rm "$biosfile"
  echo "US Saturn BIOS downloaded."
  mv "$biosdir/Bios Saturn 1.01a (U) [!].bin" "$basedir/boot.rom" && rm -rf "$biosdir"
}

nightlyurl="$(curl -sL --insecure https://nightly.link/srg320/Saturn_MiSTer/blob/master/.github/workflows/test-build.yml | grep -Eo '[>]https://.*[.zip]' | head -1 | cut -c2-)"
corezip="$coredir/${nightlyurl##*/}"
corefile="$coredir/$(echo ${nightlyurl##*/} | cut -f 1 -d '.').rbf"
url="$nightlyurl"
[ -f "$corefile" ] && echo "Core already up to date."
[ -f "$corefile" ] || echo "Downloading latest core..."
[ -f "$corefile" ] || download "$corezip" "$url"
[ -f "$corezip" ] && unpack "$corezip" "$coredir"
[ -f "$corezip" ] && rm "$corezip" && find "$coredir" -iname "*.fit_*.txt" -delete
#find "$coredir" -iname "*.fit_*.txt" -delete
#ln -sf "$corefile" "$coredir/$corename_latest.rbf"

# mainurl="$selfurl"
# mainfile="/media/fat/Scripts/${mainurl##*/}"
# [ -f "$mainfile" ] || download "$mainfile" "$mainurl"

#misterhash="05074084b1469c75648d7eb4f1fb2a7c"
#misterfile="/media/fat/MiSTer"
#md5sum "$misterfile"|grep -q "$misterhash" && echo -e "NOTICE: Please update MAIN with: \"${mainurl##*/}\"\n"

[ -n "$maxkeep" -a -n "$coredir" -a -n "$corename" ] \
  && { ls -t "${coredir}/${corename}_"*".rbf"|awk "NR>$maxkeep"|xargs -r rm;}

commiturl="https://github.com/srg320/Saturn_MiSTer/commits/master"
gitversion="$(urlcat "$commiturl"|grep "Commits on"|head -1|sed 's,^.*Commits on ,,;s,<.*$,,')"

###
#echo $nightlyurl
#echo $corezip
#echo $corefile

exit 0
