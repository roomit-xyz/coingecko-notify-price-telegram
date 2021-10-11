#!/bin/bash
#
#
# Tools Notify Price Portofolio
#



TICKER=(flow casper-network blocto-token covalent human-protocol wrapped-centrifuge staked-ether mina-protocol near shiden paras genshiro internet-computer persistence ethereum octopus-network ref-finance efinity)
TOKEN=""
CHATID=""

function Check:Tools(){
    if [ -f `which nc` ]
    then
	    echo "Checking Tools - NC Available"
    else
	    echo "Checking Tools - NC Not Available"
	    exit 1;
    fi
    
    if [ -f `which curl` ]
    then
	    echo "Checking Tools - CURL Available"
    else
	    echo "Checking Tools - CURL Not Available"
	    exit 1;
    fi
    if [ -f `which jq` ]
    then
	    echo "Checking Tools - JQ Available"
    else
	    echo "Checking Tools - JQ Not Available"
	    exit 1;
    fi
}

function Check:Internet(){
    echo -e "GET http://google.com HTTP/1.0\n\n" | nc google.com 80 > /dev/null 2>&1

    if [ $? -eq 0 ]; then
       echo "Checking Internet - Online"
    else
       echo "Checking Internet - Offline"
       exit 1;
    fi
}

function Check:File(){
   if [ -f data.txt ]
   then
       rm -f data.txt
       echo "Checking File - Remove File data.txt"
   fi
}

function Collect:Data(){
    printf "%-10s %10.5s\n" TICKER PRICE > data.txt
    printf "%-10s %10.5s\n" ===== ===== >> data.txt
    for i in ${TICKER[@]}
    do
       is_ticker=`curl -s https://api.coingecko.com/api/v3/coins/$i/tickers | jq  '. .tickers [1] .base '| tr -d '"'| tr -d " "`
       if [ $is_ticker == "null" ] || [ `echo "$is_ticker" | wc -m` -eq 43 ] || [ `echo "$is_ticker" | wc -m` -eq 69 ]
       then
           is_ticker=`curl -s https://api.coingecko.com/api/v3/coins/$i/tickers | jq  '. .tickers [0] .base '| tr -d '"'| tr -d " "`
	   if [ `echo "$is_ticker" | wc -m` -eq 43 ] || [ `echo "$is_ticker" | wc -m` -eq 69 ]
           then
                is_ticker=`curl -s https://api.coingecko.com/api/v3/coins/$i/tickers | jq  '. .tickers [2] .base '| tr -d '"'| tr -d " "`
           fi
       fi

       is_price=`curl -s https://api.coingecko.com/api/v3/coins/$i/tickers | jq  '. .tickers [0]  .converted_last.usd' | tr -d " "`
       printf "%-10s %10s %s\n" $is_ticker $is_price USD >> data.txt
    done
}

function Send:Chat(){
     echo "Sending Message - Sending To BOT"
     curl -s -X POST -d parse_mode="HTML" -d text="`cat data.txt`" -d chat_id="${CHATID}" https://api.telegram.org/bot${TOKEN}/sendMessage?chat_id=${CHATID}  
}


Check:Tools;
Check:Internet;
Check:File;
Collect:Data;
Send:Chat;
