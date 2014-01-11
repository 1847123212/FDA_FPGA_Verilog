////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995-2013 Xilinx, Inc.  All rights reserved.
////////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor: Xilinx
// \   \   \/     Version: P.20131013
//  \   \         Application: netgen
//  /   /         Filename: Counter24Bit_Up.v
// /___/   /\     Timestamp: Mon Jan 06 14:33:02 2014
// \   \  /  \ 
//  \___\/\___\
//             
// Command	: -w -sim -ofmt verilog C:/Users/Schuyler/Documents/GitHub/FDA_FPGA_Verilog/ipcore_dir/tmp/_cg/Counter24Bit_Up.ngc C:/Users/Schuyler/Documents/GitHub/FDA_FPGA_Verilog/ipcore_dir/tmp/_cg/Counter24Bit_Up.v 
// Device	: 6slx9tqg144-3
// Input file	: C:/Users/Schuyler/Documents/GitHub/FDA_FPGA_Verilog/ipcore_dir/tmp/_cg/Counter24Bit_Up.ngc
// Output file	: C:/Users/Schuyler/Documents/GitHub/FDA_FPGA_Verilog/ipcore_dir/tmp/_cg/Counter24Bit_Up.v
// # of Modules	: 1
// Design Name	: Counter24Bit_Up
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

