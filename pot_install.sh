

###
### This is made for ubuntu
###

INTERFACE='eth0'

apt update
apt -y install gcc build-essential screen libmaxminddb-dev libgoogle-perftools-dev
apt -y install cmake make gcc g++ flex bison libpcap-dev libssl-dev python-dev swig zlib1g-dev

##HOSTNAME
OLDHOSTNAME=`cat /etc/hostname`
echo DARKNET-`/sbin/ifconfig $INTERFACE | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`> /etc/hostname
NEWHOSTNAME=`cat /etc/hostname`
hostname $NEWHOSTNAME
cat /etc/hosts | sed  s/$OLDHOSTNAME/$NEWHOSTNAME/g > /tmp/hosts
mv -f /tmp/hosts /etc/hosts
echo -e "127.0.0.1\t$NEWHOSTNAME" >> /etc/hosts

mkdir /root/build

### INSTALL GEO
wget https://geolite.maxmind.com/download/geoip/database/GeoLite2-City.tar.gz
wget https://geolite.maxmind.com/download/geoip/database/GeoLite2-Country.tar.gz
wget https://geolite.maxmind.com/download/geoip/database/GeoLite2-ASN.tar.gz

tar zxvf GeoLite2-City.tar.gz
tar zxvf GeoLite2-Country.tar.gz
tar zxvf GeoLite2-ASN.tar.gz

mv GeoLite2-City_*/GeoLite2-City.mmdb  /usr/share/GeoIP/GeoLite2-City.mmdb
mv GeoLite2-Country_*/GeoLite2-Country.mmdb  /usr/share/GeoIP/GeoLite2-Country.mmdb
mv GeoLite2-ASN_*/GeoLite2-ASN.mmdb  /usr/share/GeoIP/GeoLite2-ASN.mmdb

ln -s /usr/share/GeoIP/GeoLite2-City.mmdb /usr/share/GeoIP/Geo2-City.mmdb
ln -s /usr/share/GeoIP/GeoLite2-Country.mmdb /usr/share/GeoIP/Geo2-Country.mmdb
ln -s /usr/share/GeoIP/GeoLite2-ASN.mmdb /usr/share/GeoIP/Geo2-ASN.mmdb

## DOWNLOAD BRO
wget `curl https://www.zeek.org/download/index.html | grep "gz" | grep "bro-" | grep -v beta | grep -v aux | grep -v asc | cut -d'"' -f2`
rm -fr *-beta.tar.gz
tar -xvzf bro-2.*.tar.gz

