//==================================================================================================
//
//  Project : Video Verification Platform
//  Title   : video_pkg
//  Version : 1.0.3
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


`include "FrameData/Txn.sv"
`include "FrameData/Sqr.sv"
`include "FrameData/Drv.sv"
`include "FrameData/Mon.sv"
`include "FrameData/Agt.sv"
`include "FrameData/RefMdl.sv"
`include "FrameData/Scb.sv"
`include "FrameData/Env.sv"
`include "FrameData/Seq.sv"

`include "FrameRowCtrl/Txn.sv"
`include "FrameRowCtrl/Mon.sv"
`include "FrameRowCtrl/Agt.sv"
`include "FrameRowCtrl/RefMdl.sv"
`include "FrameRowCtrl/Scb.sv"
`include "FrameRowCtrl/Env.sv"

`include "VideoTest.sv"

endpackage

