

###
### This is made for ubuntu
###

INTERFACE='eth0'

## install elastic repositories
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb https://artifacts.elastic.co/packages/6.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-6.x.list

## apt goodies
apt update
apt -y install openjdk-8-jdk openjdk-8-jre
apt -y install gcc build-essential screen libmaxminddb-dev libgoogle-perftools-dev 
apt -y install cmake make gcc g++ flex bison libpcap-dev libssl-dev python-dev swig zlib1g-dev
apt -y install logstash


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
cd /root/build/
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
rm- fr GeoLite*

## DOWNLOAD BRO
cd /root/build/
wget `curl https://www.zeek.org/download/index.html | grep "gz" | grep "bro-" | grep -v beta | grep -v aux | grep -v asc | cut -d'"' -f2`
rm -fr *-beta.txxxxxxxxxxxxxxxxxxxxxxxxxxxar.gz
tar -xvzf bro-2.*.tar.gz
rm bro-2*.gz
cd bro-2.*
./configure --prefix=/nsm/bro
make
make install

## Set Interface
cat /nsm/bro/etc/node.cfg | sed -e "s/interface\=eth0/interface\=$INTERFACE/g" > /tmp/node.cfg
mv -f /tmp/node.cfg /nsm/bro/etc/node.cfg

export PATH=/nsm/bro/bin:$PATH
/nsm/bro/bin/broctl install
/nsm/bro/bin/broctl start

cd /root/build/

#### Logstash
rm /etc/logstash/logstash-sample.conf
/usr/share/logstash/bin/logstash-plugin install logstash-filter-translate

##UPDATEGEOLITE
echo "
cd /root/build/
wget https://geolite.maxmind.com/download/geoip/database/GeoLite2-City.tar.gz
wget https://geolite.maxmind.com/download/geoip/database/GeoLite2-Country.tar.gz
wget https://geolite.maxmind.com/download/geoip/database/GeoLite2-ASN.tar.gz

tar zxvf GeoLite2-City.tar.gz
tar zxvf GeoLite2-Country.tar.gz
tar zxvf GeoLite2-ASN.tar.gz

mv -f GeoLite2-City_*/GeoLite2-City.mmdb  /usr/share/GeoIP/GeoLite2-City.mmdb
mv -f GeoLite2-Country_*/GeoLite2-Country.mmdb  /usr/share/GeoIP/GeoLite2-Country.mmdb
mv -f GeoLite2-ASN_*/GeoLite2-ASN.mmdb  /usr/share/GeoIP/GeoLite2-ASN.mmdb

rm- fr GeoLite*
" > /root/geoupdate.sh

chmod +x geoupdate.sh

#### Cleanup
echo "net.ipv4.tcp_keepalive_intvl=570" >> /etc/sysctl.conf

mv /etc/ssh/sshd_config /etc/ssh/sshd_config.old
cat /etc/ssh/sshd_config.old | sed '/Port 22$/c\Port 42224' > /etc/ssh/sshd_config
service ssh restart

