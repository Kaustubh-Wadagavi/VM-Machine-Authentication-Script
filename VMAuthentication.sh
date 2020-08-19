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
	  failedData="$FIRSTLINE"
	  arr=($failedData)
	  userName="${arr[8]}"
	  ipAddress="${arr[10]}"
	  Time2=${arr[2]}
	fi
}

getDataFromFile()
{
    while IFS=" " read a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12 a13 a14
    do 
	Time1=$a3
    	if [ "$a6" == "Failed" ]&&[ "$a7" == "password" ]
	 then
	     username=$a9
             ipaddress=$a11
	     calculateTime
	     calculateData
	  fi
    done <"$file"
}

calculateTime()
{
    IFS=':' read -r -a t1 <<< "$Time1"
    IFS=':' read -r -a t2 <<< "$Time2"
    t1=("${t1[@]##0}")
    t2=("${t2[@]##0}")
    if (( t1[0] > t2[0] || ( t1[0] == t2[0] && t1[1] > t2[1]) ))
    then
  	if (( t1[1] < t2[1] ))
  	then
   	  (( t1[1] += 60 ))
   	  (( t1[0] -- ))
  	fi
    timeDifferenceHours=$(( t1[0]-t2[0] ))
    timeDifferenceMinute=$(( t1[1] - t2[1] ))
    echo $timeDifferenceHours
    echo $timeDifferenceMinute
    fi


}

calculateData()
{
	echo "$timeDifference"
	setDelimiter=' '
	if [[ "$username" == *"$userName"* ]]&&[[ "$ipaddress" == *"$ipAddress"* ]]&&[[ "$timeDifferenceHours" -le "00" ]]&&[[ "$timeDifferenceMinute" -le "30" ]]
 	then
	   a=`expr $a + 1`
	elif [[ "$username" != *"$userName"* ]]||[[ "$ipaddress" != *"$ipAddress"* ]]
	then
	   if [[ $a -ge 3 ]]
	   then
	       saveDataInFile
	   fi
	   a=1
	   userName="$username"
	   ipAddress="$ipaddress"
	fi
}

saveDataInFile()
{
	echo "$userName                                            $ipAddress                                              $a">>output.txt
}
#authenticateRoot
readTheFile
getTotalNumberofUnAuthenticatedAttempts
getDataOfFailedFirstAttempt
getDataFromFile
saveDataInFile






























