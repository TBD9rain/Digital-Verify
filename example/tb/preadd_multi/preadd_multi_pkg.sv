//==================================================================================================
//
//  Project         :   Digital Verify Example
//  Version         :   v1.0.0
//  Title           :   preadd_multi_pkg
//
//  Description     :   test component definition
//
//  Additional info :
//  Author          :   TBD9rain
//  Email           :
//
//==================================================================================================

package preadd_multi_pkg;

//=====================
//  PACKAGE IMPORTATION
//=====================

import msg_print_pkg::*;


//==================
//  CLASS DEFINITION
//==================

`include "classes/InputTxn.sv"
`include "classes/OutputTxn.sv"
`include "classes/ClockCnt.sv"
`include "classes/InputSeqr.sv"
`include "classes/InputSeq.sv"
`include "classes/InputDrv.sv"
`include "classes/InputMon.sv"
`include "classes/InputAgent.sv"
`include "classes/CovCollector.sv"
`include "classes/OutputMon.sv"
`include "classes/OutputAgent.sv"
`include "classes/RefModel.sv"
`include "classes/Scoreboard.sv"
`include "classes/TestEnv.sv"


endpackage

