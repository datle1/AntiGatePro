#!/bin/bash
input="xx"
len=${#input}
for (( i = $len - 1; i >= 0; i-- )) 
do
	ten="$ten${input:$i:1}"
done
echo $ten > /tmp/otp
