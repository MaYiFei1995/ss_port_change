#!/bin/bash
echo "ctrl+c退出"
server_port="error"
server_port_str="server_port"
config_file="/etc/shadowsocks-go/config.json"

echo "----------读取ss-go的配置文件"
while read line
do
if [[ $line == *$server_port_str* ]]
then
 server_port=${line#*:}
 server_port=${server_port%,}
 echo "当前配置的端口是:$server_port"
fi
done < $config_file
if [ $server_port == "error" ]
then
 echo "----------错误! 没有在配置文件中找到当前端口"
 exit 0
fi

old_port=$server_port
read -p "配置的新端口:" new_port

if [ $old_port == $new_port ]
then 
 echo "----------新旧端口相同，退出任务"
 exit 0
fi
read -p "回车开始任务" to_start

echo "----------修改config文件"
sed -i "s/:$old_port/:$new_port/g" $config_file

echo "----------关闭旧端口"
firewall-cmd --zone=public --remove-port=$old_port/tcp --permanent
firewall-cmd --zone=public --remove-port=$old_port/udp --permanent

echo "----------打开新端口"
firewall-cmd --zone=public --add-port=$new_port/tcp --permanent
firewall-cmd --zone=public --add-port=$new_port/udp --permanent

echo "----------重启防火墙"
firewall-cmd --reload

echo "----------重启ss服务"
systemctl restart shadowsocks-go

echo "----------结束~"
