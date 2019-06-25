#ifndef _USB_H
#define _USB_H

#define USB_REQ_TYPE_OUT  0
#define USB_REQ_TYPE_IN   0x80
#define USB_REQ_TYPE_STANDARD   0
#define USB_REQ_TYPE_CLASS      0x20
#define USB_REQ_TYPE_VENDOR     0x40

#define USB_REQ_TYPE_DEVICE     0
#define USB_REQ_TYPE_INTERFACE  1
#define USB_REQ_TYPE_ENDPOINT   2
#define USB_REQ_TYPE_OTHER      3

#define GET_STATUS      0
#define CLEAR_FEATURE   1
#define SET_FEATURE     3
#define SET_ADDRESS     5
#define GET_DESCRIPTOR  6
#define SET_DESCRIPTOR  7
#define GET_CONF        8
#define SET_CONF        9
#define GET_IF          10
#define SET_IF          11
#define SYNC_FRAME      12


#define USB_DESC_TYPE_DEVICE  1
#define USB_DESC_TYPE_CONF    2
#define USB_DESC_TYPE_STR     3
#define USB_DESC_TYPE_IF      4
#define USB_DESC_TYPE_EP      5

#define USB_SET_FEATURE_PORT_RESET 4
#define USB_SET_FEATURE_PORT_POWER 8
#define USB_SET_FEATURE_PORT_CONNECTION 16


/* 
struct usb_setup_pkt {
    unsigned char req_type;
    unsigned char req;
    unsigned short val;
    unsigned short idx;
    unsigned short cnt;
} __attribute__ ((packed));


struct usb_dev_desc {
    unsigned char len;
    unsigned char desc_type;
    unsigned short bcd_usb;
    unsigned char cls;
    unsigned char sub_cls;
    unsigned char protocol;
    unsigned char max_pkt_sz;
    unsigned short vendor;
    unsigned short product;
    unsigned short bcd_dev;
    unsigned char idx_str_manufacturer;
    unsigned char idx_str_product;
    unsigned char idx_str_sn;
    unsigned char n_confs;
} __attribute__ ((packed));

struct usb_conf_desc {
    unsigned char len;
    unsigned char desc_type;
    unsigned short len_data;
    unsigned char n_ifs;
    unsigned char conf;
    unsigned char idx_str_conf;
    unsigned char attr;
    unsigned char max_power_in_2mA;
} __attribute__ ((packed));
*/

#endif