#!/bin/sh

APP=obs-studio

# THIS WILL DO ALL WORK INTO THE CURRENT DIRECTORY
HOME="$(dirname "$(readlink -f $0)")" 

# DOWNLOAD AND INSTALL JUNEST
git clone https://github.com/fsquillace/junest.git ~/.local/share/junest
./.local/share/junest/bin/junest setup

# CUSTOM MIRRORLIST, THIS SHOULD SPEEDUP THE INSTALLATION OF THE PACKAGES IN PACMAN (COMMENT EVERYTHING TO USE THE DEFAULT MIRROR)
rm -R ./.junest/etc/pacman.d/mirrorlist
COUNTRY=$(curl -i ipinfo.io | grep country | cut -c 15- | cut -c -2)
wget -q https://archlinux.org/mirrorlist/?country="$(echo $COUNTRY)" -O - | sed 's/#Server/Server/g' >> ./.junest/etc/pacman.d/mirrorlist

# INSTALL OBS AND PYTHON
./.local/share/junest/bin/junest -- sudo pacman -Syy
./.local/share/junest/bin/junest -- sudo pacman --noconfirm -Syu
./.local/share/junest/bin/junest -- sudo pacman --noconfirm -S $APP python3

# SET THE LOCALE
#sed "s/# /#>/g" ./.junest/etc/locale.gen | sed "s/#//g" | sed "s/>/#/g" >> ./locale.gen # ENABLE ALL THE LANGUAGES
#sed "s/#$(echo $LANG)/$(echo $LANG)/g" ./.junest/etc/locale.gen >> ./locale.gen # ENABLE ONLY ONE LANGUAGE
#rm -R ./.junest/etc/locale.gen
#mv ./locale.gen ./.junest/etc/locale.gen
rm ./.junest/etc/locale.conf
#echo "LANG=$LANG" >> ./.junest/etc/locale.conf
sed -i 's/LANG=${LANG:-C}/LANG=$LANG/g' ./.junest/etc/profile.d/locale.sh
#./.local/share/junest/bin/junest -- sudo pacman --noconfirm -S glibc gzip
#./.local/share/junest/bin/junest -- sudo locale-gen

