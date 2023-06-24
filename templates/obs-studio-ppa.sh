#!/bin/sh

APP=obs-studio

mkdir -p tmp
cd tmp

# DOWNLOADING THE DEPENDENCIES
if test -f ./appimagetool; then
	echo " appimagetool already exists" 1> /dev/null
else
	echo " Downloading appimagetool..."
	wget -q https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage -O appimagetool
fi
if test -f ./pkg2appimage; then
	echo " pkg2appimage already exists" 1> /dev/null
else
	echo " Downloading pkg2appimage..."
	wget -q https://raw.githubusercontent.com/ivan-hc/AM-application-manager/main/tools/pkg2appimage
fi
chmod a+x ./appimagetool ./pkg2appimage

# CREATING THE APPIMAGE: APPDIR FROM A RECIPE...

PREVIOUSLTS=$(wget -q https://releases.ubuntu.com/ -O - | grep class | grep LTS | grep -m2 href | tail -n1 | sed -n 's/.*href="\([^"]*\).*/\1/p' | rev| cut -c 2- | rev)
DEB=$(wget -q https://ppa.launchpadcontent.net/obsproject/obs-studio/ubuntu/pool/main/o/obs-studio/ -O - | grep $PREVIOUSLTS | grep amd64.deb | grep -o -P '(?<=href=").*(?=">obs)')
wget https://ppa.launchpadcontent.net/obsproject/obs-studio/ubuntu/pool/main/o/obs-studio/$DEB
ar x ./*.deb
tar fx ./control.tar.xz

mkdir -p $APP
mv ./$DEB ./$APP/

# ...COMPILE THE RECIPE...
rm -f ./recipe.yml
echo "app: $APP
binpatch: true
ingredients:
  dist: $PREVIOUSLTS
  sources:
    - deb http://archive.ubuntu.com/ubuntu/ $PREVIOUSLTS main universe restricted multiverse
    - deb http://archive.ubuntu.com/ubuntu $PREVIOUSLTS-security main universe restricted multiverse
    - deb http://archive.ubuntu.com/ubuntu/ $PREVIOUSLTS-updates main universe restricted multiverse
  ppas:
    - obsproject/obs-studio
  packages:
    - obs-studio
    - ffmpeg
    - libpangocairo-1.0-0
    - libpangoft2-1.0-0
    - v4l2loopback-dkms" >> recipe.yml

echo "" >> deps
cat control | grep -e "Depends:" | tr ' ' '\n' | grep -w -v '(' | grep -w -v ',' | grep -w -v '|' | grep -w -v ')' | tr ',' '\n' | grep -w -v "" >> deps
ARGS=$(sed '1d' ./deps)
for arg in $ARGS; do echo "    - $arg" >> ./recipe.yml; done

# ...RUN PKG2APPIMAGE...
./pkg2appimage ./recipe.yml

# ...DOWNLOADING LIBUNIONPRELOAD...
wget https://github.com/project-portable/libunionpreload/releases/download/amd64/libunionpreload.so
chmod a+x libunionpreload.so
mv ./libunionpreload.so ./$APP/$APP.AppDir/

# ...REPLACING THE EXISTING APPRUN WITH A CUSTOM ONE...
rm -R -f ./$APP/$APP.AppDir/AppRun
cat >> ./$APP/$APP.AppDir/AppRun << 'EOF'
#!/bin/bash
HERE="$(dirname "$(readlink -f $0)")"
export UNION_PRELOAD=$HERE
export LD_PRELOAD=$HERE/libunionpreload.so
export PATH=$HERE/usr/bin/:$HERE/usr/sbin/:$HERE/bin/:$HERE/sbin/:$PATH
export LD_LIBRARY_PATH=/lib/:/lib64/:/usr/lib/:/usr/lib/x86_64-linux-gnu/:$HERE/usr/lib/x86_64-linux-gnu/obs-plugins/:$HERE/usr/lib/x86_64-linux-gnu/cmake/libobs/:$HERE/usr/lib/x86_64-linux-gnu/cmake/obs-frontend-api/:$HERE/usr/lib/x86_64-linux-gnu/obs-scripting/:$HERE/usr/lib/:$HERE/usr/lib/x86_64-linux-gnu/:$HERE/lib/:$HERE/lib/x86_64-linux-gnu/:$HERE/usr/lib/gcc/x86_64-linux-gnu/9/:$HERE/usr/lib/python3.8/lib-dynload/:$LD_LIBRARY_PATH
export FFMPEG_CODEC_PATH=$HERE/usr/lib/x86_64-linux-gnu/:$LD_CODEC_PATH
export PYTHONPATH=$HERE/usr/lib/python3.8/:$HERE/usr/lib/python3.8/lib-dynload/:$PYTHONPATH
export XDG_DATA_DIRS=$HERE/usr/share/:$XDG_DATA_DIRS
export PERL5LIB=$HERE/usr/share/perl5/:$HERE/usr/lib/perl5/:$PERLLIB
export GSETTINGS_SCHEMA_DIR=$HERE/usr/share/glib-2.0/schemas/:$GSETTINGS_SCHEMA_DIR
export QT_PLUGIN_PATH=$HERE/lib/:$HERE/usr/lib/:$HERE/usr/lib/x86_64-linux-gnu/qt5/plugins/:$HERE/usr/lib/x86_64-linux-gnu/obs-plugins/:$QT_PLUGIN_PATH
ls /etc/ssl/certs/ca-certificates.crt > /dev/null 2>&1 && REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt
ls /etc/pki/tls/certs/ca-bundle.crt > /dev/null 2>&1 && REQUESTS_CA_BUNDLE=/etc/pki/tls/certs/ca-bundle.crt
export REQUESTS_CA_BUNDLE=${REQUESTS_CA_BUNDLE}
exec $HERE/usr/bin/obs "$@"

EOF
chmod a+x ./$APP/$APP.AppDir/AppRun

# ...IMPORT THE LAUNCHER AND THE ICON TO THE APPDIR (uncomment if not available)...
#cp ./$APP/$APP.AppDir/usr/share/icons/hicolor/22x22/apps/* ./$APP/$APP.AppDir/ 2>/dev/null
#cp ./$APP/$APP.AppDir/usr/share/icons/hicolor/24x24/apps/* ./$APP/$APP.AppDir/ 2>/dev/null
#cp ./$APP/$APP.AppDir/usr/share/icons/hicolor/32x32/apps/* ./$APP/$APP.AppDir/ 2>/dev/null
#cp ./$APP/$APP.AppDir/usr/share/icons/hicolor/48x48/apps/* ./$APP/$APP.AppDir/ 2>/dev/null
#cp ./$APP/$APP.AppDir/usr/share/icons/hicolor/64x64/apps/* ./$APP/$APP.AppDir/ 2>/dev/null
#cp ./$APP/$APP.AppDir/usr/share/icons/hicolor/128x128/apps/* ./$APP/$APP.AppDir/ 2>/dev/null
cp ./$APP/$APP.AppDir/usr/share/icons/hicolor/256x256/apps/* ./$APP/$APP.AppDir/ 2>/dev/null
#cp ./$APP/$APP.AppDir/usr/share/icons/hicolor/512x512/apps/* ./$APP/$APP.AppDir/ 2>/dev/null
#cp ./$APP/$APP.AppDir/usr/share/icons/hicolor/scalable/apps/* ./$APP/$APP.AppDir/ 2>/dev/null
cp ./$APP/$APP.AppDir/usr/share/applications/* ./$APP/$APP.AppDir/ 2>/dev/null

# ...EXPORT THE APPDIR TO AN APPIMAGE!
ARCH=x86_64 ./appimagetool -n ./$APP/$APP.AppDir;
mkdir version
mv ./$APP/$APP$underscore*.deb ./version/
version=$(ls ./version | cut -c 12- | rev | cut -c 11- | rev)

cd ..
mv ./tmp/*.AppImage ./OBS-Studio-$version-x86_64.AppImage
