// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/*===========================================================================
 Info
 ----

 ===========================================================================*/

/*---------------------------------------------------------------------------
 include files
 ---------------------------------------------------------------------------*/
#include <platform.h>
#include "modbus_tcp.h"
#include "i2c.h"
#include "timer.h"

/*---------------------------------------------------------------------------
 constants
 ---------------------------------------------------------------------------*/
// Timer interval to scan button events
#define DEBOUNCE_INTERVAL     XS1_TIMER_HZ/50
#define BUTTON_1_PRESS_VALUE  0x2

/*---------------------------------------------------------------------------
 ports and clocks
 ---------------------------------------------------------------------------*/
// These intializers are taken from the ethernet_board_support.h header for
// XMOS dev boards. If you are using a different board you will need to
// supply explicit port structure intializers for these values
ethernet_xtcp_ports_t xtcp_ports =
{
  on tile[1]: OTP_PORTS_INITIALIZER,
              ETHERNET_DEFAULT_SMI_INIT,
              ETHERNET_DEFAULT_MII_INIT_lite,
              ETHERNET_DEFAULT_RESET_INTERFACE_INIT
};

// GPIO slice ports
on tile[1]: r_i2c p_i2c = {XS1_PORT_1F, XS1_PORT_1B, 1000};
on tile[1]: port p_led = XS1_PORT_4A;
on tile[1]: port p_button = XS1_PORT_4C;

/*---------------------------------------------------------------------------
 typedefs
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 global variables
 ---------------------------------------------------------------------------*/
// IP Config - change this to suit your network. All 0s to use DHCP
xtcp_ipconfig_t ipconfig = {
  { 169, 254, 231, 27 },
  { 255, 255, 0, 0 },
  { 0, 0, 0, 0 }
};

// Global button status
unsigned short button_status = 0;

/*---------------------------------------------------------------------------
 static variables
 ---------------------------------------------------------------------------*/
//Temperature to ADC look up table
static int TEMPERATURE_LUT[][2] = { {-10, 850}, {-5, 800}, {0, 750}, {5, 700},
                                    {10, 650}, {15, 600}, {20, 550}, {25, 500},
                                    {30, 450}, {35, 400}, {40, 350}, {45, 300},
                                    {50, 250}, {55, 230}, {60, 210}
};

/*---------------------------------------------------------------------------
 static prototypes
 ---------------------------------------------------------------------------*/

/*==========================================================================*/
/**
 *  Read temperature value from the sensor using I2C
 *
 *  \param p_i2c  I2C ports that connects to the temperature sensor
 *  \return       Current recorded temperature on the sensor
 **/
static int read_temperature(r_i2c &p_i2c)
{
  int adc_value;
  int i = 0, x1, y1, x2, y2, temperature;
  unsigned char i2c_data[2];

  i2c_master_rx(0x28, i2c_data, sizeof(i2c_data), p_i2c);
  i2c_data[0] = i2c_data[0] & 0x0F;
  adc_value = (i2c_data[0] << 6) | (i2c_data[1] >> 2);

  while(adc_value < TEMPERATURE_LUT[i][1])  { i++; }

  //Calculate Linear interpolation using: y = y1+(x-x1)*(y2-y1)/(x2-x1)
  x1 = TEMPERATURE_LUT[i - 1][1];
  y1 = TEMPERATURE_LUT[i - 1][0];
  x2 = TEMPERATURE_LUT[i][1];
  y2 = TEMPERATURE_LUT[i][0];
  temperature = y1 + (((adc_value - x1) * (y2 - y1)) / (x2 - x1));

  return temperature;
}

/*==========================================================================*/
/**
 *  Read coil values. LEDs on the GPIO slice are imitated as coils. In the
 *  Simply Modbus PC application: First Coil 1, Number of Coils 4
 *  Output status byte is of format:
 *  +----+----+----+----+------+------+------+------+
 *  | XX | XX | XX | XX | LED3 | LED2 | LED1 | LED0 |
 *  +----+----+----+----+------+------+------+------+
 *
 *  Where,
 *  Bit0 is LED0 status (1 is OFF and 0 is ON)
 *  Bit1 is LED1 status (1 is OFF and 0 is ON)
 *  Bit2 is LED2 status (1 is OFF and 0 is ON)
 *  Bit3 is LED3 status (1 is OFF and 0 is ON)
 *  XX is Don't care.
 *  On Read coil success it returns MODBUS_READ_OR_WRITE_OK
 *  Other coil addresses return as device failures (no LEDs at such addresses)
 *  Device failure return value for coil = MODBUS_READ_OR_WRITE_ERROR
 *  (present in mb_codes.h)
 *
 *  \param address    address of coil to read
 *  \rtnval           coil value
 *  \return           coil status
 **/
