#!/usr/bin/bash

mkdir DBMS 2>>/dev/null

PS3="##Enter Your Choice Number: "
function checkTable {
while [ -z "$tname" ]
        do
                echo "Required input!"
                echo "|Enter Table Name:"
                read tname
        done
}
function createT {
	
	 if ! [[ -f .temp ]]
         then
      	        touch .temp

       	fi
 

	
	echo "|Enter Table Name:"
	read tname
	
	checkTable

	if [[ -f $tname.csv ]]
	then
		echo "ERROR table already exists!"
		tablemenu
	fi

	echo "|Enter NO. Columns:"
	read cols
	while [ -z "$cols" ]
        do
                echo "Required input!"
                echo "|Enter NO. columns:"
                read cols
        done

	colsnames=" "
	i=2
	draw=" "
	sep=","
	rsep="\n"
	echo "|Enter Name of column No.1 (PK):"
	read pk
	while [ -z "$pk" ]
        do
                echo "Required input!"
                echo "|Enter Name of column No.1 (PK):"
                read pk
        done

	draw="${draw} $pk$sep"
	while [ $i -le $cols ]
	do 
		echo "|Enter Name Of Col. No.$i"
		read colname

		while [ -z "$colname" ]
                do
               		 echo "Required input!"
              		 echo "|Enter Name of column No.1 (PK):"
               		 read colname
                done



		draw="${draw} $colname$sep"
		colsnames="${colsnames}  $colname  "

		((i++))
done
touch $tname.csv

metadata="Table name = $tname$rsep Number of Coloumns = $cols$rsep Name of coloumns is:$pk$colsnames$rsep "
echo -e $metadata >> $tname.csv
echo $draw >> $tname.csv


#echo $draw > .temp
#column -n -e -t -s';' .temp >> $tname


 if [[ $? == 0 ]]
        then
                echo "$tname created succefully!"
        else
                echo "ERROR table can not be created!"
        fi
	tablemenu
        

}
function listT {
       	for i in *
	do
	echo "${i%.csv}"
	done	
	tablemenu
	
}
function dropT {
	 
       	echo "|Enter Table Name To Drop:"
    	 read tname
	 
	 checkTable

        rm $tname.csv
		
        if [[ $? == 0 ]]
        then
                echo "$tname dropped succefully! "
        else
                echo "ERROR dropping $tname!"
        fi
	
	tablemenu
	
}

function insertR {

	echo "|Enter Table Name To Insert Into: "
	read tname

	checkTable

	if ! [[ -f $tname.csv ]]
	then 
		echo "ERROR table not found!"
		tablemenu
	fi
	ivalue=" "
	nr=`awk -F, '{if (NR==5){print NF}}' $tname.csv`
	sep=","

#check pk
	pk=`awk -F, '{if (NR==5){print $1}}' $tname.csv`
	
        
	while true
	do
	echo "Insert $pk value:"
        read pkvalue
		while [ -z "$pkvalue" ]
      		  do
                	echo "Required input!"
               	        echo "|Enter $pk value:"
               	        read pkvalue
        	  done

	let key=`awk -F, '{if ($1 != "'$pkvalue'")sum+=1} END{if (sum == NR)k=1; else k=0; {print k}}' $tname.csv`

	if test $key -eq 1
	then
		break
	else
		echo "$pk value already exist!"
		
	fi
	done

	ivalue="${ivalue} $pkvalue$sep"



	for (( i=2; i<$nr; i++))
	do
		cname=`awk -F, '{if (NR==5){print $'$i'}}' $tname.csv`
		echo "Insert $cname value:"
		read fname
		ivalue="${ivalue} $fname$sep"
	done

	echo $ivalue >> $tname.csv

	if [[ $? == 0 ]]
        then
                echo "values inserted succefully!"
        else
                echo "ERROR can not insert values!"
        fi

        tablemenu

}
function selectR {
        echo "|Enter Table Name To Select From: "
        read tname
	
	checkTable

        if ! [[ -f $tname.csv ]]
        then
                echo "ERROR table not found!"
                tablemenu
        fi
	echo "|Enter Primary key value:"
	read svalue
	vcheck=`awk -F, '{if ($1 == "'$svalue'") print 1}' $tname.csv`
	
	if test $vcheck -eq 1 2>/dev/null


	then 
		 echo ---------------------------$tname Table---------------------------
                awk -F, '{if (NR == 5){print $0}}' $tname.csv > .temp
                column -n -e -t -s',' .temp
                echo --------------------------------------------------------------
                awk -F, '{if ($1 == "'$svalue'"){print $0}}' $tname.csv > .temp
                column -n -e -t -s',' .temp


	else
		 echo "NO available data!"

	fi
	tablemenu

}

