//==================================================================================================
//
//  Project         :   Digital Verify Example
//  Version         :   v1.0.0
//  Title           :   adder_8bit
//
//  Description     :   2 8-bit input adder
//
//  Additional info :
//  Author          :   TBD9rain
//  Email           :
//
//==================================================================================================

module adder_8bit(
    input   clk,
    input   rst_n,

    input               data_in_vld,
    input   [ 7: 0]     data_in0,
    input   [ 7: 0]     data_in1,

    output  reg                 data_out_vld,
    output  reg     [ 8: 0]     data_out);


//===============
//  DESIGN CODING
//===============

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        data_out_vld    <= 'b0;
        data_out        <= 'b0;
    end
    else begin
        data_out_vld    <= data_in_vld;
        data_out        <= data_in0 + data_in1;
    end
end


endmodule