# VERSION NAME
VERSION=$(wget -q https://archlinux.org/packages/extra/x86_64/$APP/ -O - | grep $APP | head -1 | grep -o -P '(?<='$APP' ).*(?=</)' | tr -d " (x86_64)")

# CREATE THE APPDIR
wget -q https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage -O appimagetool
chmod a+x appimagetool
mkdir $APP.AppDir
cp -r ./.local ./$APP.AppDir/
cp -r ./.junest ./$APP.AppDir/
cp ./$APP.AppDir/.junest/usr/share/icons/hicolor/scalable/apps/*obs* ./$APP.AppDir/
cp ./$APP.AppDir/.junest/usr/share/applications/*obs* ./$APP.AppDir/
cat >> ./$APP.AppDir/AppRun << 'EOF'
#!/bin/sh
HERE="$(dirname "$(readlink -f $0)")"
export UNION_PRELOAD=$HERE
export JUNEST_HOME=$HERE/.junest
export PATH=$HERE/.local/share/junest/bin/:$PATH
mkdir -p $HOME/.cache
echo "obs $@" | $HERE/.local/share/junest/bin/junest proot -n
EOF
chmod a+x ./$APP.AppDir/AppRun

# REMOVE "READ-ONLY FILE SYSTEM" ERRORS
sed -i 's#${JUNEST_HOME}/usr/bin/junest_wrapper#${HOME}/.cache/junest_wrapper.old#g' ./$APP.AppDir/.local/share/junest/lib/core/wrappers.sh
sed -i 's/rm -f "${JUNEST_HOME}${bin_path}_wrappers/#rm -f "${JUNEST_HOME}${bin_path}_wrappers/g' ./$APP.AppDir/.local/share/junest/lib/core/wrappers.sh
sed -i 's/ln/#ln/g' ./$APP.AppDir/.local/share/junest/lib/core/wrappers.sh

# REMOVE SOME BLOATWARES
rm -R -f ./$APP.AppDir/.junest/var
rm -R -f ./$APP.AppDir/.junest/usr/lib/liblsan.so*
rm -R -f ./$APP.AppDir/.junest/usr/lib/libtsan.so*
rm -R -f ./$APP.AppDir/.junest/usr/lib/libgfortran.so*
rm -R -f ./$APP.AppDir/.junest/usr/lib/libgo.so*
rm -R -f ./$APP.AppDir/.junest/usr/lib/libphobos.so*
rm -R -f ./$APP.AppDir/.junest/usr/lib/libOSMesa.so*
rm -R -f ./$APP.AppDir/.junest/usr/lib/libPyImath_Python*
rm -R -f ./$APP.AppDir/.junest/usr/lib/libasan.so*
rm -R -f ./$APP.AppDir/.junest/usr/lib/d3d
rm -R -f ./$APP.AppDir/.junest/usr/lib/dri/crocus_dri.so
rm -R -f ./$APP.AppDir/.junest/usr/lib/dri/d3d12_dri.so
rm -R -f ./$APP.AppDir/.junest/usr/lib/dri/i*
rm -R -f ./$APP.AppDir/.junest/usr/lib/dri/kms_swrast_dri.so
rm -R -f ./$APP.AppDir/.junest/usr/lib/dri/r*
rm -R -f ./$APP.AppDir/.junest/usr/lib/dri/nouveau_dri.so
rm -R -f ./$APP.AppDir/.junest/usr/lib/dri/radeonsi_dri.so
rm -R -f ./$APP.AppDir/.junest/usr/lib/dri/virtio_gpu_dri.so
rm -R -f ./$APP.AppDir/.junest/usr/lib/dri/vmwgfx_dri.so
rm -R -f ./$APP.AppDir/.junest/usr/lib/dri/zink_dri.so
rm -R -f ./$APP.AppDir/.junest/usr/lib/systemd*
rm -R -f ./$APP.AppDir/.junest/usr/lib/audit ./$APP.AppDir/.junest/usr/lib/avahi ./$APP.AppDir/.junest/usr/lib/awk ./$APP.AppDir/.junest/usr/lib/bash ./$APP.AppDir/.junest/usr/lib/bellagio ./$APP.AppDir/.junest/usr/lib/bfd-plugins ./$APP.AppDir/.junest/usr/lib/binfmt.d ./$APP.AppDir/.junest/usr/lib/cairo ./$APP.AppDir/.junest/usr/lib/cmake ./$APP.AppDir/.junest/usr/lib/coreutils ./$APP.AppDir/.junest/usr/lib/cryptsetup ./$APP.AppDir/.junest/usr/lib/dbus-1.0 ./$APP.AppDir/.junest/usr/lib/depmod.d ./$APP.AppDir/.junest/usr/lib/e2fsprogs ./$APP.AppDir/.junest/usr/lib/engines-3 ./$APP.AppDir/.junest/usr/lib/environment.d ./$APP.AppDir/.junest/usr/lib/gawk ./$APP.AppDir/.junest/usr/lib/gconv ./$APP.AppDir/.junest/usr/lib/gdk-pixbuf-2.0 ./$APP.AppDir/.junest/usr/lib/getconf ./$APP.AppDir/.junest/usr/lib/gettext ./$APP.AppDir/.junest/usr/lib/gimp ./$APP.AppDir/.junest/usr/lib/gio ./$APP.AppDir/.junest/usr/lib/girepository-1.0 ./$APP.AppDir/.junest/usr/lib/git-core ./$APP.AppDir/.junest/usr/lib/glib-2.0 ./$APP.AppDir/.junest/usr/lib/gnupg ./$APP.AppDir/.junest/usr/lib/icu ./$APP.AppDir/.junest/usr/lib/initcpio ./$APP.AppDir/.junest/usr/lib/kernel ./$APP.AppDir/.junest/usr/lib/krb5 ./$APP.AppDir/.junest/usr/lib/libcamera ./$APP.AppDir/.junest/usr/lib/libfakeroot ./$APP.AppDir/.junest/usr/lib/libinput ./$APP.AppDir/.junest/usr/lib/libnl ./$APP.AppDir/.junest/usr/lib/libv4l ./$APP.AppDir/.junest/usr/lib/locale ./$APP.AppDir/.junest/usr/lib/modprobe.d ./$APP.AppDir/.junest/usr/lib/modules-load.d ./$APP.AppDir/.junest/usr/lib/mpg123 ./$APP.AppDir/.junest/usr/lib/objects-RelWithDebInfo ./$APP.AppDir/.junest/usr/lib/omxloaders ./$APP.AppDir/.junest/usr/lib/openjpeg-2.5 ./$APP.AppDir/.junest/usr/lib/ossl-modules ./$APP.AppDir/.junest/usr/lib/p11-kit ./$APP.AppDir/.junest/usr/lib/pam.d ./$APP.AppDir/.junest/usr/lib/perl5 ./$APP.AppDir/.junest/usr/lib/pkcs11 ./$APP.AppDir/.junest/usr/lib/pkgconfig ./$APP.AppDir/.junest/usr/lib/python3.11 ./$APP.AppDir/.junest/usr/lib/sasl2 ./$APP.AppDir/.junest/usr/lib/security ./$APP.AppDir/.junest/usr/lib/spa-0.2 ./$APP.AppDir/.junest/usr/lib/sysctl.d ./$APP.AppDir/.junest/usr/lib/sysusers.d ./$APP.AppDir/.junest/usr/lib/tmpfiles.d ./$APP.AppDir/.junest/usr/lib/ts ./$APP.AppDir/.junest/usr/lib/udev ./$APP.AppDir/.junest/usr/lib/utempter ./$APP.AppDir/.junest/usr/lib/vdpau ./$APP.AppDir/.junest/usr/lib/xkbcommon ./$APP.AppDir/.junest/usr/lib/xtables

mkdir ./save
mv ./$APP.AppDir/.junest/usr/share/obs ./save/obs
mv ./$APP.AppDir/.junest/usr/share/glvnd ./save/glvnd
rm -R -f ./$APP.AppDir/.junest/usr/share/*
mv ./save/* ./$APP.AppDir/.junest/usr/share/

# REMOVE THE INBUILT HOME
rm -R -f ./$APP.AppDir/.junest/home

# CREATE THE APPIMAGE
ARCH=x86_64 ./appimagetool -n ./$APP.AppDir
mv ./*AppImage ./OBS-Studio_$VERSION-x86_64.AppImage
