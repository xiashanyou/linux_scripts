host_ip.txt文件可以通过手动写（当然了这就显得不自动化）你可以使用扫描工具扫描你网络中的主机，然后配合awk等工具生成该文件。ip地址即登录用户名密码的文件实例：
[root@vinsent app]# cat host_ip.txt 
172.18.14.123 root 123456
172.18.254.54 root 123456

[root@tianta app]# cat ssh_auto.sh 
#!/bin/bash
#!/bin/bash
#------------------------------------------#
# FileName:             ssh_auto.sh
# Revision:             1.1.0
# Date:                 2017-07-14 04:50:33
# Description:          此脚本已经有yum 和 编译两种安装方式，其中编译安装方式已经注释
# Function：            This script can achieve ssh password-free login, 
#                       and can be deployed in batches, configuration
#------------------------------------------#
# Copyright:            2017 vinsent
# License:              GPL 2+
#------------------------------------------#

mkdir -p /etc/yum.repos.d/bak
ls /etc/yum.repos.d/
mv  /etc/yum.repos.d/*.repo  /etc/yum.repos.d/bak/
ls /etc/yum.repos.d/bak/
cd /etc/yum.repos.d/
cat /etc/redhat-release |grep 6  && wget wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-6.repo || wget wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
yum clean all
yum makecache
yum -y install expect 

#yum  install  unzip gcc -y
#mv -f tcl tcl_bak
#rm -rf tcl.zip*
#mv -f expect5.45.3 expect5.45.3_bak
#rm -rf expect5.45.3.tar.gz*
#cd /tmp & &wget  http://core.tcl.tk/tcl/zip/release/tcl.zip
#wget https://jaist.dl.sourceforge.net/project/expect/Expect/5.45.3/expect5.45.3.tar.gz
#unzip tcl.zip && cd ./tcl/unix
#./configure && make && make install
#cd /tmp && tar -xzvf expect5.45.3.tar.gz && cd expect5.45.3/
#./configure && make && make install
#expect -v
#ln -s /usr/local/bin/expect  /usr/bin/expect

[ ! -f /root/.ssh/id_rsa.pub ] && ssh-keygen -t rsa -P "" -f ~/.ssh/id_rsa # 密钥对不存在则创建密钥
while read line;do
        ip=`echo $line | cut -d " " -f1`             # To get hosts ip
        user_name=`echo $line | cut -d " " -f2`      # To get hosts user
        pass_word=`echo $line | cut -d " " -f3`      # To get hosts password
expect <<EOF
        spawn ssh-copy-id -i /root/.ssh/id_rsa.pub $user_name@$ip
        expect {
                "yes/no" { send "yes\n";exp_continue}
                "password" { send "$pass_word\n"}
        }
        expect eof
EOF
  
done < /root/host_ip.txt      # 读取存储ip的文件

# pscp.pssh -h /root/host_ip.txt /root/your_scripts.sh /root     # 推送你在目标主机进行的部署配置
# pssh -h /root/host_ip.txt -i bash /root/your_scripts.sh        # 进行远程配置，执行你的配置脚本
