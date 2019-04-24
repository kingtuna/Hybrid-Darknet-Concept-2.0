

###
### This is made for ubuntu
###

INTERFACE='eth0'
RABBIT_USER='amp'
RABBIT_PASSWORD='password'
RABBIT_HOST='1.1.1.1'

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
echo "DARKNET-"`/sbin/ifconfig $INTERFACE | grep 'inet ' | awk '{print $2}'`
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

printf 'aW5wdXQgewogIGZpbGUgewogICAgcGF0aCA9PiBbICIvbnNtL2Jyby9sb2dzL2N1cnJlbnQvY29u
bi5sb2ciIF0gIyBhcnJheSAocmVxdWlyZWQpCiAgICB0eXBlID0+ICJicm8iCiAgICB0YWdzID0+
IFsgImJyb19jb25uIiBdCiAgfQp9CgpmaWx0ZXIgewogIGlmIFttZXNzYWdlXSA9fiAvXiMvIHsK
ICAgIGRyb3AgeyB9CiAgfSAjZW5kIGlmCgogICMjIyNiZWdpbiBicm9fY29ubiMjIyMKICAjIyBU
aGFuayBZb3UgaHR0cHM6Ly9naXRodWIuY29tL3NpbHRlY29uL2Jyb25pb24vYmxvYi9tYXN0ZXIv
cGlwZWxpbmUuZC9pbnB1dF9icm9fZmlsZQogIGlmICJicm9fY29ubiIgaW4gW3RhZ3NdIHsKICAg
IGNzdiB7CiAgICAgIGNvbHVtbnMgPT4gWyJ0cyIsInVpZCIsImlkLm9yaWdfaCIsImlkLm9yaWdf
cCIsImlkLnJlc3BfaCIsImlkLnJlc3BfcCIsInByb3RvIiwic2VydmljZSIsImR1cmF0aW9uIiwi
b3JpZ19ieXRlcyIsInJlc3BfYnl0ZXMiLCJjb25uX3N0YXRlIiwibG9jYWxfb3JpZyIsImxvY2Fs
X3Jlc3AiLCJtaXNzZWRfYnl0ZXMiLCJoaXN0b3J5Iiwib3JpZ19wa3RzIiwib3JpZ19pcF9ieXRl
cyIsInJlc3BfcGt0cyIsInJlc3BfaXBfYnl0ZXMiLCJ0dW5uZWxfcGFyZW50cyJdCiAgICAgIHNl
cGFyYXRvciA9PiAiCSIKICAgIH0gI2VuZCBjc3YKICAgIHRyYW5zbGF0ZSB7CiAgICAgIGZpZWxk
ID0+ICJjb25uX3N0YXRlIgogICAgICBkZXN0aW5hdGlvbiA9PiAiY29ubl9zdGF0ZV9mdWxsIgog
ICAgICBkaWN0aW9uYXJ5ID0+IFsKICAgICAgICAiUzAiLCAiQ29ubmVjdGlvbiBhdHRlbXB0IHNl
ZW4sIG5vIHJlcGx5IiwKICAgICAgICAiUzEiLCAiQ29ubmVjdGlvbiBlc3RhYmxpc2hlZCwgbm90
IHRlcm1pbmF0ZWQiLAogICAgICAgICJTMiIsICJDb25uZWN0aW9uIGVzdGFibGlzaGVkIGFuZCBj
bG9zZSBhdHRlbXB0IGJ5IG9yaWdpbmF0b3Igc2VlbiAoYnV0IG5vIHJlcGx5IGZyb20gcmVzcG9u
ZGVyKSIsCiAgICAgICAgIlMzIiwgIkNvbm5lY3Rpb24gZXN0YWJsaXNoZWQgYW5kIGNsb3NlIGF0
dGVtcHQgYnkgcmVzcG9uZGVyIHNlZW4gKGJ1dCBubyByZXBseSBmcm9tIG9yaWdpbmF0b3IpIiwK
ICAgICAgICAiU0YiLCAiTm9ybWFsIFNZTi9GSU4gY29tcGxldGlvbiIsCiAgICAgICAgIlJFSiIs
ICJDb25uZWN0aW9uIGF0dGVtcHQgcmVqZWN0ZWQiLAogICAgICAgICJSU1RPIiwgIkNvbm5lY3Rp
b24gZXN0YWJsaXNoZWQsIG9yaWdpbmF0b3IgYWJvcnRlZCAoc2VudCBhIFJTVCkiLAogICAgICAg
ICJSU1RSIiwgIkVzdGFibGlzaGVkLCByZXNwb25kZXIgYWJvcnRlZCIsCiAgICAgICAgIlJTVE9T
MCIsICJPcmlnaW5hdG9yIHNlbnQgYSBTWU4gZm9sbG93ZWQgYnkgYSBSU1QsIHdlIG5ldmVyIHNh
dyBhIFNZTi1BQ0sgZnJvbSB0aGUgcmVzcG9uZGVyIiwKICAgICAgICAiUlNUUkgiLCAiUmVzcG9u
ZGVyIHNlbnQgYSBTWU4gQUNLIGZvbGxvd2VkIGJ5IGEgUlNULCB3ZSBuZXZlciBzYXcgYSBTWU4g
ZnJvbSB0aGUgKHB1cnBvcnRlZCkgb3JpZ2luYXRvciIsCiAgICAgICAgIlNIIiwgIk9yaWdpbmF0
b3Igc2VudCBhIFNZTiBmb2xsb3dlZCBieSBhIEZJTiwgd2UgbmV2ZXIgc2F3IGEgU1lOIEFDSyBm
cm9tIHRoZSByZXNwb25kZXIgKGhlbmNlIHRoZSBjb25uZWN0aW9uIHdhcyAnaGFsZicgb3Blbiki
LAogICAgICAgICJTSFIiLCAiUmVzcG9uZGVyIHNlbnQgYSBTWU4gQUNLIGZvbGxvd2VkIGJ5IGEg
RklOLCB3ZSBuZXZlciBzYXcgYSBTWU4gZnJvbSB0aGUgb3JpZ2luYXRvciIsCiAgICAgICAgIk9U
SCIsICJObyBTWU4gc2VlbiwganVzdCBtaWRzdHJlYW0gdHJhZmZpYyAoYSAncGFydGlhbCcgY29u
bmVjdGlvbiB0aGF0IHdhcyBub3QgbGF0ZXIgY2xvc2VkKSIKICAgICAgXQogICAgICBhZGRfdGFn
ID0+IFsgInRyYW5zbGF0ZWQiIF0KICAgIH0gI2VuZCB0cmFuc2xhdGUKICAgIGdlb2lwIHsKICAg
ICAgc291cmNlID0+ICJpZC5vcmlnX2giCiAgICAgIGFkZF90YWcgPT4gWyAiZ2VvaXBfb3JpZyIg
XQogICAgfSAjZW5kIGdlb2lwIG9yaWcKICAgIGdlb2lwIHsKICAgICAgc291cmNlID0+ICJpZC5y
ZXNwX2giCiAgICAgIGFkZF90YWcgPT4gWyAiZ2VvaXBfcmVzcCIgXQogICAgfSAjZW5kIGdlb2lw
IHJlc3AKICAgIGRhdGUgewogICAgICBtYXRjaCA9PiBbICJ0cyIsICJVTklYIiBdCiAgICAgIGFk
ZF90YWcgPT4gWyAidHNtYXRjaCIgXQogICAgfSAjZW5kIGRhdGUKICAgIGlmIFtpZC5vcmlnX2hd
ID09ICJzdHJpbmciIG9yIFtpZC5vcmlnX2hdID09ICJ1aWQiIHsKICAgICAgZHJvcCB7fQogICAg
fSAjZ2V0IHJpZCBvZiBzdHJhbmdlIHJlY29yZHMgd2hlbiBmaWxlIHJvdGF0aW9uIG9jY3Vycwog
IH0gIyMjI2VuZCBicm9fY29ubiMjIyMKCiMjI0VORCBGaWx0ZXIKfQoK'| base64 -d > /etc/logstash/conf.d/logstash-bro.conf

printf "output {
  rabbitmq {
     user => \"$RABBIT_USER\"
     exchange_type => \"direct\"
     password => \"$RABBIT_PASSWORD\"
     exchange => \"darknet-data-ext.direct\"
     vhost => \"/\"
     durable => true
     ssl => false
     port => 5672
     persistent => false
     heartbeat => 2
     host => \"$RABBIT_HOST\"
     subscription_retry_interval_seconds => 5
     connection_timeout => 3000
  }
}" >> /etc/logstash/conf.d/logstash-bro.conf

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

chmod +x /root/geoupdate.sh

#### Cleanup
echo "net.ipv4.tcp_keepalive_intvl=570" >> /etc/sysctl.conf

mv /etc/ssh/sshd_config /etc/ssh/sshd_config.old
cat /etc/ssh/sshd_config.old | sed '/Port 22$/c\Port 42224' > /etc/ssh/sshd_config
service ssh restart

