module program_counter (
    input reset,
    input enable,
    input clock,
    input [31:0] data,
    input sel,
    output reg [31:0] pc,
);
    reg [31:0] next_pc

    always @* begin
        if (!reset) begin
            if (!sel) begin
                next_pc = pc + 1; 
            end
            else begin
                next_pc = data; 
            end
            
        end
    end


    always @(posedge clock) begin

        if (reset) begin
            pc = 32'b0;
            next_pc = 32'b0;
        end
        if(!reset && enable)begin
            pc = next_pc; 
        end

    end

endmodule

/*
module pc_tb;

    // Inputs
    reg reset;
    reg enable;
    reg clock;
    reg [31:0] data;
    reg sel;
    wire [31:0] next_pc;

    // Outputs
    wire [31:0] pc;

    // Instantiate the module under test
    program_counter uut (
        .reset(reset),
        .enable(enable),
        .clock(clock),
        .data(data),
        .sel(sel),
        .pc(pc),
        .next_pc(next_pc)
    );

    // Clock generation
    always #5 clock = ~clock;

    // Initial stimulus
    initial begin
        $display("time\t clk reset enable pc  next_pc sel data");
        $monitor("%t\t %b  %b  %b  %d  %d %b  %h", $time, clock, reset, enable, pc, next_pc , sel, data);

        reset = 1;
        sel = 0;
        enable = 1;
        clock = 0;
        data = 32'h00000011;
        #20 
        reset = 0;

        #60 
        sel = 1;
        #30
        sel = 0;


        #100 $finish; // End simulation after some time
    end
endmodule
*/