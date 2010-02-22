#!/bin/bash
# benchmark.sh
OUTPUT_FILE="benchmark.txt"
ROUNDS=3

# System Info
export TIME='real\t%E\nuser\t%U\nsys\t%S\nCPU\t%P\nMem. Max\t%M\nMem. Avg\t%K\nCont. Switch\t%w'
echo -e "### $(uname -n | perl -ne 'print ucfirst($_)') Benchmark ###\n" > $OUTPUT_FILE
sleep 1

# Test: hdparm
echo -e "# hdparm -T /dev/sda #\n" >> $OUTPUT_FILE
for i in `seq $ROUNDS`
do
  sleep 1
  hdparm -T /dev/sda | grep MB >> $OUTPUT_FILE
done

# Test: gzip
echo -e "\n# gzip test.iso #\n" >> $OUTPUT_FILE
for i in `seq $ROUNDS`
do
  sleep 1
  /usr/bin/time -a -o $OUTPUT_FILE -- gzip test.iso
  echo "" >> $OUTPUT_FILE
  gunzip test.iso.gz
done

# Test: gunzip
echo -e "# gunzip test.iso.gz #\n" >> $OUTPUT_FILE
for i in `seq $ROUNDS`
do
  gzip test.iso
  sleep 1
  /usr/bin/time -a -o $OUTPUT_FILE -- gunzip test.iso.gz
  echo "" >> $OUTPUT_FILE
done

# Test: lamme
echo -e "# lame -h test.wav test.mp3 #\n" >> $OUTPUT_FILE
for i in `seq $ROUNDS`
do
  sleep 1
  /usr/bin/time -a -o $OUTPUT_FILE -- lame -h test.wav test.mp3
  echo "" >> $OUTPUT_FILE  
  rm test.mp3
done

# Test: oggenc
echo -e "# oggenc test.wav -b 256 -o test.ogg #\n" >> $OUTPUT_FILE
for i in `seq $ROUNDS`
do
  sleep 1
  /usr/bin/time -a -o $OUTPUT_FILE -- oggenc test.wav -b 256 -o test.ogg
  echo "" >> $OUTPUT_FILE  
  rm test.ogg
done

# Test: compile php
#echo -e "# compile PHP 5.2.12 #\n" >> $OUTPUT_FILE
#wget http://pt.php.net/get/php-5.2.12.tar.bz2/from/this/mirror && tar -xvjf php-5.2.12.tar.bz2 && rm #php-5.2.12.tar.bz2 && cd php-5.2.12/ && ./configure
#for i in `seq $ROUNDS`
#do
#  sleep 1
#  /usr/bin/time -a -o $OUTPUT_FILE -- make -j5
#  echo "" >> $OUTPUT_FILE
#  make clean
#done
#cd .. && rm -rf php-5.2.12/

# Test: All at the same time
echo -e "# Workload (hdparm+gzip+gunzip+lame+oggenc+compile PHP) #\n" >> $OUTPUT_FILE
/usr/bin/time -a -o $OUTPUT_FILE -- time ./workload
