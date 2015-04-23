#!/bin/bash -e

a=1
install()
{
  a=11
  echo ${a}
}
echo $a
