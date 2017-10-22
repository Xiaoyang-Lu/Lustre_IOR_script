#!/bin/bash
create_tmp(){
	sed -n -e /"clients"/p -e /"xfersize"/p -e /"blocksize"/p -e /"aggregate filesize"/p -e /"write"/p -e /"read"/p -e /"Max Write"/p -e /"Max Read"/p  ior.log > ior.log.tmp
}
replace_tmp(){
	sed -i -e s/"Max\ Write:"/"	Write"/g -e s/"Max\ Read:"/"	Read"/g -e s/"("/""/g -e s/")"/""/g ior.log.tmp
}
sort_result(){
	awk 'BEGIN{print "ProcNR\tXferSZ\tBlkSZ\tAGGSZ\tTime\tWrite\tRead";}
	{
		if($1=="clients") printf("%d\t", $3);
		if($1=="xfersize") printf("%d %s\t", $3,$4);
	        if($1=="blocksize") printf("%d %s\t", $3,$4);
        	if($1=="aggregate") printf("%d %s\t", $4,$5);
	        if($1=="write") printf("%f\t", $10);
	        if($1=="read") printf("%f\t", $10);
	        if($1=="Write") printf("%f\t\n", $4);
		if($1=="Read") printf("%f\n", $4);
	 }'  ior.log.tmp >ior.txt
	#produce average value
	cp ior.txt ior2.txt
	sed -i "1d" ior2.txt
  echo repeat=$1
	#awk -v rep=$1 'BEGIN{print "ProcNR\tXferSZ\tBlkSZ\tAGGSZ\tTime\tWrite\tRead";}
	#{ sum+=$9; if (NR%rep ==0 ){printf("%d\t%d %s\t%d %s\t%d %s\t%f\t\n",$1,$2,$3,$4,$5,$6,$7,sum/rep); sum=0}}' ior2.txt > average.txt
	awk -v rep=$1 'BEGIN{print "Bandwidth";}
	{ sum+=$9; if (NR%rep ==0 ){printf("%.2f\n",sum/rep); sum=0}}' ior2.txt > average.txt
#	 rm -rf ior.log
	 rm -rf ior2.txt ior.log.tmp
}


create_tmp
replace_tmp
sort_result $1
cat average.txt