static short read_coil(unsigned short address, unsigned short &rtnval)
{
  unsigned char led_status = 0;
  rtnval = 0;

  if(address > 3) { return MODBUS_READ_OR_WRITE_ERROR; }

  p_led :> led_status;
  p_led <: led_status;

  if(led_status & (0x01 << address))
  {
    rtnval = 1;
    return MODBUS_READ_OR_WRITE_OK;
  }
  else
  {
    rtnval = 0;
    return MODBUS_READ_OR_WRITE_OK;
  }
}

/*==========================================================================*/
/**
 *  Read Discrete Input values. Buttons on the GPIO slice are imitated as
 *  discrete inputs. In the Simply Modbus PC application: First Coil 1,
 *  Number of Coils 2. Output status byte is of format:
 *  +----+----+----+----+----+----+-----+-----+
 *  | XX | XX | XX | XX | XX | XX | SW2 | SW1 |
 *  +----+----+----+----+----+----+-----+-----+
 *
 *  Where,
 *  Bit0 is SW1 status (1 is Button Pressed)
 *  Bit1 is SW2 status (1 is Button Pressed)
 *  XX is Don't care.
 *  On Read Discrete Input success it returns MODBUS_READ_OR_WRITE_OK
 *  Other addresses return as device failures (no Buttons at such addresses)
 *  Device failure return value for discrete input = MODBUS_READ_OR_WRITE_ERROR
 *  (present in mb_codes.h)
 *
 *  \param address    address of discrete input to read
 *  \rtnval           discrete input value
 *  \return           return status
 **/
static short read_discrete_input(unsigned short address, unsigned short &rtnval)
{
  rtnval = button_status;

  if(address > 1)
  {
    return MODBUS_READ_OR_WRITE_ERROR;
  }

  button_status &= ~(1 << address);
  if(rtnval & (1 << address))
  {
    rtnval = 1;
    return MODBUS_READ_OR_WRITE_OK;
  }
  rtnval = 0;
  return MODBUS_READ_OR_WRITE_OK;
}

/*==========================================================================*/
/**
 *  Read Holding Register values. The 32-bit timer available is imitated as holding register.
 *  LSB of the timer is read in this app. Return value is connected to Holding Register
 *  address 0 of the Modbus.
 *  On Read Holding Register success it returns MODBUS_READ_OR_WRITE_OK
 *  All addresses return as device failures (no Holding Register at such
 *  addresses)
 *  Device failure return value for Holding register = MODBUS_READ_OR_WRITE_ERROR
 *  (present in mb_codes.h)
 *
 *  \param address    address of Holding Register to read
 *  \rtnval           Return timer LSB value
 *  \return           Holding Register value
 **/
static short read_holding_register(unsigned short address, unsigned short &rtnval)
{
  timer tmr;
  unsigned short temp;
  if(address == 0)
    {
      tmr :> temp;
      rtnval = temp & 0xFFFF;
      return MODBUS_READ_OR_WRITE_OK;
    }

  return MODBUS_READ_OR_WRITE_ERROR;
}

/*==========================================================================*/
/**
 *  Read Input Register values. The temperature sensor present on the GPIO slice
 *  is imitated as an Input register. Temperature from this sensor is read using
 *  I2C. This sensor is connected to Input Register address 0 of the Modbus.
 *  On Read Input Register success it returns MODBUS_READ_OR_WRITE_OK
 *  All other addresses return as device failures (no Input Register at such
 *  addresses)
 *  Device failure return value for Input Register = MODBUS_READ_OR_WRITE_ERROR
 *  (present in mb_codes.h)
 *
 *  \param address    address of Input Register to read
 *  \rtnval           Register Value
 *  \return           return status
 **/
static short read_input_register(unsigned short address, unsigned short &rtnval)
{
  rtnval = 0;
  if(address == 0)
  {
    rtnval = (unsigned short)(read_temperature(p_i2c));
    return MODBUS_READ_OR_WRITE_OK;
  }
  else
  {
    return MODBUS_READ_OR_WRITE_ERROR;
  }
}

/*==========================================================================*/
/**
 *  Write to coils. LEDs on the GPIO slice are imitated as coils which would
 *  just toggle its state (ON/OFF) on this command. In the Simply Modbus Write
 *  window:
 *  Modbus First Register 1 = LED0
 *  Modbus First Register 2 = LED1
 *  Modbus First Register 3 = LED2
 *  Modbus First Register 4 = LED3
 *  On Write Single Coil success it retuns MODBUS_READ_OR_WRITE_OK
 *  Other coil addresses return as device failures (no LEDs at such addresses)
 *  Device failure return value for write coil = MODBUS_WRITE_ERROR
 *  (present in mb_codes.h)
 *
 *  \param address    address of coil to toggle
 *  \return           write status
 **/
