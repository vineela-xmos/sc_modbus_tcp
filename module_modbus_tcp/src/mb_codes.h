// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/*===========================================================================
 Info
 ----
 
 ===========================================================================*/

#ifndef __mb_codes_h__
#define __mb_codes_h__

/*---------------------------------------------------------------------------
 nested include files
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 constants
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 typedefs
 ---------------------------------------------------------------------------*/
/* Modbus Master commands */
enum modbus_cmd
{
  MODBUS_READ_COIL              = 0x01,
  MODBUS_READ_DISCRETE_INPUT    = 0x02,
  MODBUS_READ_HOLDING_REGISTER  = 0x03,
  MODBUS_READ_INPUT_REGISTER    = 0x04,
  MODBUS_WRITE_SINGLE_COIL      = 0x05,
  MODBUS_WRITE_SINGLE_REGISTER  = 0x06,
};

/* Modbus Read/write operation errors */
enum modbus_error
{
  MODBUS_READ_1BIT_ERROR  = 2,
  MODBUS_READ_16BIT_ERROR = 0,
  MODBUS_WRITE_ERROR      = 0,
};

/*---------------------------------------------------------------------------
 global variables
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 extern variables
 ---------------------------------------------------------------------------*/
 
/*---------------------------------------------------------------------------
 prototypes
 ---------------------------------------------------------------------------*/

#endif // __mb_codes_h__
/*==========================================================================*/
