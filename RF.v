module RF(
    input reset,
    input clock,
    input enable_a,
    input enable_b,
    input enable_write,
    input [4:0] index_a,
    input [4:0] index_b,
    input [4:0] index_write,
    output [31:0] output_a,
    output [31:0] output_b,
    input [31:0] write_data
    );

    reg [31:0] registers[31:0];
    integer i;

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            for (i = 0; i < 32; i = i + 1) begin
                registers[i] <= 32'h00000000;
            end
        end else begin
            if (enable_write) begin
                registers[index_write] <= write_data;
            end
        end
    end

    // Continuous assignments for outputs
    assign output_a = (enable_a) ? registers[index_a] : 32'b0;
    assign output_b = (enable_b) ? registers[index_b] : 32'b0;

endmodule

module RF_tb;

    // Inputs
    reg reset;
    reg clock;
    reg enable_a;
    reg enable_b;
    reg enable_write;
    reg [4:0] index_a;
    reg [4:0] index_b;
    reg [4:0] index_write;
    reg [31:0] write_data;

    // Outputs
    wire [31:0] output_a;
    wire [31:0] output_b;

    // Instantiate the RF module
    RF uut (
        .reset(reset),
        .clock(clock),
        .enable_a(enable_a),
        .enable_b(enable_b),
        .enable_write(enable_write),
        .index_a(index_a),
        .index_b(index_b),
        .index_write(index_write),
        .write_data(write_data),
        .output_a(output_a),
        .output_b(output_b)
    );

    // Clock generation
    always #5 clock = ~clock;

    // Initial stimulus
    initial begin

        $display("time\t clk reset output_a output_b write_data");
        $monitor("%t\t %b %b %d %d %d",$time ,clock ,reset ,output_a ,output_b ,write_data);


        // Initialize inputs
        reset = 1;
        clock = 0;
        enable_a = 1;
        enable_b = 1;
        enable_write = 1;
        index_a = 0;
        index_b = 0;
        index_write = 0;
        write_data = 0;

        // Apply reset
        #6 reset = 0;

        // Test scenario 1: Write to register 5
        #10 index_write = 5;
        #10 write_data = 32'h12345678;
        #10
        index_write = 12;
        write_data = 103;

        // Test scenario 2: Read from registers 2 and 5
        #10 index_a = 2;
        #10 index_b = 5;
        #30 index_b = 12;

        // Add more test scenarios as needed

        // End simulation
        #100 $finish;
    end

endmodule
