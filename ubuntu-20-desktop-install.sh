#!/bin/bash
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root, please use sudo" 
   exit 1
fi
echo "--------------------------------------------"
echo "[+] Updating and upgrading existing packages"
echo "--------------------------------------------"
apt update -y
apt upgrade -y

echo "--------------------------------------------"
echo "[+] Adding BladeRF Support and Git"
echo "--------------------------------------------"
apt install -y software-properties-common git
add-apt-repository -y ppa:nuandllc/bladerf

git clone https://github.com/AndrewMohawk/trunkrecorder-helpers.git
cd trunkrecorder-helpers
mkdir -p /app/media
mkdir -p /app/config
cp config/config.json /app/config
cp config/talkgroup-trunkrecorder-format.csv /app
sudo chmod 777 /app/config/config.json
sudo chmod 777 /app/talkgroup-trunkrecorder-format.csv

echo "---------------------------------------------------"
echo "[+] Installing Packages.. this might take a while.."
echo "---------------------------------------------------"
apt install -y gr-osmosdr osmo-sdr libosmosdr0 libosmosdr-dev libuhd3.15.0 libuhd-dev gnuradio-dev libgnuradio-uhd3.8.1 libgnuradio-osmosdr0.2.0 hackrf libhackrf-dev libhackrf0 git gcc cpp cmake make build-essential libboost-all-dev libusb-1.0-0 libusb-dev fdkaac libfdk-aac-dev libfdk-aac1 libsox3 libsox-dev libsoxr0 sox ffmpeg libaacs0 libcppunit-dev libcppunit-1.15-0 libvo-aacenc0 libssl-dev openssl curl libcurl4 libcurl4-openssl-dev gnuradio libuhd-dev libcurl3-gnutls bladerf libbladerf-dev libtecla1  libncurses5-dev libtecla-dev pkg-config wget gqrx-sdr liborc-0.4-dev autoconf automake build-essential libass-dev libfreetype6-dev libtool pkg-config texinfo zlib1g-dev yasm libfdk-aac-dev

echo "--------------------------------------------"
echo "[+] Setting Locale"
echo "--------------------------------------------"
apt-get install -y locales \
    && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
    && locale-gen

echo "--------------------------------------------"
echo "[+] Creating temporary directories for build and copying/applying patches"
echo "--------------------------------------------"
mkdir -p /tmp/trunk-recorder-build/
mkdir -p /tmp/trunk-recorder-build/patches
cp patches/* /tmp/trunk-recorder-build/patches
cd /tmp/trunk-recorder-build/
git clone https://github.com/robotastic/trunk-recorder.git src
mv src/* .
cat /tmp/trunk-recorder-build/patches/*.patch | patch -p1
mkdir -p /tmp/trunk-recorder-build/build/
cd /tmp/trunk-recorder-build/build/

echo "--------------------------------------------"
echo "[+] Building trunk recorder... this will take a while"
echo "--------------------------------------------"
cmake ../
make 
make install
cp ./recorder /app/trunk-recorder

sed -i 's/log_level = debug/log_level = info/g' /etc/gnuradio/conf.d/gnuradio-runtime.conf 

echo "--------------------------------------------------------------------------"
echo "[+] Completed. You can now copy your config file and start trunk-recorder"
echo "--------------------------------------------------------------------------"