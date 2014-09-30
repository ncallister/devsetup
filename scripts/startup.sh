#!/bin/bash

ssh-add ~/.ssh/1.5
ssh-add ~/.ssh/github

davmail &

~/scripts/atomupdate.sh
~/scripts/svnupdate.sh
