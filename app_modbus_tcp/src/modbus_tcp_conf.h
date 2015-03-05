// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/*===========================================================================
 Info
 ----

 ===========================================================================*/

#ifndef __modbus_tcp_conf_h__
#define __modbus_tcp_conf_h__

/*---------------------------------------------------------------------------
 nested include files
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 constants
 ---------------------------------------------------------------------------*/

#define MODBUS_COIL_ADDRESS_START               0
#define MODBUS_COIL_ADDRESS_END                 3
#define MODBUS_DISCRETE_INPUT_ADDRESS_START     0
#define MODBUS_DISCRETE_INPUT_ADDRESS_END       1
#define MODBUS_INPUT_REGISTER_ADDRESS_START     0
#define MODBUS_INPUT_REGISTER_ADDRESS_END       0
#define MODBUS_HOLDING_REGISTER_ADDRESS_START   0
#define MODBUS_HOLDING_REGISTER_ADDRESS_END     125



// Where is the Ethernet slice connected on the Slicekit Core board
// MODBUS_TCP_ETHERNET_SLOT_{STAR|TRIANGLE|CIRCLE|SQUARE}
#define MODBUS_TCP_ETHERNET_SLOT_CIRCLE

/*---------------------------------------------------------------------------
 typedefs
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 global variables
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 extern variables
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 prototypes
 ---------------------------------------------------------------------------*/


#endif // __modbus_tcp_conf_h__
/*==========================================================================*/
