////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995-2013 Xilinx, Inc.  All rights reserved.
////////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor: Xilinx
// \   \   \/     Version: P.20131013
//  \   \         Application: netgen
//  /   /         Filename: CounterUp_4BitLoadable.v
// /___/   /\     Timestamp: Thu Dec 26 14:32:15 2013
// \   \  /  \ 
//  \___\/\___\
//             
// Command	: -w -sim -ofmt verilog C:/Users/Schuyler/Documents/GitHub/FDA_LED_test/ipcore_dir/tmp/_cg/CounterUp_4BitLoadable.ngc C:/Users/Schuyler/Documents/GitHub/FDA_LED_test/ipcore_dir/tmp/_cg/CounterUp_4BitLoadable.v 
// Device	: 6slx9tqg144-3
// Input file	: C:/Users/Schuyler/Documents/GitHub/FDA_LED_test/ipcore_dir/tmp/_cg/CounterUp_4BitLoadable.ngc
// Output file	: C:/Users/Schuyler/Documents/GitHub/FDA_LED_test/ipcore_dir/tmp/_cg/CounterUp_4BitLoadable.v
// # of Modules	: 1
// Design Name	: CounterUp_4BitLoadable
// Xilinx        : C:\Xilinx\14.7\ISE_DS\ISE\
//             
// Purpose:    
//     This verilog netlist is a verification model and uses simulation 
//     primitives which may not represent the true implementation of the 
//     device, however the netlist is functionally correct and should not 
//     be modified. This file cannot be synthesized and should only be used 
//     with supported simulation tools.
//             
// Reference:  
//     Command Line Tools User Guide, Chapter 23 and Synthesis and Simulation Design Guide, Chapter 6
//             
////////////////////////////////////////////////////////////////////////////////

`timescale 1 ns/1 ps

module CounterUp_4BitLoadable (
  clk, ce, sclr, load, l, q
)/* synthesis syn_black_box syn_noprune=1 */;
  input clk;
  input ce;
  input sclr;
  input load;
  input [3 : 0] l;
  output [3 : 0] q;
  
  // synthesis translate_off
  
  wire \blk00000001/sig00000018 ;
  wire \blk00000001/sig00000017 ;
  wire \blk00000001/sig00000016 ;
  wire \blk00000001/sig00000015 ;
  wire \blk00000001/sig00000014 ;
  wire \blk00000001/sig00000013 ;
  wire \blk00000001/sig00000012 ;
  wire \blk00000001/sig00000011 ;
  wire \blk00000001/sig00000010 ;
  wire \blk00000001/sig0000000f ;
  wire \blk00000001/sig0000000e ;
  wire \blk00000001/sig0000000d ;
  wire [3 : 0] NlwRenamedSig_OI_q;
  assign
    q[3] = NlwRenamedSig_OI_q[3],
    q[2] = NlwRenamedSig_OI_q[2],
    q[1] = NlwRenamedSig_OI_q[1],
    q[0] = NlwRenamedSig_OI_q[0];
  LUT3 #(
    .INIT ( 8'h74 ))
  \blk00000001/blk00000011  (
    .I0(l[3]),
    .I1(load),
    .I2(NlwRenamedSig_OI_q[3]),
    .O(\blk00000001/sig00000014 )
  );
  LUT3 #(
    .INIT ( 8'h74 ))
  \blk00000001/blk00000010  (
    .I0(l[2]),
    .I1(load),
    .I2(NlwRenamedSig_OI_q[2]),
    .O(\blk00000001/sig00000012 )
  );
  LUT3 #(
    .INIT ( 8'h74 ))
  \blk00000001/blk0000000f  (
    .I0(l[1]),
    .I1(load),
    .I2(NlwRenamedSig_OI_q[1]),
    .O(\blk00000001/sig00000013 )
  );
  LUT3 #(
    .INIT ( 8'h74 ))
  \blk00000001/blk0000000e  (
    .I0(l[0]),
    .I1(load),
    .I2(NlwRenamedSig_OI_q[0]),
    .O(\blk00000001/sig00000015 )
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \blk00000001/blk0000000d  (
    .C(clk),
    .CE(ce),
    .D(\blk00000001/sig0000000e ),
    .R(sclr),
    .Q(NlwRenamedSig_OI_q[0])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \blk00000001/blk0000000c  (
    .C(clk),
    .CE(ce),
    .D(\blk00000001/sig0000000f ),
    .R(sclr),
    .Q(NlwRenamedSig_OI_q[1])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \blk00000001/blk0000000b  (
    .C(clk),
    .CE(ce),
    .D(\blk00000001/sig00000010 ),
    .R(sclr),
    .Q(NlwRenamedSig_OI_q[2])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \blk00000001/blk0000000a  (
    .C(clk),
    .CE(ce),
    .D(\blk00000001/sig00000011 ),
    .R(sclr),
    .Q(NlwRenamedSig_OI_q[3])
  );
  MUXCY   \blk00000001/blk00000009  (
    .CI(\blk00000001/sig0000000d ),
    .DI(load),
    .S(\blk00000001/sig00000015 ),
    .O(\blk00000001/sig00000018 )
  );
  MUXCY   \blk00000001/blk00000008  (
    .CI(\blk00000001/sig00000018 ),
    .DI(load),
    .S(\blk00000001/sig00000013 ),
    .O(\blk00000001/sig00000017 )
  );
  MUXCY   \blk00000001/blk00000007  (
    .CI(\blk00000001/sig00000017 ),
    .DI(load),
    .S(\blk00000001/sig00000012 ),
    .O(\blk00000001/sig00000016 )
  );
  XORCY   \blk00000001/blk00000006  (
    .CI(\blk00000001/sig00000018 ),
    .LI(\blk00000001/sig00000013 ),
    .O(\blk00000001/sig0000000f )
  );
  XORCY   \blk00000001/blk00000005  (
    .CI(\blk00000001/sig00000017 ),
    .LI(\blk00000001/sig00000012 ),
    .O(\blk00000001/sig00000010 )
  );
  XORCY   \blk00000001/blk00000004  (
    .CI(\blk00000001/sig00000016 ),
    .LI(\blk00000001/sig00000014 ),
    .O(\blk00000001/sig00000011 )
  );
  XORCY   \blk00000001/blk00000003  (
    .CI(\blk00000001/sig0000000d ),
    .LI(\blk00000001/sig00000015 ),
    .O(\blk00000001/sig0000000e )
  );
  VCC   \blk00000001/blk00000002  (
    .P(\blk00000001/sig0000000d )
  );

// synthesis translate_on

endmodule

// synthesis translate_off

`ifndef GLBL
`define GLBL

`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;

    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (weak1, weak0) GSR = GSR_int;
    assign (weak1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

endmodule

`endif

// synthesis translate_on
