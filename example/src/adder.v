//==================================================================================================
//
//  Project         :   Digital Verify Example
//  Version         :   v1.1.0
//  Title           :   adder
//
//  Description     :   2 8-bit input adder
//
//  Additional info :
//  Author          :   TBD9rain
//  Email           :
//
//==================================================================================================

module adder #(
    parameter   DATA_WIDTH  = 8)
(
    input   clk,
    input   rst_n,

    input                       data_in_vld,
    input   [DATA_WIDTH - 1: 0] data_in0,
    input   [DATA_WIDTH - 1: 0] data_in1,

    output  reg                     data_out_vld,
    output  reg     [DATA_WIDTH: 0] data_out);


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

