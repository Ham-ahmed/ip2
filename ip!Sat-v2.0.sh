#!/bin/sh

#remove unnecessary files and folders
if [  -d "/CONTROL" ]; then
rm -r  /CONTROL >/dev/null 2>&1
fi
rm -rf /control >/dev/null 2>&1
rm -rf /postinst >/dev/null 2>&1
rm -rf /preinst >/dev/null 2>&1
rm -rf /prerm >/dev/null 2>&1
rm -rf /postrm >/dev/null 2>&1
rm -rf /tmp/*.ipk >/dev/null 2>&1
rm -rf /tmp/*.tar.gz >/dev/null 2>&1

#config
plugin=IP2SAT
version=2.0
url=https://raw.githubusercontent.com/Ham-ahmed/ip2/refs/heads/main/iptosat.tar.gz
package=/var/volatile/tmp/$plugin-$version.tar.gz

#download & install
echo "> Downloading $plugin-$version package  please wait ..."
sleep 3s

wget --show-progress -qO $package --no-check-certificate $url
tar -xzf $package -C /
extract=$?
rm -rf $package >/dev/null 2>&1

echo ''
if [ $extract -eq 0 ]; then
echo "#########################################################"
echo "#                 Installation Complete!                #"
echo "#                  Enjoy with plugin!                   #"
echo "#                 MagicPanelGold v10.9                  #"
echo "#             Enigma2 restart is required               #"
echo "#        .::UPLOADED BY  >>>>   HAMDY_AHMED::.          #"
echo "#     https://www.facebook.com/share/g/18qCRuHz26/      #"
echo "#########################################################"
echo "#           your Device will RESTART Now                #"
echo "#########################################################"

# Countdown 3 seconds
echo -n "> Restarting in "
for i in 3 2 1; do
    echo -n "$i... "
    sleep 1
done
echo ""

# Restart enigma2
init 4 >/dev/null 2>&1
sleep 2
init 3 >/dev/null 2>&1

else

echo "> $plugin-$version package installation failed"
sleep 3s
fi

exit 0