#!/bin/bash -e

a=2
install()
{
  a=22
  echo ${a}
}
echo $a