static short write_single_coil(unsigned short address,
                                        unsigned short value, unsigned short &rtnval)
{
  unsigned short led_status;
  unsigned short led_value;
  rtnval = 0;
  if(address > 3)
  {
    return MODBUS_READ_OR_WRITE_ERROR;
  }

  p_led :> led_status;

  if(value == 0){
      led_value = 0;
  }
  else{
      led_value = 1;
  }

  if((led_status & (1 << address)) == led_value){

   }
   else if(led_status & (1 << address))
   {
     led_status &= ~(1 << address);
   }
   else
   {
     led_status |= (1 << address);
   }

  p_led <: led_status;
  return MODBUS_READ_OR_WRITE_OK;
}

/*==========================================================================*/
/**
 *  Write to Register. Not implemented in this app.
 *  All addresses return as device failures (no Register at such addresses)
 *  Device failure return value for Write register = MODBUS_READ_OR_WRITE_ERROR
 *  (present in mb_codes.h)
 *
 *  \param address    address of Register to write to
 *  \return           write status
 **/
static short write_single_register(unsigned short address,
                                            unsigned short value, unsigned short &rtnval)
{
  rtnval = 0;
  return MODBUS_READ_OR_WRITE_ERROR;
}

/*==========================================================================*/
/**
 *  Device Application. This task maps Modbus commands to external devices such
 *  as coils / registers. In this Demo application:
 *  Coils are mapped to LEDs on the GPIO Slice.
 *  Discrete Input are mapped to Buttons on the GPIO Slice.
 *  Holding Registers are mapped to Timer
 *  Input Registers are mapped to Temperature sensor on the GPIO Slice..
 *
 *  \param c_modbus   channel to receive Modbus commands from the
 *                    modbus_tcp_server
 *  \return           None
 **/
static void device_application(chanend c_modbus)
{
  int scan_button_flag = 1;
  unsigned button_state_1 = 0;
  unsigned button_state_2 = 0;
  timer t_scan_button_flag;
  unsigned time;

  unsigned char i2c_register[1] = {0x13};
  i2c_master_write_reg(0x28, 0x00, i2c_register, 1, p_i2c);

  set_port_drive_low(p_button);
  t_scan_button_flag :> time;
  p_button :> button_state_1;

  while(1)
  {
    select
    {
      // Listen to Modbus TCP events
      case c_modbus :> unsigned char cmd:
      {
        unsigned short address, value, rtnval;
        short rtnstatus;

        c_modbus :> address;
        c_modbus :> value;

        switch(cmd)
        {
          case MODBUS_READ_COIL:
          {
            rtnstatus = read_coil(address, rtnval);
            c_modbus <: rtnstatus;
            c_modbus <: rtnval;
            break;
          }

          case MODBUS_READ_DISCRETE_INPUT:
          {
            rtnstatus = read_discrete_input(address, rtnval);
            c_modbus <: rtnstatus;
            c_modbus <: rtnval;
            break;
          }

          case MODBUS_READ_HOLDING_REGISTER:
          {
            rtnstatus = read_holding_register(address, rtnval);
            c_modbus <: rtnstatus;
            c_modbus <: rtnval;
            break;
          }

          case MODBUS_READ_INPUT_REGISTER:
          {
            rtnstatus = read_input_register(address, rtnval);
            c_modbus <: rtnstatus;
            c_modbus <: rtnval;
            break;
          }

          case MODBUS_WRITE_SINGLE_COIL:
          {
            rtnstatus = write_single_coil(address, value, rtnval);
            c_modbus <: rtnstatus;
            c_modbus <: rtnval;
            break;
          }

          case MODBUS_WRITE_SINGLE_REGISTER:
          {
            rtnstatus = write_single_register(address, value, rtnval);
            c_modbus <: rtnstatus;
            c_modbus <: rtnval;
            break;
          }

          default: break;
        } // switch(cmd)

        break;

      } // case c_modbus

      case scan_button_flag=> p_button when pinsneq(button_state_1) :> button_state_1 :
      {
        t_scan_button_flag :> time;
        scan_button_flag = 0;
        break;
      }

      case !scan_button_flag => t_scan_button_flag when timerafter(time + DEBOUNCE_INTERVAL) :> void:
      {
        p_button :> button_state_2;
        if(button_state_1 == button_state_2)
        {
          if(button_state_1 == BUTTON_1_PRESS_VALUE)
          {
            button_status |= 0x01;
          }
          if(button_state_2 == BUTTON_1_PRESS_VALUE-1)
          {
            button_status |= 0x02;
          }
        }
        scan_button_flag = 1;
        break;
      }
    }
  }
}

/*---------------------------------------------------------------------------
 Main Entry Point
 ---------------------------------------------------------------------------*/
int main(void)
{
  chan c_modbus;

  par
  {
    // The Modbus server
    on tile[1]: modbus_tcp_server(c_modbus, xtcp_ports, ipconfig);
    // The device application
    on tile[1]: device_application(c_modbus);
  } // par

  return 0;
}

/*==========================================================================*/
