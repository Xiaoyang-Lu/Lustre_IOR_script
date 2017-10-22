#!/bin/bash
#trap 'echo "before execute line:$LINENO, XSIZE=$XSIZE"' DEBUG

exec=/home/cc/pkg_src/IOR/src/C/IOR
baseDir=/home/cc
machine=${baseDir}/script/ior_test/clients
servers=`awk '{print $1}' ${baseDir}/script/ior_test/servers`
fm=/home/cc/fm.sh
T=8

#transferSize
XSIZE="1"

#fileSize 
#FSIZE="4"
#FSIZE_M="4096"
#number of processes
PROCNR="1 2 4 8 16 32 64 128"

#stripe count
STRCOUNT="1 2 4 8"

prepare(){
        #       create test file
        for count in $STRCOUNT
        do
                mkdir /mnt/lustre/${count}
                lfs setstripe -c ${count} /mnt/lustre/${count}
                mpirun -np 64 -f ${machine} ${exec} -a MPIIO -o /mnt/lustre/${count}/ior.0 -w -t 1m -b 512m -k
	done
}


IOR-write-seq(){

        for node in $servers
        do
                #ssh $node sudo su -c "sync; echo 3 >/proc/sys/vm/drop_caches"
                ssh $node ${fm}
        done
        #arguments 1: procnr 2: transfer size 3:block size 4:filename

	mpirun -np ${1} -f ${machine} ${exec} -a MPIIO -t ${2}m -w -E -o /mnt/lustre/${4} -b ${3}m  -k >>ior.log

}




clean(){
        
	for count in $STRCOUNT
        do
        	rm -rf /mnt/lustre/${count}
        done
}

hahaha-write(){
        for xsize in $XSIZE
        do
                for procnr in $PROCNR
                do
                        for count in $STRCOUNT
                        do
                        	for num in `seq 1 3`
                                do   
                            		record=`awk 'BEGIN{printf "%.2f\n",('$procnr'/'$T')}'`
					record_temp=`expr $procnr / $T`					
					if [ $(echo "$record == $record_temp"|bc) -eq 1 ]
					then
       	 					record=$record_temp
					else
        					record=$((${record//.*/+1}))
					fi
					fsize_m=`expr $record \* 4 \* 1024`					
					bsize=`expr ${fsize_m} / ${procnr}`
       					#arguments 1: procnr 2: transfer size 3:block size 4:filename
                                	IOR-write-seq  ${procnr}  ${xsize} ${bsize} /${count}/ior.0
                            	done
                        done
                done
        done
}


if [ -e ior.log ]
then rm -rf ior.log
fi

clean
prepare
hahaha-write
clean
./average.sh 3
#./transform.sh 8 2
#cat transform.txt

