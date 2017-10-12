#! /bin/sh

ETHWAN="0"
SFPWAN="0"
MOCAWAN="0"
ATM0="0"
ATM1="0"
PTM="0"
WANIF="0"
WANTYPE="0"
ALLWANIF="0"

ENABLE="1"
DISABLE="0"

SUCC=0
FAIL=1

BoardID=$(cfecmd -g BoardID)
BoardID=${BoardID:36}

NO_MOCA_WAN=0
NO_SFP_WAN=0
DUAL_ATM=0
if [ -n "$(echo ${BoardID} | grep "BHR5C_M6240")" ]; then
  echo "bhr5c_xx"
  NO_MOCA_WAN=1
  ETHWAN="eth0"
  SFPWAN="eth5"
  ALLWANIF="${ETHWAN} ${SFPWAN}"
elif [ -n "$(echo ${BoardID} | grep -e "T3200" -e "C3000")" ]; then
# T3200xx and C3000xx don't support MOCA WAN
  NO_MOCA_WAN=1
# T3200 don't support SFP WAN
  if [ ${BoardID} = "T3200" ]; then
    NO_SFP_WAN=1
  fi
  if [ ${BoardID} = "C3000" ]; then
    DUAL_ATM=0
  else
    DUAL_ATM=1
  fi
  ETHWAN="ewan0"
  SFPWAN="ewan1"
  ATM0="atm0"
  ATM1="atm1"
  PTM="ptm0"
  ALLWANIF="${ETHWAN} ${SFPWAN} ${ATM0} ${ATM1} ${PTM}"
else
  ETHWAN="eth0"
  SFPWAN="eth5"
  MOCAWAN="moca0"
  ALLWANIF="${ETHWAN} ${SFPWAN} ${MOCAWAN}"
fi

if [ "$#" = "0" ] || [ "$1" = "help" ]; then
  echo "---HELP---"
  echo "$0 GE : add ETH WAN to bridge"
  if [ $NO_SFP_WAN == 0 ]; then
    echo "$0 SFP : add SFP WAN to bridge"
  fi
  if [ $NO_MOCA_WAN == 0 ]; then
    echo "$0 MOCA : add MOCA WAN to bridge"
  fi
  if [ ${ATM0} != "0" ]; then
    echo "$0 ATM : add DSL (ATM) WAN to bridge"
  fi
  if [ ${PTM} != "0" ]; then
    echo "$0 PTM : add DSL (PTM) WAN to bridge"
  fi
  echo "$0 FINISH : delete GE\c"
  if [ $NO_SFP_WAN == 0 ]; then
    echo " SFP\c"
  fi
  if [ $NO_MOCA_WAN == 0 ]; then
    echo " MOCA\c"
  fi
  if [ ${ATM0} != "0" ]; then
    echo " ATM\c"
  fi
  if [ ${PTM} != "0" ]; then
    echo " PTM\c"
  fi
  echo " from bridge"
  echo "---END---"
  exit 1;
fi

configWANVLAN()
{
  if [ "$1" = "all" ] || [ "$1" = "${ETHWAN}" ]; then
    cli -spv InternetGatewayDevice.WANDevice.3.WANConnectionDevice.1.WANIPConnection.1.Enable boolean $2 1> /dev/null 2> /dev/null
  fi

  if [ $NO_MOCA_WAN == 0 ]; then
    if [ "$1" = "all" ] || [ "$1" = "${MOCAWAN}" ]; then
      echo ""
      # if have moca vlan
    fi
  fi

  if [ $NO_SFP_WAN == 0 ]; then
    if [ "$1" = "all" ] || [ "$1" = "${SFPWAN}" ]; then
      cli -spv InternetGatewayDevice.WANDevice.4.WANConnectionDevice.1.WANIPConnection.1.Enable boolean $2 1> /dev/null 2> /dev/null
    fi
  fi

  if [ "$1" = "all" ] || [ "$1" = "${PTM}" ]; then
    cli -spv InternetGatewayDevice.WANDevice.2.WANConnectionDevice.1.WANIPConnection.1.Enable boolean $2 1> /dev/null 2> /dev/null
  fi

  if [ "$1" = "all" ] || [ "$1" = "${ATM0}" ]; then
    cli -spv InternetGatewayDevice.WANDevice.1.WANConnectionDevice.1.WANIPConnection.1.Enable boolean $2 1> /dev/null 2> /dev/null
  fi

  if [ "$1" = "all" ] || [ "$1" = "${ATM1}" ]; then
    cli -spv InternetGatewayDevice.WANDevice.1.WANConnectionDevice.2.WANIPConnection.1.Enable boolean $2 1> /dev/null 2> /dev/null
  fi
}

