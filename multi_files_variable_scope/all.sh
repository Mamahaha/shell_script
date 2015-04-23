#!/bin/bash -e

a=3
echo $a
source ./1.sh
echo ${a}
install
echo ${a}
source ./2.sh
echo ${a}
install
echo ${a}
