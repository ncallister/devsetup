#!/bin/bash
sudo apt-get purge $(dpkg --list |egrep 'linux-image-[0-9]' |awk '{print $3,$2}' |sort -nr |tail -n +2 |grep -v $(uname -r) |awk '{ print $2}')
sudo apt-get autoremove -y; sudo apt-get purge -y $(dpkg --list |grep '^rc' |awk '{print $2}')