configWAN()
{
  if [ "$1" = "all" ] || [ "$1" = ${ETHWAN} ]; then
    cli -spv InternetGatewayDevice.WANDevice.3.WANEthernetInterfaceConfig.Enable boolean $2 1> /dev/null 2> /dev/null
    sleep 1
  fi
  if [ $NO_MOCA_WAN == 0 ]; then
    if [ "$1" = "all" ] || [ "$1" = ${MOCAWAN} ]; then
      cli -spv InternetGatewayDevice.WANDevice.4.WANMoCAInterfaceConfig.Enable boolean $2 1> /dev/null 2> /dev/null
      sleep 1
    fi
  fi
  if [ $NO_SFP_WAN == 0 ]; then
    if [ "$1" = "all" ] || [ "$1" = ${SFPWAN} ]; then
      cli -spv InternetGatewayDevice.WANDevice.4.WANEthernetInterfaceConfig.Enable boolean $2 1> /dev/null 2> /dev/null
      sleep 1
    fi
  fi
}

checkWAN()
{
  sec=0

  while [ $sec -lt 10 ]
  do
    if [ -n "$(ethswctl -c wan 2>&1 | grep "Interface(s) ${1}" )" ]; then
      return ${SUCC};
    fi
    sleep 1
    let "sec+=1"
  done

  return ${FAIL};
}

checkDSLWAN()
{
  result=$(ifconfig $1 | grep "UP")
  if [ -z "${result}" ] ; then
    return $FAIL
  else
    result=$SUCC;
  fi
}

bridgeConfig()
{
  if [ $1 = "add" ]; then
    brctl addif br0 $2 2> /dev/null
  elif [ $1 = "del" ]; then
    brctl delif br0 $2 2> /dev/null
  fi
}

main()
{
  ret=$SUCC
  result=$SUCC

  if [ "$1" = "GE" ]; then
    WANIF=${ETHWAN}
  elif [ $NO_MOCA_WAN == 0 ] && [ "$1" = "MOCA" ]; then
    WANIF=${MOCAWAN}
  elif [ $NO_SFP_WAN == 0 ] && [ "$1" = "SFP" ]; then
    WANIF=${SFPWAN}
  elif [ "$1" = "ATM" ]; then
    echo " ATM"
    if [ ${DUAL_ATM} == 1 ]; then
      WANIF="${ATM0} ${ATM1}"
    else
      WANIF="${ATM0}"
    fi
    WANTYPE="DSL"
  elif [ "$1" = "PTM" ]; then
    WANIF=${PTM}
    echo " PTM"
	WANTYPE="DSL"
  elif [ "$1" = "FINISH" ]; then
    configWAN "all" ${ENABLE}
    configWANVLAN "all" ${ENABLE}
    for IF in $ALLWANIF ; do
      bridgeConfig "del" ${IF}
    done
    exit 0;
  else
    echo "no find wan interface"
    exit 1;
  fi

  if [ "$1" = "ATM" ] && [ ${DUAL_ATM} == 1 ]; then
    configWANVLAN "${ATM0}" ${DISABLE}
    configWANVLAN "${ATM1}" ${DISABLE}
  else
    configWANVLAN "${WANIF}" ${DISABLE}
  fi

  if [ "${WANTYPE}" = "DSL" ]; then
    if [ "$1" = "ATM" ] && [ ${DUAL_ATM} == 1 ]; then
      checkDSLWAN ${ATM0}
      if [ $? -eq ${SUCC} ]; then
        checkDSLWAN ${ATM1}
      fi
    else
      checkDSLWAN ${WANIF}
    fi
  else
    configWAN "all" ${DISABLE}
    configWAN "${WANIF}" ${ENABLE}
    if [ ${WANIF} = "ewan0" ]; then
      sleep 5
      ethctl ewan0 "media-type" auto port 9 2>&1 > /dev/null
    fi
    checkWAN ${WANIF}
  fi
  ret=$?
  echo ""
  if [ ${ret} -eq ${SUCC} ]; then
    echo "config $1 complete"
  else
    echo "config $1 fail"
  fi
  echo ""

  bridgeConfig "add" "${WANIF}"

  return ${ret}
}

main $1
exit $?
