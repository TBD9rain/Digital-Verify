//==================================================================================================
//
//  Project         :   Digital Verify Example
//  Version         :   v1.0.0
//  Title           :   preadd_multi
//
//  Description     :   multiplier with 2 pre-adder
//
//  Additional info :
//  Author          :   TBD9rain
//  Email           :
//
//==================================================================================================

module preadd_multi #(
    parameter   DATA_WIDTH  = 8,

    localparam  DATA_IN_WIDTH = DATA_WIDTH,
    localparam  DATA_OUT_WIDTH = 2*(DATA_IN_WIDTH + 1))
(
    input   clk,
    input   rst_n,

    input                           data_in_vld,
    input   [DATA_IN_WIDTH - 1: 0]  data_in_a0,
    input   [DATA_IN_WIDTH - 1: 0]  data_in_a1,
    input   [DATA_IN_WIDTH - 1: 0]  data_in_b0,
    input   [DATA_IN_WIDTH - 1: 0]  data_in_b1,

    output  reg                         data_out_vld,
    output  reg [DATA_OUT_WIDTH - 1: 0] data_out);


//=====================
//  VARIABLE DEFINITION
//=====================

//  pre-adder
wire                        data_out_vld_a;
wire    [DATA_IN_WIDTH: 0]  data_out_a;
wire                        data_out_vld_b;
wire    [DATA_IN_WIDTH: 0]  data_out_b;


//===============
//  DESIGN CODING
//===============

//  pre-adder a
adder #(
    .DATA_WIDTH (DATA_IN_WIDTH))
u_adder_a (
    .clk    (clk),
    .rst_n  (rst_n),

    .data_in_vld    (data_in_vld),
    .data_in0       (data_in_a0),
    .data_in1       (data_in_a1),

    .data_out_vld   (data_out_vld_a),
    .data_out       (data_out_a));

//  pre-adder b
adder #(
    .DATA_WIDTH (DATA_IN_WIDTH))
u_adder_b (
    .clk    (clk),
    .rst_n  (rst_n),

    .data_in_vld    (data_in_vld),
    .data_in0       (data_in_b0),
    .data_in1       (data_in_b1),

    .data_out_vld   (data_out_vld_b),
    .data_out       (data_out_b));


//  multiplier
always @(posedge clk or posedge rst_n) begin
    if (rst_n) begin
        data_out_vld    <= 'b0;
        data_out        <= 'b0;
    end
    else begin
        data_out_vld    <= data_out_vld_a && data_out_vld_b;
        data_out        <= data_out_a * data_out_b;
    end
end

endmodule

