//==================================================================================================
//
//  Project : Video Verification Platform
//  Title   : video_pkg
//  Version : 1.0.0
//
//  Description
//
//  Additional info
//
//  Author  : TBD9rain
//
//==================================================================================================

package video_pkg;

`include "uvm_macros.svh"
import uvm_pkg::*;


typedef struct packed {
    int unsigned h_active;
    int unsigned h_fp;
    int unsigned h_sync;
    int unsigned h_bp;
    int unsigned v_active;
    int unsigned v_fp;
    int unsigned v_sync;
    int unsigned v_bp;
    bit h_sync_pos;
    bit v_sync_pos;
} video_timing_t;


`include "FrameDataTxn.sv"
`include "FrameDataSqr.sv"
`include "FrameDataDrv.sv"
`include "FrameDataMon.sv"
`include "FrameDataAgt.sv"
`include "FrameDataRefMdl.sv"
`include "FrameDataScb.sv"
`include "FrameDataEnv.sv"
`include "FrameDataSeq.sv"
`include "VideoTest.sv"

endpackage

