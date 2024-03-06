`include "program_counter.v"
`include "rom.v"
`include "Decoder.v"
`include "RF.v"
`include "ALU.v"

module RV32I(
    input reset,
    input enable,
    input enable_a;
    input enable_b;
    input enable_write;
    input rom_read_enable,
    input rom_chip_enable,
    input decoder_enable,
    input clock,
    input [31:0] branch,
    );
    wire sel_wire;
    wire [31:0] pc;
    wire [31:0] branch_wire;
    wire [31:0] instruction;
    wire [4:0] index_rega;
    wire [4:0] index_regb;
    wire [4:0] index_regd;
    wire [10:0] operation_wire;
    wire [31:0] imediate_wire;
    wire [31:0] output_a_wire;
    wire [31:0] output_b_wire;
    wire [31:0] result_wire;


    program_counter program_counter(
        .reset(reset),
        .enable(enable),
        .clock(clock),
        .data(branch_wire),
        .sel(sel_wire),
        .pc(pc),
    );

    rom rom(
        .address(pc),
        .data(instruction),
        .read_en(rom_read_enable),
        .ce(rom_chip_enable) 
    );

    decoder decoder(
        .instruction(instruction),
        .clock(clock),
        .enable(decoder_enable),
        .index_ra(index_rega), 
        .index_rb(index_regb), 
        .operation(operation_wire),
        .index_rd(index_regd),
        .immeadiate(imediate_wire)
    );

    RF RF(
        .reset(reset),
        .clock(clock),
        .enable_a(enable_a),
        .enable_b(enable_b),
        .enable_write(enable_write),
        .index_a(index_rega),
        .index_b(index_regb),
        .index_write(index_regd),
        .output_a(output_a_wire),
        .output_b(output_b_wire),
        .write_data(result_wire)
    );

    ALU ALU(
        .source_a(output_a_wire),
        .source_b(output_b_wire),
        .index_rd(index_regd),
        .imediate(imediate_wire),
        .operation(operation_wire),
        .result(result_wire),
        .new_PC(branch_wire),
        .branch(sel_wire),
        .PC(pc)
    );

endmodule


