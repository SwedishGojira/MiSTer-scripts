# MiSTer-scripts
Third party scripts for MiSTer FPGA

> [!IMPORTANT]
> All of my scripts are made to be run directly on the MiSTer from the standard /media/fat/Scripts directory.



## Saturn core updater scripts
Small scripts that will download the latest successful build of the Saturn core from  from the workflow of [srg320's official Saturn repo on Github](https://github.com/srg320/Saturn_MiSTer).

- If you only want the single SDRAM version just get the "saturn-updater..." script.
- If you want to download the dual SDRAM version of the core get both scripts as the "saturn_ds-updater..." is calling the standard script for all the work.

As the builds on srg320's github are only available for 90 days before they are automatically deleted the script will now use the unstable builds from [MiSTer-unstable-nightlies /
Saturn_MiSTer](https://github.com/MiSTer-unstable-nightlies/Saturn_MiSTer) as backup.


## Saturn bios installer scripts
Small scripts that will download and install the US, JP or JP Hitachi recommended bios for the Saturn core.

You only need to install one of the bios, not both. Just make sure you set the region in the core settings to the region matching the game you are loading and it should be working.

> [!NOTE]
> The Saturn core is still under heavy development and the bios have fluctuated between being called boot.rom and boot.bin.
> Therefore the bios scripts is made to remove any old bios.bin file and replace it with the downloaded boot.rom which is the correct name for the bios at the moment of writing.


## N64 bios installer scripts
Small script that will download and install the recommended NTSC and PAL bioses for the N64 core.
