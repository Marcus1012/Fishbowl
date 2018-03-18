#!/bin/sh
clear
echo | tee -a debug.log
echo | tee -a debug.log
echo ================================= | tee -a debug.log
echo _Fishbowl GO iOS - Debug Monitor_ | tee -a debug.log
echo ================================= | tee -a debug.log
date | tee -a debug.log
echo | tee -a debug.log
# ncat -l 4000 -k < hello.http
ncat -l 4000 -k < hello.http 2>&1 | tee -a debug.log

