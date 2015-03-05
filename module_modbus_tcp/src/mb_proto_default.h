// Copyright (c) 2015, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/*===========================================================================
 Info
 ----

 ===========================================================================*/

#ifndef MB_PROTO_DEFAULT_H_
#define MB_PROTO_DEFAULT_H_


/*---------------------------------------------------------------------------
 nested include files
 ---------------------------------------------------------------------------*/
#ifdef __modbus_tcp_conf_h_exists__
#include "modbus_tcp_conf.h"
#endif

/**
 * Default Modbus device addresses. May be defined in modbus_rtu_conf.h by user.
 */
#ifndef MODBUS_COIL_ADDRESS_START
#define MODBUS_COIL_ADDRESS_START               0
#endif
#ifndef MODBUS_COIL_ADDRESS_END
#define MODBUS_COIL_ADDRESS_END                 2000
#endif
#ifndef MODBUS_DISCRETE_INPUT_ADDRESS_START
#define MODBUS_DISCRETE_INPUT_ADDRESS_START     0
#endif
#ifndef MODBUS_DISCRETE_INPUT_ADDRESS_END
#define MODBUS_DISCRETE_INPUT_ADDRESS_END       2000
#endif
#ifndef MODBUS_INPUT_REGISTER_ADDRESS_START
#define MODBUS_INPUT_REGISTER_ADDRESS_START     0
#endif
#ifndef MODBUS_INPUT_REGISTER_ADDRESS_END
#define MODBUS_INPUT_REGISTER_ADDRESS_END       125
#endif
#ifndef MODBUS_HOLDING_REGISTER_ADDRESS_START
#define MODBUS_HOLDING_REGISTER_ADDRESS_START   0
#endif
#ifndef MODBUS_HOLDING_REGISTER_ADDRESS_END
#define MODBUS_HOLDING_REGISTER_ADDRESS_END     125
#endif



#endif /* MB_PROTO_DEFAULT_H_ */
