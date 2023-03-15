# MiSTer-scripts
Third party scripts for MiSTer FPGA

## Saturn core updater scripts
Small scripts that will download the latest successful build of the Saturn core from  from the workflow of [srg320's official Saturn repo on Github](https://github.com/srg320/Saturn_MiSTer).

- If you only want the single SDRAM version just get the "saturn-updater..." script.
- If you want to download the dual SDRAM version of the core get both scripts as the "saturn_ds-updater..." is calling the standard script for all the work.

As the builds on srg320's github are only available for 90 days before they are automatically deleted the script will now use the unstable builds from [MiSTer-unstable-nightlies /
Saturn_MiSTer](https://github.com/MiSTer-unstable-nightlies/Saturn_MiSTer) as backup.
