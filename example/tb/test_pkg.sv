//==================================================================================================
//
//  Project         :   Digital Verify Example
//  Version         :   v1.3.1
//  Title           :   test_pkg
//
//  Description     :   test component definition
//
//  Additional info :
//  Author          :   TBD9rain
//  Email           :
//
//==================================================================================================

package test_pkg;

//=====================
//  PACKAGE IMPORTATION
//=====================

import msg_print_pkg::*;


//=========================
//  Verification Components
//=========================


`include "InputTxn.sv"
`include "OutputTxn.sv"
`include "ClockCnt.sv"
`include "InputSeqr.sv"
`include "InputSeq.sv"
`include "InputDrv.sv"
`include "InputMon.sv"
`include "InputAgent.sv"
`include "CovCollector.sv"
`include "OutputMon.sv"
`include "OutputAgent.sv"
`include "RefModel.sv"
`include "Scoreboard.sv"
`include "TestEnv.sv"

endpackage

