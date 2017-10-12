/***********************************************************************
 *
 *  Copyright (c) 2006-2007  Broadcom Corporation
 *  All Rights Reserved
 *
<:label-BRCM:2012:DUAL/GPL:standard

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License, version 2, as published by
the Free Software Foundation (the "GPL").

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.


A copy of the GPL is available at http://www.broadcom.com/licenses/GPLv2.php, or by
writing to the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
Boston, MA 02111-1307, USA.

:>
 *
 ************************************************************************/

#include "cms.h"
#include "cms_util.h"
#include "cms_boardioctl.h"
#if defined(AEI_INTERNET_LED_BEHAVIOR)
#include "cms_led.h"
#endif

/*
 * See:
 * bcmdrivers/opensource/include/bcm963xx/board.h
 * bcmdrivers/opensource/char/board/bcm963xx/impl1/board.c and bcm63xx_led.c
 */

void cmsLed_setWanConnected(void)
{
   devCtl_boardIoctl(BOARD_IOCTL_LED_CTRL, 0, NULL, kLedWanData, kLedStateOn, NULL);
}


void cmsLed_setWanDisconnected(void)
{
   devCtl_boardIoctl(BOARD_IOCTL_LED_CTRL, 0, NULL, kLedWanData, kLedStateOff, NULL);
}


void cmsLed_setWanFailed(void)
{
   devCtl_boardIoctl(BOARD_IOCTL_LED_CTRL, 0, NULL, kLedWanData, kLedStateFail, NULL);
}

#if defined(SUPPORT_GPL_4)
void cmsLed_setWifiLedOn(void)
{
   devCtl_boardIoctl(BOARD_IOCTL_LED_CTRL, 0, NULL, kLedWifi, kLedStateOn, NULL);
}

void cmsLed_setWifiLedOff(void)
{
   devCtl_boardIoctl(BOARD_IOCTL_LED_CTRL, 0, NULL, kLedWifi, kLedStateOff, NULL);
}

void cmsLed_setWifiLedBlink(void)
{
   devCtl_boardIoctl(BOARD_IOCTL_LED_CTRL, 0, NULL, kLedWifi, kLedStateSlowBlinkContinues, NULL);
}

void update_wifi_led_state(unsigned int state)
{
    switch (state) {
        case AEI_LED_OFF:
                devCtl_boardIoctl(BOARD_IOCTL_LED_CTRL, 0, NULL, kLedSes, kLedStateOff, NULL);
            break;
        case AEI_LED_GREEN:
                devCtl_boardIoctl(BOARD_IOCTL_LED_CTRL, 0, NULL, kLedSes, kLedStateOn, NULL);
            break;
        case AEI_LED_YELLOW:
                devCtl_boardIoctl(BOARD_IOCTL_LED_CTRL, 0, NULL, kLedSes, kLedStateAmber, NULL);
            break;
        case AEI_LED_RED:
                devCtl_boardIoctl(BOARD_IOCTL_LED_CTRL, 0, NULL, kLedSes, kLedStateFail, NULL);
            break;
        case AEI_LED_WPS_IN_PROGRESS_GREEN:
                devCtl_boardIoctl(BOARD_IOCTL_LED_CTRL, 0, NULL, kLedSes, kLedStateUserWpsInProgress, NULL);
            break;
        case AEI_LED_WPS_IN_PROGRESS_RED:
                devCtl_boardIoctl(BOARD_IOCTL_LED_CTRL, 0, NULL, kLedSes, kLedStateRedUserWpsInProgress, NULL);
            break;
        case AEI_LED_WPS_IN_PROGRESS_YELLOW:
                devCtl_boardIoctl(BOARD_IOCTL_LED_CTRL, 0, NULL, kLedSes, kLedStateAmberUserWpsInProgress, NULL);
            break;
        case AEI_LED_WPS_ERROR:
                devCtl_boardIoctl(BOARD_IOCTL_LED_CTRL, 0, NULL, kLedSes, kLedStateUserWpsError, NULL);
            break;
        case AEI_LED_WPS_SESSION_OVER_LAP_GREEN:
                devCtl_boardIoctl(BOARD_IOCTL_LED_CTRL, 0, NULL, kLedSes, kLedStateUserWpsSessionOverLap, NULL);
            break;
        case AEI_LED_WPS_SESSION_OVER_LAP_YELLOW:
                devCtl_boardIoctl(BOARD_IOCTL_LED_CTRL, 0, NULL, kLedSes, kLedStateAmberUserWpsSessionOverLap, NULL);
            break;
        default:
            cmsLog_error("no support state=%u\n");
            break;
    }
}

void update_led_brightness(char *led_name, unsigned int brightness)
{
    if (cmsUtl_strcmp(led_name, "internet") == 0)
        devCtl_boardIoctl(AEI_BOARD_IOCTL_LED_BRIGHTNESS_CTRL, 0, NULL, kLedInternet, brightness, NULL);
    else if (cmsUtl_strcmp(led_name, "wifi") == 0)
        devCtl_boardIoctl(AEI_BOARD_IOCTL_LED_BRIGHTNESS_CTRL, 0, NULL, kLedSes, brightness, NULL);
}
#endif

#if defined(AEI_INTERNET_LED_BEHAVIOR)
void update_internet_led_state(unsigned int state)
{
    switch (state) {
        case AEI_LED_OFF:
                devCtl_boardIoctl(BOARD_IOCTL_LED_CTRL, 0, NULL, kLedInternet, kLedStateOff, NULL);
            break;
        case AEI_LED_GREEN:
                devCtl_boardIoctl(BOARD_IOCTL_LED_CTRL, 0, NULL, kLedInternet, kLedStateOn, NULL);
            break;
	case AEI_LED_RED:
                devCtl_boardIoctl(BOARD_IOCTL_LED_CTRL, 0, NULL, kLedInternet, kLedStateFail, NULL);
            break;
        case AEI_LED_YELLOW:
                devCtl_boardIoctl(BOARD_IOCTL_LED_CTRL, 0, NULL, kLedInternet, kLedStateAmber, NULL);
            break;
        case AEI_LED_GREEN_BLINK:
                devCtl_boardIoctl(BOARD_IOCTL_LED_CTRL, 0, NULL, kLedInternet, kLedStateFastBlinkContinues, NULL);
            break;
        case AEI_LED_YELLOW_BLINK:
                devCtl_boardIoctl(BOARD_IOCTL_LED_CTRL, 0, NULL, kLedInternet, kLedStateAmberFastBlinkContinues, NULL);
            break;
        default:
            cmsLog_error("no support state=%u\n");
            break;
    }
}
#endif