function deleteR {
	echo "|Enter Table Name To Delete From: "
        read tname
	
	checkTable

        if ! [[ -f $tname.csv ]]
        then
                echo "ERROR table not found:"
                tablemenu
        fi

        echo "|Enter Primary key value:"
        read pvalue
	vcheck=`awk -F, '{if ($1 == "'$pvalue'") print 1}' $tname.csv`  


        if test $vcheck -eq 1 2>/dev/null


        then
		 drow=`awk -F, '{if ($1 == "'$pvalue'"){print NR}}' $tname.csv `
                sed  -i ''$drow'd'  $tname.csv
                echo "Data with id $pvalue deleted succefully!"

           
        else
		echo "NO available data!"

	fi

	tablemenu

}
function choosedb {
 echo "|Enter DB name To Connect:"
        read chdb
        if [[ -d $chdb ]]
        then
                cd $chdb
                tablemenu

        else
                echo "DB not found!"
		cd ..
		mainmenu
        fi

}

function tablemenu {
echo "____________________________TABLE MENU__________________________________"
echo " "
select choice in "Create Table" "List Tables" "Drop Tables" "Insert Into Tables" "Select From Table" "Delete From Table" "Return To Main Menu"
do
        case $choice in
                "Create Table" ) createT
                        ;;
                "List Tables") listT
                        ;;
                "Drop Tables") dropT
                        ;;
                "Insert Into Tables") insertR
                        ;;
                "Select From Table") selectR
                        ;;
		"Delete From Table") deleteR
                        ;;
		"Return To Main Menu") cd .. ; mainmenu
			;;
		*) echo "Wrong choice!"
                        
        esac
done

echo " "
}

function createdb {
	echo "|Enter Name Of New Database"
	read dbname

	while [ -z "$dbname" ]
        do
                echo "Required input!"
                echo "|Enter Database Name:"
                read dbname
        done


	cd DBMS

	mkdir  $dbname 2>/dev/null
	if [[ $? == 0 ]]
	then
		echo "$dbname Database created succefully! "
	else 
		echo "ERROR Database already exists!"
	fi
	cd ..

}
function listdb {
	cd DBMS

	ls
	cd ..
}

function dropdb {
	echo "|Enter Database Name To Delete:"
	read dbdelete

	while [ -z "$dbdelete" ]  #check input is empty
        do
                echo "Required input!"
                echo "|Enter Database Name:"
                read dbdelete
        done

	cd DBMS

	rm -r $dbdelete
	if [[ $? == 0 ]]   #check errors=0
        then
                echo "$dbdelete Database deleted succefully! "
        else
                echo "ERROR Database can not be deleted!"
        fi

	cd ..

}

function mainmenu {
	
echo "_____________________________MAIN MENU__________________________________"
echo " "
select choice in "Create Database" "List Database" "Connect To Database" "Drop Database" "exit"
do
	case $choice in
		"Create Database" ) createdb
			;;
		"List Database") listdb
			;;
		"Connect To Database") cd DBMS; choosedb
                        ;;
                "Drop Database") dropdb
                        ;;
		"exit") exit
			;;
                *) echo "Wrong Choice!"
	esac
done
}
clear
echo "                          WELCOME TO DBMS"
mainmenu


