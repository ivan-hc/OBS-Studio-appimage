This is an attempt to create OBS Studio AppImage from the official PPA.

## WARNING: 
#### *This build is higly experimental, this repo only provides the scripts to build an experimental version of OBS Studio from many different sources. Any help appreciated!*

## How to test
- Download the last experimental build from [here](https://github.com/ivan-hc/OBS-Studio-appimage/releases/tag/continuous)
- Now make the AppImage executable (command `chmod a+x ./*.AppImage`)
- Extract the AppImage (command `./*AppImage --appimage-extract`)
- Run the AppRun (command `cd ./squashfs-root && ./AppRun`) and check the AppDir (ie `./squashfs-root`) in case of issues.
