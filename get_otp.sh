#!/bin/bash
ten=$(cat /tmp/otp)
time=$(date +%s%3N)
check=$(($time - 30000))
/home/nito/jre1.8.0_181/bin/java -jar /home/nito/scripts/autogate/pop3_client.jar "dat" $ten $check > /tmp/otp
