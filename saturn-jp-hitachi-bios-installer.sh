#!/bin/sh
version=1.4

# ===
bios="8c031bf9908fd0142fdd10a9cdd79389f8a3f2fc"
region="Japan Hitachi"
biosversion="1.03"
name="jp-hitachi"
# ===

biospath=""

corename="Saturn"

self="$(readlink -f "$0")"

conf="${self%.*}.ini"
[ -f "$conf" ] && . "$conf"

trap "result" 0 1 3 15

result(){
  case "$?" in
#    0) echo -e "last version: Github says, last commit on $gitversion"
#       echo -e "core version: ${corefile##*/}\n";;
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

selfurl="https://raw.githubusercontent.com/SwedishGojira/MiSTer-scripts/main/saturn-${name}-bios-installer.sh"
selfurl_version="$(urlcat "$selfurl"|sed -n 's,^version=,,;2p')"

[ "$selfurl_version" = "$version" ] || {
  tempfile="$(mktemp -u)"; download "$tempfile" "$selfurl"
  mv "$tempfile" "$self";chmod +x "$self";exec "$self"; exit 99
}

echo ""
echo -e "█▀▀ █▀▀█ ▀▀█▀▀ █\e[34m░░\e[39m█ █▀▀█ █▀▀▄   █▀▀▄ ▀█▀ █▀▀█ █▀▀ "
echo -e "▀▀█ █▄▄█ \e[34m░░\e[39m█\e[34m░░\e[39m █\e[34m░░\e[39m█ █▄▄▀ █\e[34m░░\e[39m█   █▀▀▄ \e[34m░\e[39m█\e[34m░\e[39m █\e[34m░░\e[39m█ ▀▀█ "
echo -e "▀▀▀ ▀\e[34m░░\e[39m▀ \e[34m░░\e[39m▀\e[34m░░\e[39m \e[34m░\e[39m▀▀▀ ▀\e[34m░\e[39m▀▀ ▀\e[34m░░\e[39m▀   ▀▀▀\e[34m░\e[39m ▀▀▀ ▀▀▀▀ ▀▀▀ "
echo ""
echo -e "█▀▀▄ █▀▀█ █\e[34m░░░\e[39m█ █▀▀▄ █\e[34m░░\e[39m █▀▀█ █▀▀█ █▀▀▄ █▀▀ █▀▀█ "
echo -e "█\e[34m░░\e[39m█ █\e[34m░░\e[39m█ █▄█▄█ █\e[34m░░\e[39m█ █\e[34m░░\e[39m █\e[34m░░\e[39m█ █▄▄█ █\e[34m░░\e[39m█ █▀▀ █▄▄▀ \e[1m\e[34mversion $version\e[0m"
echo -e "▀▀▀\e[34m░\e[39m ▀▀▀▀ \e[34m░\e[39m▀\e[34m░\e[39m▀\e[34m░\e[39m ▀\e[34m░░\e[39m▀ ▀▀▀ ▀▀▀▀ ▀\e[34m░░\e[39m▀ ▀▀▀\e[34m░\e[39m ▀▀▀ ▀\e[34m░\e[39m▀▀ \e[34m░░░░░░░ ░░░\e[39m"
echo ""


# Path Priority (https://mister-devel.github.io/MkDocs_MiSTer/cores/paths/#path-priority)
# There is a priority order of core paths. When you plug in a USB drive and it has a folder /games/Saturn on it (mounted locally as /media/usb<0..5>/games/Saturn when plugged in),
# then the MiSTer Saturn core will look to that folder on the USB drive instead of the local one on the MicroSD at /media/fat/games/Saturn.
# Here is the priority list from Main_MiSTer's file_io.cpp in order of highest priority to lowest:

echo "Detecting $corename file path for bios installation..."

declare -a paths=("/media/fat"
                  "/media/fat/games"
                  "/media/usb0"
                  "/media/usb1"
                  "/media/usb2"
                  "/media/usb3"
                  "/media/usb4"
                  "/media/usb5"
                  "/media/usb0/games"
                  "/media/usb1/games"
                  "/media/usb2/games"
                  "/media/usb3/games"
                  "/media/usb4/games"
                  "/media/usb5/games"
                  "/media/fat/cifs"
                  "/media/fat/cifs/games"
                  )

# You can access them using echo "${paths[0]}", "${paths[1]}" also

## now loop through the above array
for path in "${paths[@]}"; do
  if [ -d "$path/$corename" ]; then
    echo "[X] $path/$corename"
    biospath="$path/$corename"
  else
    echo "[ ] $path/$corename"
  fi
done

if [ "$biospath" = "" ]; then
  biospath="/media/fat/games/$corename"
  echo ""
  echo "No existing $corename folder found!"
  echo "A $corename folder will be created at $biospath"
  mkdir -p "$biospath"
fi

echo ""

biosurl="https://archive.org/download/segasaturnbios/Sega%20Saturn%20BIOS.zip"
bioshash="a8cd8951d07cd9ecdc175e9f0462cfb8"
biosfile="/media/fat/Scripts/saturnbios.zip"
biospack="/media/fat/Scripts/.saturn-bios"

if [ ! -d "$biospack" ]; then
  mkdir -p "$biospack"
  echo "Downloading Saturn bios pack..."
  download "$biosfile" "$biosurl"
  [ -n "$bioshash" ] && checksum "$biosfile" "$bioshash"
  unpack "$biosfile" "$biospack"
  rm "$biosfile"
  cd "$biospack"
  for i in *.bin; do
    sum=$(sha1sum "$i" | cut -f 1 -d ' ')
    mv "$i" "$sum"
  done
fi
echo "Installing $corename bios into $biospath..."
if [ -f "$biospath/boot.bin" ]; then
  rm "$biospath/boot.bin"
fi
cp "$biospack/${bios}" "$biospath/boot.rom"
echo "Finished installing Saturn bios ${biosversion} ${region} version in $biospath" 

echo ""
