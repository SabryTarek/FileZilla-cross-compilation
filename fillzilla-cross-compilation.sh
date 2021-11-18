#!/bin/bash



#######################################################################################
# Author: Sabry Tarek
# Email: ss.tarek97@gmail.com
# Data: 15/11/2021
# Script Name: fillzilla-cross-compilation.sh
# Description: Cross Compiling FileZilla 3 for Windows under Ubuntu or Debian GNU/Linux
# Args: 
#######################################################################################



# defining dependancies versions
gmp-version="6.2.1"                 # $gmp-version
nettle-version="3.7.3"              # $nettle-version
gnutls-version="3.7.2"              # $gnutls-version
sqlite-autoconf-version="3260000"   # $sqlite-autoconf-version
nsis-version="3.04"                 # $nsis-version
libfilezilla-tags="0.34.0"          # $libfilezilla-tags
FileZilla3-tags="3.56.0"            # $FileZilla3-tags


# Create building envirionmant
mkdir ~/prefix
mkdir ~/src
echo '
export PATH="$HOME/prefix/bin:$PATH"
export LD_LIBRARY_PATH="$HOME/prefix/lib:$LD_LIBRARY_PATH"
export PKG_CONFIG_PATH="$HOME/prefix/lib/pkgconfig:$PKG_CONFIG_PATH"
export TARGET_HOST=x86_64-w64-mingw32
export DEBIAN_FRONTEND=noninteractive
' >> ~/.bashrc
. ~/.bashrc



# Installing Dev dependancies
bash -c '
dpkg --add-architecture i386
apt update -y
apt upgrade -y
apt install -y automake
apt install -y autoconf
apt install -y libtool
apt install -y make
apt install -y gettext
apt install -y lzip
apt install -y mingw-w64
apt install -y pkg-config
apt install -y wx-common
apt install -y wine
apt install -y wine64
apt install -y wine32
apt install -y wine-binfmt
apt install -y subversion
apt install -y git
apt install -y dash
apt install -y git-core
apt install -y autogen
apt install -y nettle-dev
apt install -y libp11-kit-dev
apt install -y libtspi-dev
apt install -y libunistring-dev
apt install -y guile-2.2-dev
apt install -y libtasn1-6-dev
apt install -y libidn2-0-dev
apt install -y gawk
apt install -y libunbound-dev
apt install -y dns-root-data
apt install -y bison
apt install -y texinfo
apt install -y texlive
apt install -y texlive-extra-utils
apt install -y valgrind
apt install -y nodejs
apt install -y softhsm2
apt install -y datefudge
apt install -y lcov
apt install -y libssl-dev
apt install -y libcmocka-dev
apt install -y expect
apt install -y libev-dev
apt install -y dieharder
apt install -y openssl
apt install -y abigail-tools
apt install -y socat
apt install -y net-tools
apt install -y ppp
apt install -y util-linux
apt install -y autopoint
apt install -y gperf
apt install -y gengetopt
apt install -y help2man
apt install -y git2cl
apt install -y gtk-doc-tools
apt install -y abi-compliance-checker
'



# wine intiate 
wine reg add HKCU\\Environment /f /v PATH /d "`x86_64-w64-mingw32-g++ -print-search-dirs | grep ^libraries | sed 's/^libraries: =//' | sed 's/:/;z:/g' | sed 's/^\\//z:\\\\\\\\/' | sed 's/\\//\\\\/g'`"



# Download and compile gmp-6.2.1
cd ~/src
# wget https://gmplib.org/download/gmp/gmp-6.2.1.tar.lz ### Server is down
wget https://ftp.gnu.org/gnu/gmp/gmp-6.2.1.tar.lz
tar xf gmp-6.2.1.tar.lz
cd gmp-6.2.1
CC_FOR_BUILD=gcc ./configure --host=$TARGET_HOST --prefix="$HOME/prefix" --disable-static --enable-shared --enable-fat
make
make install



# Download and compile nettle-3.7.3
cd ~/src
wget https://ftp.gnu.org/gnu/nettle/nettle-3.7.3.tar.gz
tar xf nettle-3.7.3.tar.gz
cd nettle-3.7.3
./configure --host=$TARGET_HOST --prefix="$HOME/prefix" --enable-shared --disable-static --enable-fat LDFLAGS="-L$HOME/prefix/lib" CPPFLAGS="-I$HOME/prefix/include" --enable-mini-gmp
make
make install



