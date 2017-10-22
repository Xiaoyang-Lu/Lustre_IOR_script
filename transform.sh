#########################################################################
# File Name: transform.sh
# Author: Xiaoyang Lu
# mail: xlu40@hawk.iit.edu
# Created Time: Sun 15 Oct 2017 10:10:11 AM CST
#########################################################################
#!/bin/bash

usage()
{
	echo "Usage: `echo $0| awk -F/ '{print $NF}'`  [option]"
	echo "[option]:"
	echo "  column row"
	echo "  e.g transform.sh 8 2"
	echo "Copyright by Shuibing He 2012-10."
	echo
}

if [ $# -lt 2 ]
then
	usage
	exit
fi

if [ -e test.txt ]
then rm -rf test.txt test1.txti transform.txt
fi

cp average.txt test.txt
sed -i "1d" test.txt
awk -v column=$1 '{print $column}' test.txt > test1.txt
awk -v row=$2 '{if(NR%row != 0){printf("%f\t", $1)} else {printf("%f\n", $1)}}' test1.txt > transform.txt

rm -rf test.txt test1.txt

