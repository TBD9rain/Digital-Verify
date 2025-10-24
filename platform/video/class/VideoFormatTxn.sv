//==================================================================================================
//
//  Project : Video Verification Platform
//  Title   : VideoFormatTxn
//  Version : 1.0.0
//
//  Description
//      video format transaction for timing monitor
//      internal methods:
//          - range comparison
//
//  Additional info
//
//  Author  : TBD9rain
//
//==================================================================================================

class VideoFormatTxn extends uvm_sequence_item;

    //----------
    //  Variable
    //----------

    bit de;
    bit hsync;
    bit vsync;

    //  time stamp
    longint unsigned timestamp = 0;


    //----------
    //  Registry
    //----------

    `uvm_object_param_utils_begin(VideoFormatTxn)
        `uvm_field_int(de, UVM_ALL_ON)
        `uvm_field_int(hsync, UVM_ALL_ON)
        `uvm_field_int(vsync, UVM_ALL_ON)

        `uvm_field_int(timestamp, UVM_ALL_ON | UVM_NOCOMPARE)
    `uvm_object_utils_end


    //--------
    //  Method
    //--------

    function new(string name="VideoFormatTxn");
        super.new(name);
    endfunction
endclass

