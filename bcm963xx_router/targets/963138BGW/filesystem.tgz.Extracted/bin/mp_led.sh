#! /bin/sh
#######################  help ###########################
# /bin/mp_led.sh CMD <LED>
# CMD = on | onnext | off
# LED = [SWLED] WIFI POWER WPS SFP ETH0 ETH1 ETH2 ETH3 WAN MOCA0 MOCA1
# SWLED = WIFI POWER WPS SFP

# Notes:
# 1) <LED> is an option, if not specified LED after CMD, means run command on all LEDs including sw led and hw led.
#    when SWLED is specified, only to control "WIFI POWER WPS SFP " sw led
#
#
BoardID=$(cfecmd -g BoardID)
BoardID=${BoardID:36}

CENTURYLINK=0
NO_MOCA_WAN=0
NO_MOCA_LAN=0
# BHR5C_M6240x, C3000 and T3200xxx don't support MOCA WAN
if [ -n "$(echo ${BoardID} | grep -e "BHR5C_M6240" -e "T3200" -e "C3000")" ]; then
    NO_MOCA_WAN=1
fi

# T3200 T3200B and C3000 don't support MOCA LAN
if [[ "${BoardID}" = "C3000" || "${BoardID}" = "T3200B" || "${BoardID}" = "T3200" ]]; then
    NO_MOCA_LAN=1
fi

if [ "${BoardID}" = "C3000" ]; then
    CENTURYLINK=1
fi

OFF="00"
ON="01"
ONNEXT="02"
#ALL_LEDS="WIFI POWER WPS ETH0 ETH1 ETH2 ETH3 WAN SFP0"
ALL_LEDS="WIFI POWER WPS ETH0 ETH1 ETH2 ETH3 WAN"
#SW_LEDS="WIFI POWER WPS SFP0"
SW_LEDS="WIFI POWER WPS"
ONNEXT_LEDS="POWER WPS"

if [ "${BoardID}" = "T3200" ]; then
    ALL_LEDS=${ALL_LEDS}" VDSL0 VDSL1"
elif [ "${BoardID}" = "T3200B" ]; then
    ALL_LEDS=${ALL_LEDS}" SFP0 SFP1 VDSL0 VDSL1"
    SW_LEDS=${SW_LEDS}" SFP0 SFP1"
elif [[ "${BoardID}" = "T3200M" || "${BoardID}" = "T3200BM" ]]; then
    ALL_LEDS=${ALL_LEDS}" SFP0 SFP1 VDSL0 VDSL1 MOCA0"
    SW_LEDS=${SW_LEDS}" SFP0 SFP1"
elif [[ "${BoardID}" = "T3200BV" || "${BoardID}" = "C3000" ]]; then
    ALL_LEDS=${ALL_LEDS}" SFP0 SFP1 VDSL0 VDSL1 VOIP0 VOIP1"
    SW_LEDS=${SW_LEDS}" SFP0 SFP1"
elif [ "${BoardID}" = "T3200BMV" ]; then
    ALL_LEDS=${ALL_LEDS}" SFP0 SFP1 VDSL0 VDSL1 MOCA0 VOIP0 VOIP1"
    SW_LEDS=${SW_LEDS}" SFP0 SFP1"
fi

LEDS=$ALL_LEDS

if [ "$#" = "0" ] || [ "$1" = "help" ]; then
  echo "---HELP---"
  echo "$0 on/off (on/off all LED)"
  echo "$0 on/off SWLED (on/off SWLED: ${SW_LEDS})"
  echo "$0 on/off LED_NAME (on/off LED: ${ALL_LEDS})"
  echo "$0 onnext (on all red LED: ${ONNEXT_LEDS})"
  echo "$0 onnext LED_NAME (on red LED: ${ONNEXT_LEDS})"
  echo "---END---"
  exit 1;
fi

set_power_led()
{
    if [ $CENTURYLINK == 1 ]; then
        echo "22$1" >/proc/led
    else
        echo "1E$1" >/proc/led
    fi
}

set_wps_led()
{
    echo "03$1" >/proc/led
}

set_wifi_led()
{
#    # after wifi-led supported, need to comment command#1 and uncomment  below command#2
#    # command#1 to control wifi-led
#    # echo "1C$1" >/proc/led
#
#    # command#2 to control wifi-led
#    case $1 in
#    "00")
#        # 2G
#        wl down
#        wl radio off
#        # 5G
#        qcsapi_sockrpc enable_interface wifi0 0
#        qcsapi_sockrpc set_LED 1 0
#        ;;
#    "01")
#        # 2G
#        wl radio on
#        wl up
#        # 5G
#        qcsapi_sockrpc enable_interface wifi0 1
#        qcsapi_sockrpc set_LED 1 1
#        ;;
#    esac

    # command#2 to control wifi-led
     echo "1D$1" >/proc/led
}

