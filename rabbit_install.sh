apt-key adv --keyserver "hkps.pool.sks-keyservers.net" --recv-keys "0x6B73A36E6026DFCA"
echo "deb http://dl.bintray.com/rabbitmq-erlang/debian bionic erlang" > /etc/apt/sources.list.d/50-erlang.list

USER=tuna
PASS=Ilovetuna

apt-get install -y erlang-base-hipe \
                        erlang-asn1 erlang-crypto erlang-eldap erlang-ftp erlang-inets \
                        erlang-mnesia erlang-os-mon erlang-parsetools erlang-public-key \
                        erlang-runtime-tools erlang-snmp erlang-ssl \
                        erlang-syntax-tools erlang-tftp erlang-tools erlang-xmerl


wget -O - "https://packagecloud.io/rabbitmq/rabbitmq-server/gpgkey" | sudo apt-key add -

curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.deb.sh | sudo bash

apt-get install -y rabbitmq-server
service rabbitmq-server start
rabbitmq-plugins enable rabbitmq_management

rabbitmqctl add_user $USER $PASS
rabbitmqctl set_user_tags $USER administrator
rabbitmqctl set_permissions -p / $USER ".*" ".*" ".*"
