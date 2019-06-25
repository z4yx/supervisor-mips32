#ifndef _USBHID_H
#define _USBHID_H


/**
 * Modifier masks - used for the first byte in the HID report.
 * NOTE: The second byte in the report is reserved, 0x00
 */
#define KEY_MOD_LCTRL  0x01
#define KEY_MOD_LSHIFT 0x02
#define KEY_MOD_LALT   0x04
#define KEY_MOD_LMETA  0x08
#define KEY_MOD_RCTRL  0x10
#define KEY_MOD_RSHIFT 0x20
#define KEY_MOD_RALT   0x40
#define KEY_MOD_RMETA  0x80

/* 
struct usb_hid_report {
    unsigned char modifier;
    unsigned char reserved;
    unsigned char usage_indexes[6];

} __attribute__ ((packed));

static char usb_hid_usage_table[] = {
  0,0,0,0,'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z',
// 30
  '1','2','3','4','5','6','7','8','9','0',
// 40
  '\r',0,'\b','\t',' ','-','=','[',']','\\',0,';','\'','`',',','.','/',0,
  'F','F','F','F','F','F','F','F','F','F','F','F', // F1~F12
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,'/','*','-','+','\r','1','2','3','4','5','6','7','8','9','0','.',0,0,0,'=',
  'F','F','F','F','F','F','F','F','F','F','F','F', // F13~F24
  0,0,0,0,0,0,0,0,0,0,0,0,
};

static char usb_hid_usage_table_shift[] = {
  0,0,0,0,'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z',
// 30
  '!','@','#','$','%','^','&','*','(',')',
// 40
  '\r',0,'\b','\t',' ','_','+','{','}','|',0,':','"','~','<','>','?',0,
  'F','F','F','F','F','F','F','F','F','F','F','F', // F1~F12
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,'/','*','-','+','\r','1','2','3','4','5','6','7','8','9','0','.',0,0,0,'=',
  'F','F','F','F','F','F','F','F','F','F','F','F', // F13~F24
  0,0,0,0,0,0,0,0,0,0,0,0,
};

*/

#endif