#! /bin/bash


SubString="Failed password"
authenticateRoot()
{
	cd /var/log/
	sudo su
	
}

readTheFile()
{ 
	cd /home/kaustubh/Desktop/
	countFailedPassword=$(grep "Failed password" auth.log | wc -l)
}

getTotalNumberofUnAuthenticatedAttempts()
{
	if [ countFailedPassword > 2 ]
	then 
	    echo "Total number of Failed Login attempts are :" $countFailedPassword
	else
	   echo "There is no failed Login attempts for V-M machine!!"
	   exit
	fi
}

getDataOfFailedAttempts()
{
	echo "Calculating Data"
	file="/home/kaustubh/Desktop/auth.log"
	while IFS=: read f1 f2 f3 f4  
	do 
	if [[ "$f4" == *"$SubString"* ]]
	then 
	  failedData="$f4"
	  splitData 
	fi
	done <"$file"
	 
}

splitData()
{
	setDelimiter=' '
	read -a arr <<< "$failedData"
	echo "${arr[0]} ${arr[1]} ${arr[2]} ${arr[3]} ${arr[4]} ${arr[5]}"
	userName="${arr[3]}"
	ipAddress="${arr[5]}"
	if [ "${arr[3]}" == $userName ]&&[ "${arr[5]}" == $ipAddress ]
	then
	   a=`expr $a + 1`
	   
	else 
	   b=$a
	   a=0
           echo "$b"
	fi
	   
}
# authenticateRoot
readTheFile
getTotalNumberofUnAuthenticatedAttempts
getDataOfFailedAttempts



