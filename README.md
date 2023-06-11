# OBS-Studio-appimage
OBS Studio AppImage created from the official PPA.

#### WARNING: this build is higly experimental, this repo only provides a builder ([here](https://raw.githubusercontent.com/ivan-hc/OBS-Studio-appimage/main/obs-studio))... any help appreciated!

## How to test
- Download the last experimental build from [here](https://github.com/ivan-hc/OBS-Studio-appimage/releases/tag/continuous)
- Now make the AppImage executable (command `chmod a+x ./*.AppImage`)
- Extract the AppImage (command `./*AppImage --appimage-extract`)
- Run the AppRun (command `cd ./squashfs-root && ./AppRun`) and check the AppDir (ie `./squashfs-root`) in case of issues.