# Download and compile libidn2
cd ~/src
git clone --single-branch https://gitlab.com/libidn/libidn2
cd libidn2/
./bootstrap
./configure --host=$TARGET_HOST
make
make install



# Download and compile gnutls-3.7.2
cd ~/src
wget https://www.gnupg.org/ftp/gcrypt/gnutls/v3.7/gnutls-3.7.2.tar.xz
tar xvf gnutls-3.7.2.tar.xz
cd gnutls-3.7.2
#Documentation: ./configure --host=$TARGET_HOST --enable-shared --disable-static --without-p11-kit --with-included-libtasn1 --with-included-unistring --enable-local-libopts --disable-srp-authentication --disable-dtls-srtp-support --disable-heartbeat-support --disable-psk-authentication --disable-anon-authentication --disable-openssl-compatibility --without-tpm --disable-cxx ######################################### missing configration options
./configure --host=$TARGET_HOST --enable-shared --disable-static --without-p11-kit --with-included-libtasn1 --with-included-unistring --enable-local-libopts --disable-srp-authentication --disable-dtls-srtp-support --disable-heartbeat-support --disable-psk-authentication --disable-anon-authentication --disable-openssl-compatibility --without-tpm --disable-cxx LDFLAGS="-L$HOME/prefix/lib" --disable-doc
cp /usr/include/idn2.h ./lib/
make
make install



# Download and compile sqlite-autoconf-32600
cd ~/src
wget https://sqlite.org/2018/sqlite-autoconf-3260000.tar.gz
tar xvzf sqlite-autoconf-3260000.tar.gz
cd sqlite-autoconf-3260000
./configure  --host=$TARGET_HOST --prefix="$HOME/prefix" --enable-shared --disable-static --disable-dynamic-extensions
make
make install



# Download and compile nsis-3.04
cd ~/src
wget https://prdownloads.sourceforge.net/nsis/nsis-3.04-setup.exe
wine nsis-3.04-setup.exe /S
[ -f "$HOME/.wine/drive_c/Program Files/NSIS/makensis.exe" ] && echo "Success!"



# Download and compile wxWidgets
cd ~/src
git clone --branch WX_3_0_BRANCH --single-branch https://github.com/wxWidgets/wxWidgets.git wx3
cd wx3
./configure --host=$TARGET_HOST --prefix="$HOME/prefix" --enable-shared --disable-static
make
make install



cd ~/prefix/lib
for file in *-x86_64-w64-mingw32.dll.a ; do ln -s $file $(echo $file | sed 's/-x86_64-w64-mingw32//g'); done



# Download and compile libfilezilla-0.34.0
cd ~/src
svn co https://svn.filezilla-project.org/svn/libfilezilla/tags/0.34.0 lfz
cd lfz
autoreconf -i
./configure --host=$TARGET_HOST --prefix="$HOME/prefix" --enable-shared --disable-static LDFLAGS="-L$HOME/prefix/lib"
make
make install



cp $HOME/prefix/lib/wx*.dll $HOME/prefix/bin
cp -r ~/src/lfz/lib/libfilezilla ~/prefix/bin
cp -r ~/src/lfz/lib/libfilezilla .



# Download and compile FileZilla3-3.56.0
cd ~/src
svn co https://svn.filezilla-project.org/svn/FileZilla3/tags/3.56.0/ fz
cd fz
autoreconf -i
./configure --host=$TARGET_HOST --prefix="$HOME/prefix" --enable-shared --disable-static --with-pugixml=builtin
make



$TARGET_HOST-strip src/interface/.libs/filezilla.exe
$TARGET_HOST-strip src/putty/.libs/fzsftp.exe
$TARGET_HOST-strip src/putty/.libs/fzputtygen.exe
$TARGET_HOST-strip src/fzshellext/64/.libs/libfzshellext-0.dll
$TARGET_HOST-strip src/fzshellext/32/.libs/libfzshellext-0.dll
$TARGET_HOST-strip data/dlls_gui/*.dll



cd data
wine "$HOME/.wine/drive_c/Program Files (x86)/NSIS/makensis.exe" install.nsi