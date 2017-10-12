#ifndef __AEI_UTILES_H__
#define __AEI_UTILES_H__
#include "mdm_object.h"

#if defined(AEI_QUANTENNA_SUPPORT)
#define QCSAPI_TARGET_IP "169.254.1.2"
#endif

#if defined(AEI_VDSL_DSL_STATE_GUI_ACCESS_NO_AUTH)
#define AEI_DSL_CLEAR_LOG_FILE "/var/aei_dsl_clear_log.txt"
#endif

int AEI_get_value_by_file(char *file, int size, char *value);
UINT16 AEI_get_interface_mtu(char *ifname);
void AEI_createFile(char *filename, char *content);
int AEI_removeFile(char *filename);
int AEI_isFileExist(char *filename);
int AEI_get_mac_addr(char *ifname, char *mac);
int AEI_convert_space(char *src,char *dst);
int AEI_convert_spec_chars(char *src,char *dst);
char* AEI_SpeciCharEncode(char *s, int len);
char *AEI_getGUIStrValue(char *v_in, char *v_out, int v_out_len);
char *AEI_getGUIStrValue2(char *v_in, int v_in_len);
pid_t* find_pid_by_name( char* pidName);
int AEI_GetPid(char * command);
#if defined(AEI_CONFIG_JFFS) && defined(NOT_USED_24)
CmsRet AEI_writeDualPartition(char *imagePtr, UINT32 imageLen, void *msgHandle, int partition);
#endif
#if  defined(AEI_VDSL_DETECT_LOG)
typedef enum
{
    AEI_WAN_ETH,
    AEI_WAN_ADSL,
    AEI_WAN_VDSL,
}AEIWanDevType; 
#endif
#if defined(NOT_USED_6)
int AEI_save_syslog();
#endif
#endif
