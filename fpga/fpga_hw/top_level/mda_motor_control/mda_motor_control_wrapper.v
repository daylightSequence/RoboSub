/////////////////////////////////////////////////////////////////////////
// Module: mda_motor_control_wrapper.v
// i---------------------------------------------------------------------
// Purpose: Wrapper for the mda_motor_control modules. This is the slave
//			controller which the Avalon memory mapped system interfaces with.
// ---------------------------------------------------------------------
// Version History:
//
// 2016/3/26 - 1.0: New slave controller design copied from legacy, but removed
//					direction input. Direction is now inferred from duty cycle.
// Albert Hsueh
//
// 2016/5/22 - 1.1: Copied legacy verilog and made modifications for Robosub
//					2016 competition. Using new documentation convention.
// Shai Bonen
//////////////////////////////////////////////////////////////////////////


// Registers 0-7 store the direction and on/off switch for each motor
// Registers 8-13 store the respective duty cycle
// The output should be fed to GPIO pins in the top_level configuration

`include "mda_motor_control_defines.v"

module mda_motor_control_wrapper(input clk, input reset, input chipselect, input write, input [4:0]addr, input [31:0] writedata, output [31:0] GPIO_out);
  
  // input register holding 8 moter_contoller's on and dir inputs
  // in = {mc0_on, mc0_dir, mc1_on, mc1_dir ...}
  reg [7:0] in = 8'd0;
  reg [8*`PERIOD_LENGTH-1:0] duty_cycle = 0;
  reg [15:0] period = 16'd0;
 
  always @(posedge clk)
    if (chipselect & write)
    casex (addr)
		// addr 0-7 are the in's
      5'b00000:
        in[0] <= writedata[0];
      5'b00001:
        in[1] <= writedata[0];
      5'b00010:
        in[2] <= writedata[0];
      5'b00011:
        in[3] <= writedata[0];
      5'b00100:
        in[4] <= writedata[0];
      5'b00101:
        in[5] <= writedata[0];
	  5'b00110:
        in[6] <= writedata[0];
	  5'b00111:
        in[7] <= writedata[0];
		
		// addr 8-15 are sets the duty cycles for each motor driver H-Bridge
      5'b01000: // Motor 0 H-Bridge Duty Cycle
        duty_cycle[`PERIOD_LENGTH-1:0] <= writedata[`PERIOD_LENGTH-1:0];
      5'b01001: // Motor 0 H-Bridge Duty Cycle
        duty_cycle[2*`PERIOD_LENGTH-1:`PERIOD_LENGTH] <= writedata[`PERIOD_LENGTH-1:0];
      5'b01010: // Motor 0 H-Bridge Duty Cycle
        duty_cycle[3*`PERIOD_LENGTH-1:2*`PERIOD_LENGTH] <= writedata[`PERIOD_LENGTH-1:0];
      5'b01011: // Motor 0 H-Bridge Duty Cycle
        duty_cycle[4*`PERIOD_LENGTH-1:3*`PERIOD_LENGTH] <= writedata[`PERIOD_LENGTH-1:0];
      5'b01100: // Motor 0 H-Bridge Duty Cycle
        duty_cycle[5*`PERIOD_LENGTH-1:4*`PERIOD_LENGTH] <= writedata[`PERIOD_LENGTH-1:0];
      5'b01101: // Motor 0 H-Bridge Duty Cycle
        duty_cycle[6*`PERIOD_LENGTH-1:5*`PERIOD_LENGTH] <= writedata[`PERIOD_LENGTH-1:0];
      5'b01110: // Motor 0 H-Bridge Duty Cycle
        duty_cycle[7*`PERIOD_LENGTH-1:6*`PERIOD_LENGTH] <= writedata[`PERIOD_LENGTH-1:0];
      5'b01111: // Motor 0 H-Bridge Duty Cycle
        duty_cycle[8*`PERIOD_LENGTH-1:7*`PERIOD_LENGTH] <= writedata[`PERIOD_LENGTH-1:0];
      
		// addr 16 for pwm generator period
	  5'b10000:
        period <= writedata[15:0];
      default:
        ; // do nothing
    endcase

	// generate the moter_contollers
  generate
  genvar i;
    for (i=0; i<8; i=i+1)
      begin : motor_control_loop
        mda_motor_control mc(clk, in[i], period, duty_cycle[(i+1)*`PERIOD_LENGTH-1:i*`PERIOD_LENGTH], GPIO_out[i*4+3:i*4]);
      end
  endgenerate
endmodule


/////////////////////////////////////////////////////////////////////////
// Legacy Code Below
/////////////////////////////////////////////////////////////////////////

/*
// OLD slave_controller decomissioned Mar. 26 2016 ahsueh1996
module slave_controller(input clk, input reset, input chipselect, input write, input [3:0]addr, input [31:0] writedata, output [23:0] GPIO_out);
  reg [11:0] in = 12'd0;
  reg [6*`PERIOD_LENGTH-1:0] duty_cycle = 0;
  reg [15:0] period = 16'd0;
 
  always @(posedge clk)
    if (chipselect & write)
    casex (addr)
      4'b0000:
        in[1:0] <= writedata[1:0];
      4'b0001:
        in[3:2] <= writedata[1:0];
      4'b0010:
        in[5:4] <= writedata[1:0];
      4'b0011:
        in[7:6] <= writedata[1:0];
      4'b0100:
        in[9:8] <= writedata[1:0];
      4'b0101:
        in[11:10] <= writedata[1:0];
      4'b1000:
        duty_cycle[`PERIOD_LENGTH-1:0] <= writedata[`PERIOD_LENGTH-1:0];
      4'b1001:
        duty_cycle[2*`PERIOD_LENGTH-1:`PERIOD_LENGTH] <= writedata[`PERIOD_LENGTH-1:0];
      4'b1010:
        duty_cycle[3*`PERIOD_LENGTH-1:2*`PERIOD_LENGTH] <= writedata[`PERIOD_LENGTH-1:0];
      4'b1011:
        duty_cycle[4*`PERIOD_LENGTH-1:3*`PERIOD_LENGTH] <= writedata[`PERIOD_LENGTH-1:0];
      4'b1100:
        duty_cycle[5*`PERIOD_LENGTH-1:4*`PERIOD_LENGTH] <= writedata[`PERIOD_LENGTH:0];
      4'b1101:
        duty_cycle[6*`PERIOD_LENGTH-1:5*`PERIOD_LENGTH] <= writedata[`PERIOD_LENGTH:0];
      4'b1110:
        period <= writedata[15:0];
      default:
        ; // do nothing
    endcase

  generate
  genvar i;
    for (i=0; i<6; i=i+1)
      begin : motor_control_loop
        motor_controller mc(clk, in[i*2 + 1], in[i*2], period, duty_cycle[(i+1)*`PERIOD_LENGTH-1:i*`PERIOD_LENGTH], GPIO_out[i*4+3:i*4]);
      end
  endgenerate
endmodule
*/
