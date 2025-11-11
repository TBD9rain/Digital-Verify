//==================================================================================================
//
//  Project : Video Verification Platform
//  Title   : Txn
//  Version : 1.0.1
//
//  Description
//      video frame data transaction with video timing variables
//      internal methods:
//          - alloc_mem: allocate memory for frame_data
//          - gen_color_bar: generate color bars in frame_data
//          - read_bin_frame: read frame data from frame_data
//
//  Additional info
//
//  Author  : TBD9rain
//
//==================================================================================================

class FrameDataTxn #(
    parameter int unsigned DATA_WIDTH = 8
) extends uvm_sequence_item;

    //----------
    //  Variable
    //----------

    //  video frame size
    int frame_width  = 0;
    int frame_height = 0;

    //  insert vsync before frame data
    bit prefix_vsync = 1;
    //  insert vsync after frame data
    bit suffix_vsync = 0;

    //  {R, G, B} dynamic array
    bit [3*DATA_WIDTH - 1: 0] frame_data [];

    protected bit mem_allocated = 0;

    //  time stamp
    longint unsigned timestamp = 0;


    //----------
    //  Registry
    //----------

    `uvm_object_param_utils_begin(FrameDataTxn #(DATA_WIDTH))
        `uvm_field_int(frame_width, UVM_ALL_ON)
        `uvm_field_int(frame_height, UVM_ALL_ON)
        `uvm_field_array_int(frame_data, UVM_ALL_ON)
        `uvm_field_int(timestamp, UVM_ALL_ON | UVM_NOCOMPARE)
    `uvm_object_utils_end


    //--------
    //  Method
    //--------

    function new(string name="FrameDataTxn");
        super.new(name);
    endfunction

    function void alloc_mem();
        if (frame_width == 0 || frame_height == 0) begin
            `uvm_fatal(get_name(), "video frame_width and frame_height are not set.")
        end
        if (mem_allocated) begin
            `uvm_fatal(get_name(), "frame data memory has been allocated.")
        end
        frame_data = new[frame_height*frame_width];
        mem_allocated = 1;
    endfunction

    function void gen_color_bar();
        int i;
        int j;
        int bar_idx;

        if (~mem_allocated) begin
            `uvm_fatal(get_name(), "frame data array is not allocated.")
        end
        for(i = 0; i < frame_height; i++) begin
            for(j = 0; j < frame_width; j++) begin
                bar_idx = (j*8) / frame_width;
                //  r channel
                frame_data[frame_width*i + j][3*DATA_WIDTH - 1: 2*DATA_WIDTH] =
                    (bar_idx == 1 || bar_idx == 5 || bar_idx == 6 || bar_idx == 7) ?
                    {DATA_WIDTH{1'b1}} : {DATA_WIDTH{1'b0}};
                //  g channel
                frame_data[frame_width*i + j][2*DATA_WIDTH - 1: DATA_WIDTH] =
                    (bar_idx == 2 || bar_idx == 4 || bar_idx == 6 || bar_idx == 7) ?
                    {DATA_WIDTH{1'b1}} : {DATA_WIDTH{1'b0}};
                //  b channel
                frame_data[frame_width*i + j][DATA_WIDTH - 1: 0] =
                    (bar_idx == 3 || bar_idx == 4 || bar_idx == 5 || bar_idx == 7) ?
                    {DATA_WIDTH{1'b1}} : {DATA_WIDTH{1'b0}};
            end
        end
    endfunction

    function void read_bin_frame(string file);
        int fd      = 0;
        int fcode   = 0;
        byte temp;

        if (~mem_allocated) begin
            `uvm_fatal(get_name(), "frame data array is not allocated.")
        end

        fd = $fopen(file, "rb");
        if (fd == 0) begin
            `uvm_fatal(get_name(), "can't open binary file to read frame data.")
        end

        //  for memory order:
        //      read from the little address to big address
        //  for data array order:
        //      "C" like order (row-major)
        //  for channel order:
        //      1st R, 2nd G, 3rd B
        //  for each data:
        //      read byte by byte in big endian manner
        //      8-bit wide memory is loaded using 1 byte per memory word
        //      9-bit wide memory is loaded using 2 bytes per memory word
        fcode = $fread(frame_data, fd);

        if (fcode == 0) begin
            $fclose(fd);
            `uvm_fatal(get_name(), "no data is read.")
        end
        if (fcode < 3*((DATA_WIDTH + 7)/8)*frame_height*frame_width) begin
            $fclose(fd);
            `uvm_fatal(get_name(), "data read is less than predefined frame size.")
        end

        fcode = $fread(temp, fd);
        if (fcode != 0) begin
            $fclose(fd);
            `uvm_fatal(get_name(), "file size is greater than predefined frame size.")
        end

        $fclose(fd);
    endfunction
endclass

