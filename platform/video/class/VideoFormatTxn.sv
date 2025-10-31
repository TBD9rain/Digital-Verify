//==================================================================================================
//
//  Project : Video Verification Platform
//  Title   : VideoFormatTxn
//  Version : 1.1.0
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

    int unsigned h_total = 0;

    bit de [];
    bit hsync [];
    bit vsync [];

    bit mem_allocated = 0;


    //----------
    //  Registry
    //----------

    `uvm_object_param_utils_begin(VideoFormatTxn)
        `uvm_field_int(h_total, UVM_ALL_ON)
        `uvm_field_array_int(de, UVM_ALL_ON)
        `uvm_field_array_int(hsync, UVM_ALL_ON)
        `uvm_field_array_int(vsync, UVM_ALL_ON)
    `uvm_object_utils_end


    //--------
    //  Method
    //--------

    function new(string name="VideoFormatTxn");
        super.new(name);
    endfunction

    function void alloc_mem();
        if (h_total == 0) begin
            `uvm_fatal(get_name(), "Htotal is not set.")
        end
        if (mem_allocated) begin
            `uvm_fatal(get_name(), "Htotal format signal memory has been allocated.")
        end
        de = new[h_total];
        hsync = new[h_total];
        vsync = new[h_total];
        mem_allocated = 1;
    endfunction
endclass