set_sfp_led0()
{
    if [ $CENTURYLINK == 1 ]; then
        echo "1F$1" >/proc/led
    else
        echo "1B$1" >/proc/led
    fi
}

set_sfp_led1()
{
    if [ $CENTURYLINK == 1 ]; then
        echo "20$1" >/proc/led
    else
        echo "1C$1" >/proc/led
    fi
}

set_lan0_led()
{
    echo "0C$1" >/proc/led
    echo "0D$1" >/proc/led
}

set_lan1_led()
{
    echo "0F$1" >/proc/led
    echo "10$1" >/proc/led
}

set_lan2_led()
{
    echo "12$1" >/proc/led
    echo "13$1" >/proc/led
}

set_lan3_led()
{
    echo "15$1" >/proc/led
    echo "16$1" >/proc/led
}
set_wan_led()
{
    #echo "19$1" >/proc/led
    #echo "1A$1" >/proc/led

    case $1 in
    "00")
        sw fffe8140 0x5015;sw fffe8144  21;sw fffe8140 0x5014;sw fffe8144  21;sw fffe8100 300000;sw fffe8114 300000
        sw fffe8140 0x4015;sw fffe8144  21;sw fffe8140 0x4014;sw fffe8144  21;
        ;;
    "01")
        sw fffe8140 0x5015;sw fffe8144  21;sw fffe8140 0x5014;sw fffe8144  21;sw fffe8100 300000;sw fffe8114 000000 
        ;;
    esac
}


set_moca_led()
{
    mode="00 01 02"
    for each in $mode; do
        if [ "-$2" = "-$each" ];then
            mocap $1 -p set --led_mode $2 --restart
        fi
    done
}

set_moca0_led()
{
    set_moca_led moca0 $1
}
set_moca1_led()
{
    sleep 1
    set_moca_led moca1 $1
}
set_vdsl0_led()
{
    echo "00$1" >/proc/led
}
set_vdsl1_led()
{
    echo "01$1" >/proc/led
}
set_voip0_led()
{
    echo "08$1" >/proc/pca9555/output
}
set_voip1_led()
{
    echo "09$1" >/proc/pca9555/output
}

set_led()
{
    case "$1" in
        "WIFI")
            set_wifi_led $2 ;;
        "POWER")
            set_power_led $2 ;;
        "WPS")
            set_wps_led $2 ;;
        "SFP0")
            set_sfp_led0 $2 ;;
        "SFP1")
            set_sfp_led1 $2 ;;
        "ETH0")
            set_lan0_led $2 ;;
        "ETH1")
            set_lan1_led $2 ;;
        "ETH2")
            set_lan2_led $2 ;;
        "ETH3")
            set_lan3_led $2 ;;
        "WAN")
            set_wan_led $2 ;;
        "MOCA0")
            set_moca_led moca0 $2 ;;
        "MOCA1")
            if [ $NO_MOCA_WAN == 0 ]; then
                set_moca_led moca1 $2
            fi
            ;;
        "VDSL0")
            set_vdsl0_led $2 ;;
        "VDSL1")
            set_vdsl1_led $2 ;;
        "VOIP0")
            set_voip0_led $2 ;;
        "VOIP1")
            set_voip1_led $2 ;;
        "SW")
            ;;
        *)
            echo "error $2 $1";;
    esac
}

set_led_off()
{
    set_led $1 $OFF
}

set_led_on()
{
    set_led $1 $ON
}

set_led_onnext()
{
    set_led $1 $ONNEXT
}


set_all_leds_off()
{
    for each in $LEDS ;do
        if [ $NO_MOCA_WAN == 0 ]; then
            if [ $each == "MOCA1" ]; then
                sleep 1
            fi
        fi
        set_led_off $each
    done
}

set_all_leds_on()
{
    for each in $LEDS ;do
        if [ $NO_MOCA_WAN == 0 ]; then
            if [ $each == "MOCA1" ]; then
                sleep 1
            fi
        fi
        set_led_on $each
    done
}

set_all_leds_onnext()
{
    for each in $ONNEXT_LEDS ;do
        set_led_onnext $each
    done
}


if [ $# -eq 0 ]; then
exit
else
    if [ "-$2" = "-SWLED" ]; then
        LEDS=$SW_LEDS
    fi

    case "$1" in
    "on")
        if [ "-$2" = "-" -o "-$2" = "-SWLED" ];then
                # turn on all LED
            set_all_leds_on
        else
            # turn led on
            set_led_on $2
        fi;;

    "off")
        if [ "-$2" = "-" -o "-$2" = "-SWLED" ];then
            # turn on all LED
            set_all_leds_off
        else
            # turn led off
            set_led_off $2
        fi ;;
    "onnext")
        if [ "-$2" = "-" -o "-$2" = "-SWLED" ];then
            # turn on all red led
            set_all_leds_onnext
        else
            # turn red led on
            set_led_onnext $2
        fi;;
    *)
        echo "error $1";;
    esac
fi
