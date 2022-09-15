#!/bin/sh
version=0.8
#
#  Saturn Updater based on workflow builds  (c) 2022 by SwedishGojira GPLv2
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
    0) echo -e "Last version: Github says, last commit on $gitversion"
       echo -e "Core version: ${corefile##*/}\n";;
   99) echo "self: updated self";;
  100) echo "error: cannot reach url";;
  101) echo "error: cannot write to sdcard";;
  102) echo "error: download failed";;
  105) echo "error: unzip failed";;
  esac
}

makedir(){ [ -d "$1" ] || { mkdir -p "$1" || exit 101;};}
download(){ wget --no-cache -q "$2" -O "$1" || { rm "$1";exit 102;};}
urlcat(){ wget --no-cache -q "$1" -O - || exit 100;}
unpack(){ unzip -j -o "$1" -d "$2" >/dev/null 2>&1 || exit 105;}

selfurl="https://raw.githubusercontent.com/SwedishGojira/MiSTer-scripts/main/saturn-updater-workflow-builds.sh"
selfurl_version="$(urlcat "$selfurl"|sed -n 's,^version=,,;2p')"

if [ ! "$selfurl_version" = "$version" ]; then
  tempfile="$(mktemp -u)"
  download "$tempfile" "$selfurl"
  mv "$tempfile" "$self"
  chmod +x "$self"
  exec "$self"
  exit 99
fi

echo -e "\e[0m█▀ ▄▀█ ▀█▀ █\e[34m░\e[39m█ █▀█ █▄\e[34m░\e[39m█   █▀▀ █▀█ █▀█ █▀▀"
echo -e "▄█ █▀█ \e[34m░\e[39m█\e[34m░\e[39m █▄█ █▀▄ █\e[34m░\e[39m▀█   █▄▄ █▄█ █▀▄ ██▄"
echo ""
echo -e "\e[39m█\e[34m░\e[39m█ █▀█ █▀▄ ▄▀█ ▀█▀ █▀▀ █▀█  \e[1m\e[34mversion. $version\e[0m"
echo -e "█▄█ █▀▀ █▄▀ █▀█ \e[34m░\e[39m█\e[34m░\e[39m ██▄ █▀▄  \e[34m░░░░░░░░ ░░░\e[0m"
echo ""

storagedir="/media/fat"
coredir="$storagedir/_Unstable";makedir "$coredir"
nightlyurl="$(curl -sL --insecure https://nightly.link/srg320/Saturn_MiSTer/blob/master/.github/workflows/test-build$DS.yml | grep -Eo '[>]https://.*[.zip]' | head -1 | cut -c2-)"
corezip="$coredir/${nightlyurl##*/}"
corefile="$coredir/$(echo ${nightlyurl##*/} | cut -f 1 -d '.').rbf"
if [ -f "$corefile" ]; then
  echo "Core already up to date."
else
  echo "Downloading latest core..."
  download "$corezip" "$nightlyurl"
  if [ -f "$corezip" ]; then
    unpack "$corezip" "$coredir"
    rm "$corezip"
    find "$coredir" -iname "*.fit_*.txt" -delete
  fi
fi

if [ -f "$coredir/ Saturn_latest.rbf" ]; then
  rm "$coredir/ Saturn_latest.rbf"
fi

ln -sf "$corefile" "$coredir/Saturn_latest.rbf"

[ -n "$maxkeep" -a -n "$coredir" -a -n "$corename" ] \
  && { ls -t "${coredir}/${corename}_"*".rbf"|awk "NR>$maxkeep"|xargs -r rm;}

commiturl="https://github.com/srg320/Saturn_MiSTer/commits/master"
gitversion="$(urlcat "$commiturl"|grep "Commits on"|head -1|sed 's,^.*Commits on ,,;s,<.*$,,')"

DS=""

exit 0
