#!/usr/bin/env bash

# update apt
apt update

if [ $? -eq 0 ];then
  apt_check="apt update succeed!"
else
  echo "get errors!"
  exit
fi

# install python
apt install -y python

if [ $? -eq 0 ];then
  install_python="Install python succeed!"
else
  echo "get errors!"
  exit
fi

# install pip
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py

python get-pip.py
if [ $? -eq 0 ];then
  install_pip="Install pip succeed!"
else
  echo "get errors!"
  exit
fi

# if use ubuntu 16.04
sed -i 's/^#PermitRootLogin.*/PermitRootLogin=yes/g' /etc/ssh/sshd_config
sed -i 's/^PermitRootLogin.*/PermitRootLogin=yes/g' /etc/ssh/sshd_config

service sshd restart

if [ $? -eq 0 ];then
  config_ssh="config ssh succeed!"
else
  echo "get errors!"
  exit
fi

echo ""
echo "if all below operations return succeed, just do the next step!"
echo $apt_check
echo $install_sshpass
echo $install_python
echo $install_pip
echo $config_ssh