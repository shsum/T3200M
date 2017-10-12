#! /bin/sh

(
  sleep 1
  echo "admin"
  echo "admin"
  echo 'echo ;ls -l /proc/bootcfg/*cal |tee /tmp/check_cal; cal=$(get_bootval calstate); echo calstate=${cal}; if [ "3" = $(cat /tmp/check_cal |grep -c ".cal") ]; then echo ; echo Have do calibration; if [ "3" != ${cal} ]; then echo But calstate=${cal}; fi; else echo ; echo No do calibration; fi; echo '
  sleep 1
  echo "exit"
) | telnet 169.254.1.2
echo
