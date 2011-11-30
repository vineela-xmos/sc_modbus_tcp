// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#ifndef TCPIP_IF_H_
#define TCPIP_IF_H_
/*===========================================================================
Filename:
Project :
Author  :
Version :
Purpose
-----------------------------------------------------------------------------


===========================================================================*/

/*---------------------------------------------------------------------------
nested include files
---------------------------------------------------------------------------*/
#include "xtcp_client.h"

/*---------------------------------------------------------------------------
constants
---------------------------------------------------------------------------*/
#define SIZE_TCP_DATA               260
#define LISTEN_PORT                 502
#define NUM_CONNECTIONS             1

/*---------------------------------------------------------------------------
extern variables
---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
typedefs
---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
global variables
---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
prototypes
---------------------------------------------------------------------------*/
void tcp_reset(chanend tcp_svr);
void tcp_handle_event(chanend tcp_svr, REFERENCE_PARAM(xtcp_connection_t, conn));

#endif // TCPIP_IF_H_
/*=========================================================================*/