module Counter24Bit_Up (
  clk, ce, sclr, q
)/* synthesis syn_black_box syn_noprune=1 */;
  input clk;
  input ce;
  input sclr;
  output [23 : 0] q;
  
  // synthesis translate_off
  
  wire \blk00000001/sig00000063 ;
  wire \blk00000001/sig00000062 ;
  wire \blk00000001/sig00000061 ;
  wire \blk00000001/sig00000060 ;
  wire \blk00000001/sig0000005f ;
  wire \blk00000001/sig0000005e ;
  wire \blk00000001/sig0000005d ;
  wire \blk00000001/sig0000005c ;
  wire \blk00000001/sig0000005b ;
  wire \blk00000001/sig0000005a ;
  wire \blk00000001/sig00000059 ;
  wire \blk00000001/sig00000058 ;
  wire \blk00000001/sig00000057 ;
  wire \blk00000001/sig00000056 ;
  wire \blk00000001/sig00000055 ;
  wire \blk00000001/sig00000054 ;
  wire \blk00000001/sig00000053 ;
  wire \blk00000001/sig00000052 ;
  wire \blk00000001/sig00000051 ;
  wire \blk00000001/sig00000050 ;
  wire \blk00000001/sig0000004f ;
  wire \blk00000001/sig0000004e ;
  wire \blk00000001/sig0000004d ;
  wire \blk00000001/sig0000004c ;
  wire \blk00000001/sig0000004b ;
  wire \blk00000001/sig0000004a ;
  wire \blk00000001/sig00000049 ;
  wire \blk00000001/sig00000048 ;
  wire \blk00000001/sig00000047 ;
  wire \blk00000001/sig00000046 ;
  wire \blk00000001/sig00000045 ;
  wire \blk00000001/sig00000044 ;
  wire \blk00000001/sig00000043 ;
  wire \blk00000001/sig00000042 ;
  wire \blk00000001/sig00000041 ;
  wire \blk00000001/sig00000040 ;
  wire \blk00000001/sig0000003f ;
  wire \blk00000001/sig0000003e ;
  wire \blk00000001/sig0000003d ;
  wire \blk00000001/sig0000003c ;
  wire \blk00000001/sig0000003b ;
  wire \blk00000001/sig0000003a ;
  wire \blk00000001/sig00000039 ;
  wire \blk00000001/sig00000038 ;
  wire \blk00000001/sig00000037 ;
  wire \blk00000001/sig00000036 ;
  wire \blk00000001/sig00000035 ;
  wire \blk00000001/sig00000034 ;
  wire \blk00000001/sig00000033 ;
  wire \blk00000001/sig00000032 ;
  wire \blk00000001/sig00000031 ;
  wire \blk00000001/sig00000030 ;
  wire \blk00000001/sig0000002f ;
  wire \blk00000001/sig0000002e ;
  wire \blk00000001/sig0000002d ;
  wire \blk00000001/sig0000002c ;
  wire \blk00000001/sig0000002b ;
  wire \blk00000001/sig0000002a ;
  wire \blk00000001/sig00000029 ;
  wire \blk00000001/sig00000028 ;
  wire \blk00000001/sig00000027 ;
  wire \blk00000001/sig00000026 ;
  wire \blk00000001/sig00000025 ;
  wire \blk00000001/sig00000024 ;
  wire \blk00000001/sig00000023 ;
  wire \blk00000001/sig00000022 ;
  wire \blk00000001/sig00000021 ;
  wire \blk00000001/sig00000020 ;
  wire \blk00000001/sig0000001f ;
  wire \blk00000001/sig0000001e ;
  wire \blk00000001/sig0000001d ;
  wire \blk00000001/sig0000001c ;
  wire [23 : 0] NlwRenamedSig_OI_q;
  assign
    q[23] = NlwRenamedSig_OI_q[23],
    q[22] = NlwRenamedSig_OI_q[22],
    q[21] = NlwRenamedSig_OI_q[21],
    q[20] = NlwRenamedSig_OI_q[20],
    q[19] = NlwRenamedSig_OI_q[19],
    q[18] = NlwRenamedSig_OI_q[18],
    q[17] = NlwRenamedSig_OI_q[17],
    q[16] = NlwRenamedSig_OI_q[16],
    q[15] = NlwRenamedSig_OI_q[15],
    q[14] = NlwRenamedSig_OI_q[14],
    q[13] = NlwRenamedSig_OI_q[13],
    q[12] = NlwRenamedSig_OI_q[12],
    q[11] = NlwRenamedSig_OI_q[11],
    q[10] = NlwRenamedSig_OI_q[10],
    q[9] = NlwRenamedSig_OI_q[9],
    q[8] = NlwRenamedSig_OI_q[8],
    q[7] = NlwRenamedSig_OI_q[7],
    q[6] = NlwRenamedSig_OI_q[6],
    q[5] = NlwRenamedSig_OI_q[5],
    q[4] = NlwRenamedSig_OI_q[4],
    q[3] = NlwRenamedSig_OI_q[3],
    q[2] = NlwRenamedSig_OI_q[2],
    q[1] = NlwRenamedSig_OI_q[1],
    q[0] = NlwRenamedSig_OI_q[0];
  INV   \blk00000001/blk00000061  (
    .I(NlwRenamedSig_OI_q[0]),
    .O(\blk00000001/sig0000004d )
  );
  LUT1 #(
    .INIT ( 2'h2 ))
  \blk00000001/blk00000060  (
    .I0(NlwRenamedSig_OI_q[1]),
    .O(\blk00000001/sig00000063 )
  );
  LUT1 #(
    .INIT ( 2'h2 ))
  \blk00000001/blk0000005f  (
    .I0(NlwRenamedSig_OI_q[2]),
    .O(\blk00000001/sig00000062 )
  );
  LUT1 #(
    .INIT ( 2'h2 ))
  \blk00000001/blk0000005e  (
    .I0(NlwRenamedSig_OI_q[3]),
    .O(\blk00000001/sig00000061 )
  );
  LUT1 #(
    .INIT ( 2'h2 ))
  \blk00000001/blk0000005d  (
    .I0(NlwRenamedSig_OI_q[4]),
    .O(\blk00000001/sig00000060 )
  );
  LUT1 #(
    .INIT ( 2'h2 ))
  \blk00000001/blk0000005c  (
    .I0(NlwRenamedSig_OI_q[5]),
    .O(\blk00000001/sig0000005f )
  );
  LUT1 #(
    .INIT ( 2'h2 ))
  \blk00000001/blk0000005b  (
    .I0(NlwRenamedSig_OI_q[6]),
    .O(\blk00000001/sig0000005e )
  );
  LUT1 #(
    .INIT ( 2'h2 ))
  \blk00000001/blk0000005a  (
    .I0(NlwRenamedSig_OI_q[7]),
    .O(\blk00000001/sig0000005d )
  );
  LUT1 #(
    .INIT ( 2'h2 ))
  \blk00000001/blk00000059  (
    .I0(NlwRenamedSig_OI_q[8]),
    .O(\blk00000001/sig0000005c )
  );
  LUT1 #(
    .INIT ( 2'h2 ))
  \blk00000001/blk00000058  (
    .I0(NlwRenamedSig_OI_q[9]),
    .O(\blk00000001/sig0000005b )
  );
  LUT1 #(
    .INIT ( 2'h2 ))
  \blk00000001/blk00000057  (
    .I0(NlwRenamedSig_OI_q[10]),
    .O(\blk00000001/sig0000005a )
  );
  LUT1 #(
    .INIT ( 2'h2 ))
  \blk00000001/blk00000056  (
    .I0(NlwRenamedSig_OI_q[11]),
    .O(\blk00000001/sig00000059 )
  );
  LUT1 #(
    .INIT ( 2'h2 ))
  \blk00000001/blk00000055  (
    .I0(NlwRenamedSig_OI_q[12]),
    .O(\blk00000001/sig00000058 )
  );
  LUT1 #(
    .INIT ( 2'h2 ))
  \blk00000001/blk00000054  (
    .I0(NlwRenamedSig_OI_q[13]),
    .O(\blk00000001/sig00000057 )
  );
  LUT1 #(
    .INIT ( 2'h2 ))
  \blk00000001/blk00000053  (
    .I0(NlwRenamedSig_OI_q[14]),
    .O(\blk00000001/sig00000056 )
  );
  LUT1 #(
    .INIT ( 2'h2 ))
  \blk00000001/blk00000052  (
    .I0(NlwRenamedSig_OI_q[15]),
    .O(\blk00000001/sig00000055 )
  );
  LUT1 #(
    .INIT ( 2'h2 ))
  \blk00000001/blk00000051  (
    .I0(NlwRenamedSig_OI_q[16]),
    .O(\blk00000001/sig00000054 )
  );
  LUT1 #(
    .INIT ( 2'h2 ))
  \blk00000001/blk00000050  (
    .I0(NlwRenamedSig_OI_q[17]),
    .O(\blk00000001/sig00000053 )
  );
  LUT1 #(
    .INIT ( 2'h2 ))
  \blk00000001/blk0000004f  (
    .I0(NlwRenamedSig_OI_q[18]),
    .O(\blk00000001/sig00000052 )
  );
  LUT1 #(
    .INIT ( 2'h2 ))
  \blk00000001/blk0000004e  (
    .I0(NlwRenamedSig_OI_q[19]),
    .O(\blk00000001/sig00000051 )
  );
  LUT1 #(
    .INIT ( 2'h2 ))
  \blk00000001/blk0000004d  (
    .I0(NlwRenamedSig_OI_q[20]),
    .O(\blk00000001/sig00000050 )
  );
  LUT1 #(
    .INIT ( 2'h2 ))
  \blk00000001/blk0000004c  (
    .I0(NlwRenamedSig_OI_q[21]),
    .O(\blk00000001/sig0000004f )
  );
  LUT1 #(
    .INIT ( 2'h2 ))
  \blk00000001/blk0000004b  (
    .I0(NlwRenamedSig_OI_q[22]),
    .O(\blk00000001/sig0000004e )
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \blk00000001/blk0000004a  (
    .C(clk),
    .CE(ce),
    .D(\blk00000001/sig0000001e ),
    .R(sclr),
    .Q(NlwRenamedSig_OI_q[0])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000049  (
    .C(clk),
    .CE(ce),
    .D(\blk00000001/sig0000001f ),
    .R(sclr),
    .Q(NlwRenamedSig_OI_q[1])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000048  (
    .C(clk),
    .CE(ce),
    .D(\blk00000001/sig00000020 ),
    .R(sclr),
    .Q(NlwRenamedSig_OI_q[2])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000047  (
    .C(clk),
    .CE(ce),
    .D(\blk00000001/sig00000021 ),
    .R(sclr),
    .Q(NlwRenamedSig_OI_q[3])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000046  (
    .C(clk),
    .CE(ce),
    .D(\blk00000001/sig00000022 ),
    .R(sclr),
    .Q(NlwRenamedSig_OI_q[4])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000045  (
    .C(clk),
    .CE(ce),
    .D(\blk00000001/sig00000023 ),
    .R(sclr),
    .Q(NlwRenamedSig_OI_q[5])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000044  (
    .C(clk),
    .CE(ce),
    .D(\blk00000001/sig00000024 ),
    .R(sclr),
    .Q(NlwRenamedSig_OI_q[6])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000043  (
    .C(clk),
    .CE(ce),
    .D(\blk00000001/sig00000025 ),
    .R(sclr),
    .Q(NlwRenamedSig_OI_q[7])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000042  (
    .C(clk),
    .CE(ce),
    .D(\blk00000001/sig00000026 ),
    .R(sclr),
    .Q(NlwRenamedSig_OI_q[8])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000041  (
    .C(clk),
    .CE(ce),
    .D(\blk00000001/sig00000027 ),
    .R(sclr),
    .Q(NlwRenamedSig_OI_q[9])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000040  (
    .C(clk),
    .CE(ce),
    .D(\blk00000001/sig00000028 ),
    .R(sclr),
    .Q(NlwRenamedSig_OI_q[10])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \blk00000001/blk0000003f  (
    .C(clk),
    .CE(ce),
    .D(\blk00000001/sig00000029 ),
    .R(sclr),
    .Q(NlwRenamedSig_OI_q[11])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \blk00000001/blk0000003e  (
    .C(clk),
    .CE(ce),
    .D(\blk00000001/sig0000002a ),
    .R(sclr),
    .Q(NlwRenamedSig_OI_q[12])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \blk00000001/blk0000003d  (
    .C(clk),
    .CE(ce),
    .D(\blk00000001/sig0000002b ),
    .R(sclr),
    .Q(NlwRenamedSig_OI_q[13])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \blk00000001/blk0000003c  (
    .C(clk),
    .CE(ce),
    .D(\blk00000001/sig0000002c ),
    .R(sclr),
    .Q(NlwRenamedSig_OI_q[14])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \blk00000001/blk0000003b  (
    .C(clk),
    .CE(ce),
    .D(\blk00000001/sig0000002d ),
    .R(sclr),
    .Q(NlwRenamedSig_OI_q[15])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \blk00000001/blk0000003a  (
    .C(clk),
    .CE(ce),
    .D(\blk00000001/sig0000002e ),
    .R(sclr),
    .Q(NlwRenamedSig_OI_q[16])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000039  (
    .C(clk),
    .CE(ce),
    .D(\blk00000001/sig0000002f ),
    .R(sclr),
    .Q(NlwRenamedSig_OI_q[17])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000038  (
    .C(clk),
    .CE(ce),
    .D(\blk00000001/sig00000030 ),
    .R(sclr),
    .Q(NlwRenamedSig_OI_q[18])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000037  (
    .C(clk),
    .CE(ce),
    .D(\blk00000001/sig00000031 ),
    .R(sclr),
    .Q(NlwRenamedSig_OI_q[19])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000036  (
    .C(clk),
    .CE(ce),
    .D(\blk00000001/sig00000032 ),
    .R(sclr),
    .Q(NlwRenamedSig_OI_q[20])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000035  (
    .C(clk),
    .CE(ce),
    .D(\blk00000001/sig00000033 ),
    .R(sclr),
    .Q(NlwRenamedSig_OI_q[21])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000034  (
    .C(clk),
    .CE(ce),
    .D(\blk00000001/sig00000034 ),
    .R(sclr),
    .Q(NlwRenamedSig_OI_q[22])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000033  (
    .C(clk),
    .CE(ce),
    .D(\blk00000001/sig00000035 ),
    .R(sclr),
    .Q(NlwRenamedSig_OI_q[23])
  );
  MUXCY   \blk00000001/blk00000032  (
    .CI(\blk00000001/sig0000001d ),
    .DI(\blk00000001/sig0000001c ),
    .S(\blk00000001/sig0000004d ),
    .O(\blk00000001/sig0000004c )
  );
  XORCY   \blk00000001/blk00000031  (
    .CI(\blk00000001/sig0000001d ),
    .LI(\blk00000001/sig0000004d ),
    .O(\blk00000001/sig0000001e )
  );
  XORCY   \blk00000001/blk00000030  (
    .CI(\blk00000001/sig00000036 ),
    .LI(NlwRenamedSig_OI_q[23]),
    .O(\blk00000001/sig00000035 )
  );
  MUXCY   \blk00000001/blk0000002f  (
    .CI(\blk00000001/sig0000004c ),
    .DI(\blk00000001/sig0000001d ),
    .S(\blk00000001/sig00000063 ),
    .O(\blk00000001/sig0000004b )
  );
  XORCY   \blk00000001/blk0000002e  (
    .CI(\blk00000001/sig0000004c ),
    .LI(\blk00000001/sig00000063 ),
    .O(\blk00000001/sig0000001f )
  );
  MUXCY   \blk00000001/blk0000002d  (
    .CI(\blk00000001/sig0000004b ),
    .DI(\blk00000001/sig0000001d ),
    .S(\blk00000001/sig00000062 ),
    .O(\blk00000001/sig0000004a )
  );
  XORCY   \blk00000001/blk0000002c  (
    .CI(\blk00000001/sig0000004b ),
    .LI(\blk00000001/sig00000062 ),
    .O(\blk00000001/sig00000020 )
  );
  MUXCY   \blk00000001/blk0000002b  (
    .CI(\blk00000001/sig0000004a ),
    .DI(\blk00000001/sig0000001d ),
    .S(\blk00000001/sig00000061 ),
    .O(\blk00000001/sig00000049 )
  );
  XORCY   \blk00000001/blk0000002a  (
    .CI(\blk00000001/sig0000004a ),
    .LI(\blk00000001/sig00000061 ),
    .O(\blk00000001/sig00000021 )
  );
  MUXCY   \blk00000001/blk00000029  (
    .CI(\blk00000001/sig00000049 ),
    .DI(\blk00000001/sig0000001d ),
    .S(\blk00000001/sig00000060 ),
    .O(\blk00000001/sig00000048 )
  );
  XORCY   \blk00000001/blk00000028  (
    .CI(\blk00000001/sig00000049 ),
    .LI(\blk00000001/sig00000060 ),
    .O(\blk00000001/sig00000022 )
  );
  MUXCY   \blk00000001/blk00000027  (
    .CI(\blk00000001/sig00000048 ),
    .DI(\blk00000001/sig0000001d ),
    .S(\blk00000001/sig0000005f ),
    .O(\blk00000001/sig00000047 )
  );
  XORCY   \blk00000001/blk00000026  (
    .CI(\blk00000001/sig00000048 ),
    .LI(\blk00000001/sig0000005f ),
    .O(\blk00000001/sig00000023 )
  );
  MUXCY   \blk00000001/blk00000025  (
    .CI(\blk00000001/sig00000047 ),
    .DI(\blk00000001/sig0000001d ),
    .S(\blk00000001/sig0000005e ),
    .O(\blk00000001/sig00000046 )
  );
  XORCY   \blk00000001/blk00000024  (
    .CI(\blk00000001/sig00000047 ),
    .LI(\blk00000001/sig0000005e ),
    .O(\blk00000001/sig00000024 )
  );
  MUXCY   \blk00000001/blk00000023  (
    .CI(\blk00000001/sig00000046 ),
    .DI(\blk00000001/sig0000001d ),
    .S(\blk00000001/sig0000005d ),
    .O(\blk00000001/sig00000045 )
  );
  XORCY   \blk00000001/blk00000022  (
    .CI(\blk00000001/sig00000046 ),
    .LI(\blk00000001/sig0000005d ),
    .O(\blk00000001/sig00000025 )
  );
  MUXCY   \blk00000001/blk00000021  (
    .CI(\blk00000001/sig00000045 ),
    .DI(\blk00000001/sig0000001d ),
    .S(\blk00000001/sig0000005c ),
    .O(\blk00000001/sig00000044 )
  );
  XORCY   \blk00000001/blk00000020  (
    .CI(\blk00000001/sig00000045 ),
    .LI(\blk00000001/sig0000005c ),
    .O(\blk00000001/sig00000026 )
  );
  MUXCY   \blk00000001/blk0000001f  (
    .CI(\blk00000001/sig00000044 ),
    .DI(\blk00000001/sig0000001d ),
    .S(\blk00000001/sig0000005b ),
    .O(\blk00000001/sig00000043 )
  );
  XORCY   \blk00000001/blk0000001e  (
    .CI(\blk00000001/sig00000044 ),
    .LI(\blk00000001/sig0000005b ),
    .O(\blk00000001/sig00000027 )
  );
  MUXCY   \blk00000001/blk0000001d  (
    .CI(\blk00000001/sig00000043 ),
    .DI(\blk00000001/sig0000001d ),
    .S(\blk00000001/sig0000005a ),
    .O(\blk00000001/sig00000042 )
  );
  XORCY   \blk00000001/blk0000001c  (
    .CI(\blk00000001/sig00000043 ),
    .LI(\blk00000001/sig0000005a ),
    .O(\blk00000001/sig00000028 )
  );
  MUXCY   \blk00000001/blk0000001b  (
    .CI(\blk00000001/sig00000042 ),
    .DI(\blk00000001/sig0000001d ),
    .S(\blk00000001/sig00000059 ),
    .O(\blk00000001/sig00000041 )
  );
  XORCY   \blk00000001/blk0000001a  (
    .CI(\blk00000001/sig00000042 ),
    .LI(\blk00000001/sig00000059 ),
    .O(\blk00000001/sig00000029 )
  );
  MUXCY   \blk00000001/blk00000019  (
    .CI(\blk00000001/sig00000041 ),
    .DI(\blk00000001/sig0000001d ),
    .S(\blk00000001/sig00000058 ),
    .O(\blk00000001/sig00000040 )
  );
  XORCY   \blk00000001/blk00000018  (
    .CI(\blk00000001/sig00000041 ),
    .LI(\blk00000001/sig00000058 ),
    .O(\blk00000001/sig0000002a )
  );
  MUXCY   \blk00000001/blk00000017  (
    .CI(\blk00000001/sig00000040 ),
    .DI(\blk00000001/sig0000001d ),
    .S(\blk00000001/sig00000057 ),
    .O(\blk00000001/sig0000003f )
  );
  XORCY   \blk00000001/blk00000016  (
    .CI(\blk00000001/sig00000040 ),
    .LI(\blk00000001/sig00000057 ),
    .O(\blk00000001/sig0000002b )
  );
  MUXCY   \blk00000001/blk00000015  (
    .CI(\blk00000001/sig0000003f ),
    .DI(\blk00000001/sig0000001d ),
    .S(\blk00000001/sig00000056 ),
    .O(\blk00000001/sig0000003e )
  );
  XORCY   \blk00000001/blk00000014  (
    .CI(\blk00000001/sig0000003f ),
    .LI(\blk00000001/sig00000056 ),
    .O(\blk00000001/sig0000002c )
  );
  MUXCY   \blk00000001/blk00000013  (
    .CI(\blk00000001/sig0000003e ),
    .DI(\blk00000001/sig0000001d ),
    .S(\blk00000001/sig00000055 ),
    .O(\blk00000001/sig0000003d )
  );
  XORCY   \blk00000001/blk00000012  (
    .CI(\blk00000001/sig0000003e ),
    .LI(\blk00000001/sig00000055 ),
    .O(\blk00000001/sig0000002d )
  );
  MUXCY   \blk00000001/blk00000011  (
    .CI(\blk00000001/sig0000003d ),
    .DI(\blk00000001/sig0000001d ),
    .S(\blk00000001/sig00000054 ),
    .O(\blk00000001/sig0000003c )
  );
  XORCY   \blk00000001/blk00000010  (
    .CI(\blk00000001/sig0000003d ),
    .LI(\blk00000001/sig00000054 ),
    .O(\blk00000001/sig0000002e )
  );
  MUXCY   \blk00000001/blk0000000f  (
    .CI(\blk00000001/sig0000003c ),
    .DI(\blk00000001/sig0000001d ),
    .S(\blk00000001/sig00000053 ),
    .O(\blk00000001/sig0000003b )
  );
  XORCY   \blk00000001/blk0000000e  (
    .CI(\blk00000001/sig0000003c ),
    .LI(\blk00000001/sig00000053 ),
    .O(\blk00000001/sig0000002f )
  );
  MUXCY   \blk00000001/blk0000000d  (
    .CI(\blk00000001/sig0000003b ),
    .DI(\blk00000001/sig0000001d ),
    .S(\blk00000001/sig00000052 ),
    .O(\blk00000001/sig0000003a )
  );
  XORCY   \blk00000001/blk0000000c  (
    .CI(\blk00000001/sig0000003b ),
    .LI(\blk00000001/sig00000052 ),
    .O(\blk00000001/sig00000030 )
  );
  MUXCY   \blk00000001/blk0000000b  (
    .CI(\blk00000001/sig0000003a ),
    .DI(\blk00000001/sig0000001d ),
    .S(\blk00000001/sig00000051 ),
    .O(\blk00000001/sig00000039 )
  );
  XORCY   \blk00000001/blk0000000a  (
    .CI(\blk00000001/sig0000003a ),
    .LI(\blk00000001/sig00000051 ),
    .O(\blk00000001/sig00000031 )
  );
  MUXCY   \blk00000001/blk00000009  (
    .CI(\blk00000001/sig00000039 ),
    .DI(\blk00000001/sig0000001d ),
    .S(\blk00000001/sig00000050 ),
    .O(\blk00000001/sig00000038 )
  );
  XORCY   \blk00000001/blk00000008  (
    .CI(\blk00000001/sig00000039 ),
    .LI(\blk00000001/sig00000050 ),
    .O(\blk00000001/sig00000032 )
  );
  MUXCY   \blk00000001/blk00000007  (
    .CI(\blk00000001/sig00000038 ),
    .DI(\blk00000001/sig0000001d ),
    .S(\blk00000001/sig0000004f ),
    .O(\blk00000001/sig00000037 )
  );
  XORCY   \blk00000001/blk00000006  (
    .CI(\blk00000001/sig00000038 ),
    .LI(\blk00000001/sig0000004f ),
    .O(\blk00000001/sig00000033 )
  );
  MUXCY   \blk00000001/blk00000005  (
    .CI(\blk00000001/sig00000037 ),
    .DI(\blk00000001/sig0000001d ),
    .S(\blk00000001/sig0000004e ),
    .O(\blk00000001/sig00000036 )
  );
  XORCY   \blk00000001/blk00000004  (
    .CI(\blk00000001/sig00000037 ),
    .LI(\blk00000001/sig0000004e ),
    .O(\blk00000001/sig00000034 )
  );
  GND   \blk00000001/blk00000003  (
    .G(\blk00000001/sig0000001d )
  );
  VCC   \blk00000001/blk00000002  (
    .P(\blk00000001/sig0000001c )
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
