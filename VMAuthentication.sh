#! /bin/bash


SubString="Failed password"
file="/home/kaustubh/Desktop/auth.log"
iCnt=0
userName=""
ipAddress=""
authenticateRoot()
{
	cd /var/log/
	sudo su
	
}

readTheFile()
{ 
	cd /home/kaustubh/Desktop/
	countFailedPassword=$(grep "Failed password" auth.log | wc -l)
	touch output.txt
        echo "UserName                                            IP Address                                       Failed Login Attempts">>output.txt
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

getDataOfFailedFirstAttempt()
{
	FIRSTLINE=`head -1 $file`
      
	if [[ "$FIRSTLINE" == *"$SubString"* ]]
	then 
	  echo "Calculating Data"
	  failedData="$FIRSTLINE"
	  arr=($failedData)
	  userName="${arr[8]}"
	  ipAddress="${arr[10]}"
	fi
}

getDataFromFile()
{
    while IFS=: read a1 a2 a3 a4
    do 
    	if [[ "$a4" == *"$SubString"* ]]
	  	then
	     failedDataOfFile="$a4"
	     splitData
	  fi
    	done <"$file"
}

splitData()
{
	setDelimiter=' '
	read -a arr2 <<< "$failedDataOfFile"
	if [[ "${arr2[3]}" == *"$userName"* ]]&&[[ "${arr2[5]}" == *"$ipAddress"* ]]
	then
	   a=`expr $a + 1`
	   echo $a
	elif [[ "${arr2[3]}" != *"$userName"* ]]||[[ "${arr2[5]}" != *"$ipAddress"* ]]
	then
	   echo $a
	   if [[ $a -ge 3 ]]
	   then
	       saveDataInFile
	   fi
	   a=1
	   userName="${arr2[3]}"
	   ipAddress="${arr2[5]}"
	fi
}

saveDataInFile()
{
	echo "$userName                                            $ipAddress                                              $a">>output.txt
}
# authenticateRoot
readTheFile
getTotalNumberofUnAuthenticatedAttempts
getDataOfFailedFirstAttempt
getDataFromFile
saveDataInFile






























