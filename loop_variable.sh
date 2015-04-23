#!/bin/sh

for x in `ls`
  do echo $x
  while read line
    do 
      echo $line
    done<$x
    echo 
done
