#ifndef __AEI_CMS_H__
#define __AEI_CMS_H__

#if defined(AEI_VDSL_WP) && defined(AEI_VDSL_DHCP_LEASE)
#define AEI_OPT60_VENDOR_ID     "VENDOR_ID"
#define AEI_OPT60_PRODUCT_TYPE  "PRODUCT_TYPE"
#define AEI_OPT60_SOFTWARE_VER  "VERSION"
#define AEI_OPT60_PROTOCOL_VER  "PROTOCOL"
#define AEI_OPT60_WP_STRING     "ACTIONTEC_WP"
#if defined(AEI_VDSL_WP_AUTO_CONFIG)
#define AEI_OPT60_WP_CAP  "CAPABILITY"
#endif

#define AEI_WP_VENDOR_ID_LEN    32
#define AEI_WP_PRODUCT_TYPE_LEN 32
#define AEI_WP_FIRMWARE_LEN     32
#define AEI_WP_PROTOCOL_LEN     32 
#if defined(AEI_VDSL_WP_AUTO_CONFIG)
#define AEI_WP_CAP_LEN     32
#endif

#endif

#ifdef AEI_DUAL_IMAGE_CONFIG
#define AEI_IMAGE1  "image1"
#define AEI_IMAGE2  "image2"
#endif

#endif /* __AEI_CMS_H__ */
