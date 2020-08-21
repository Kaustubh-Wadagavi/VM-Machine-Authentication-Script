#! /bin/bash

countTotalAttempts()
{
	countFailedPassword=$(grep "Failed password" $file | wc -l)
}

getTotalNumberofUnAuthenticatedAttempts()
{
	if [ countFailedPassword > 2 ]
	then 
	   echo -e "\nTotal number of Failed Login attempts are :" $countFailedPassword
	else
	   echo -e "\nThere is no failed Login attempts for V-M machine!!"
	   exit
	fi
}

createTheFile()
{ 
	touch output.txt
	echo "*******************************************************************************">>output.txt
	echo "-------------------------------------------------------------------------------">>output.txt
	echo " Number of Failed |      IP Address       |               User Name            ">>output.txt
	echo "  Login Attempts  |                       |                                    ">>output.txt 
	echo "-------------------------------------------------------------------------------">>output.txt
	echo "*******************************************************************************">>output.txt
}

getDataOfFailedFirstAttempt()
{
    while IFS=" " read b1 b2 b3 b4 b5 b6 b7 b8 b9 b10 b11 b12 b13 b14
    do 
    	if [ "$b6" == "Failed" ]&&[ "$b7" == "password" ]
	 		then
	    	 Time2=$b3
	    	 userName=$b9
      	 ipAddress=$b11
	    	 break
	  	fi
    done <"$file"
}

getDataFromFile()
{
    while IFS=" " read a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12 a13 a14
    do 
    	if [ "$a6" == "Failed" ]&&[ "$a7" == "password" ]
	 		then
	    	 Time1=$a3
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
    fi


}

calculateData()
{
	setDelimiter=' '
	if [[ "$username" == *"$userName"* ]]&&[[ "$ipaddress" == *"$ipAddress"* ]]&&[[ "$timeDifferenceHours" -le "00" ]]&&[[ "$timeDifferenceMinute" -le "30" ]]
 	then
	   a=`expr $a + 1`
	elif [[ "$username" != *"$userName"* ]]||[[ "$ipaddress" != *"$ipAddress"* ]]||[[ "$timeDifferenceHours" -ge "00" ]]||[[ "$timeDifferenceMinute" -ge "30" ]]
	then
	   if [[ $a -ge 3 ]]
	   then
	       saveDataInFile
	   fi
	   a=1
	   userName="$username"
	   ipAddress="$ipaddress"
	   Time2=$Time1
	else
	    echo "There is no continuous Failed Login Attempts"
	fi
}

saveDataInFile()
{
	echo "         $a        |     $ipAddress     |            $userName                 ">>output.txt
	echo "-------------------------------------------------------------------------------">>output.txt
}


SubString="Failed password"
file=/var/log/authTwo.log
iCnt=0
userName=""
ipAddress=""

countTotalAttempts
getTotalNumberofUnAuthenticatedAttempts
createTheFile
getDataOfFailedFirstAttempt
getDataFromFile
if [[ $a -ge 3 ]]
then
	saveDataInFile
	echo "Calculated Data stored in the : output.txt"
fi
exit




















