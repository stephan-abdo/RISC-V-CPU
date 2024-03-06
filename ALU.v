module ALU(
    input  [31:0] source_a,
    input  [31:0] source_b,
    input  [4:0] index_rd,
    input reset,
    input  [31:0] immeadiate,
    input  [10:0] operation,
    input [31:0] PC,
    output reg [31:0] result,
    output reg branch,
    output reg [31:0] new_PC
    );

    reg[32:0] ram[256:0];
    integer i = 0;

    always @(reset)begin
        for(i = 0 ; i < 256 ; i = i +1)begin
            ram[i] = 32'b0;
        end
    end

    always@(*)begin
        result = 32'b0;
        branch = 1'b0;
        new_PC = 32'b0;

        //immeadiate
        case(operation[6:0])
            7'b0010011 : begin
                case(operation[9:7])
                    3'b000: result = $signed(source_a) + $signed(immeadiate);
                    3'b010: result = $signed(source_a) < $signed(immeadiate) ? 1 : 0;
                    3'b011: result = $signed(source_a) < immeadiate ? 1 : 0;
                    3'b100: result = source_a ^ immeadiate;
                    3'b110: result = source_a || immeadiate;
                    3'b111: result = source_a && immeadiate;
                endcase
            end
        //Register
            7'b0110011 : begin
                case(operation[9:7])
                    3'b000: result = $signed(source_a) + $signed(source_b);
                    3'b010: result = $signed(source_a) - $signed(source_b);
                    3'b100: result = source_a ^ source_b;
                    3'b110: result = source_a || source_b;
                    3'b111: result = source_a && source_b;
                    3'b001: result = source_a << source_b;
                    3'b101: 
                    if(operation[10] == 0)begin
                        result = source_a >> source_b;
                    end
                    else begin
                        result = source_a >>> source_b;
                    end

                endcase
            end
        //load
            7'b0000011 : begin
                case(operation[9:7])
                    3'b000: result = $signed({{24{1'b0}},ram[immeadiate + source_a]});
                    3'b001: result = $signed({{16{1'b0}},ram[immeadiate + source_a]});
                    3'b010: result = $signed(ram[immeadiate + source_a]);
                    3'b100: result = {{24{1'b0}},ram[immeadiate + source_a]};
                    3'b101: result = {{16{1'b0}},ram[immeadiate + source_a]};
                endcase
            end
        //store
            7'b0100011 : begin
                case(operation[9:7])
                    3'b000: ram[immeadiate + source_a] = ({{24{1'b0}},source_b[15:0]});
                    3'b001: ram[immeadiate + source_a] = ({{16{1'b0}},source_b[15:0]});
                    3'b010: ram[immeadiate + source_a] = source_b;
                endcase
            end
        //branch
            7'b1100011 : begin
                case(operation[9:7])
                    3'b000: begin 
                        branch = source_a == source_b ? 1 : 0;
                        new_PC = PC +immeadiate;
                    end
                    3'b001: begin
                        branch = source_a != source_b ? 1 : 0;
                        new_PC = PC +immeadiate;
                    end
                    3'b100: begin
                        branch = source_a < source_b ? 1 : 0;
                        new_PC = PC +immeadiate;
                    end
                    3'b101: begin 
                        branch = $signed(source_a) < $signed(source_b) ? 1 : 0;
                        new_PC = PC +immeadiate;
                    end
                    3'b110: begin
                        branch = source_a >= source_b ? 1 : 0;
                        new_PC = PC +immeadiate;
                    end
                    3'b111: begin
                        branch = $signed(source_a) >= $signed(source_b) ? 1 : 0;
                        new_PC = PC +immeadiate;
                    end
                endcase
            end
            //U instruction
            7'b0110111 : begin
                    result = {immeadiate[31:12],12'b0};
            end
            //J
            7'b1101111 : begin
                    result = PC + 1;
                    branch = 1;
                    new_PC = immeadiate;
            end
            7'b1100111 : begin
                    result = PC + 1;
                    branch = 1;
                    new_PC = source_a + immeadiate;
            end           
            
        endcase
    end
endmodule



module ALU_tb;

    // Parameters
    parameter CLOCK_PERIOD = 10; // Time period for clock (in ns)

    // Signals
    reg [31:0] source_a, source_b, imediate;
    reg [4:0] index_rd;
    reg [10:0] operation;
    wire [31:0] result;
    wire branch;
    wire [31:0] new_PC;

    // Instantiate the ALU module
    ALU dut (
        .source_a(source_a),
        .source_b(source_b),
        .index_rd(index_rd),
        .immeadiate(imediate),
        .operation(operation),
        .result(result),
        .branch(branch),
        .new_PC(new_PC)
    );

    // Clock generation
    reg clock = 0;
    always #((CLOCK_PERIOD)/2) clock = ~clock;

    // Test stimulus
    initial begin

        $monitor("%h %h %h %b",result , branch , new_PC ,operation);
        // Initialize inputs
        source_a = 32'hAAAAAAAA;
        source_b = 32'h55555555;
        index_rd = 5'b00000;
        imediate = 32'h12345678;
        operation = 11'b00000000000;

        // Test case 1: ALU operation 0010011 (ADDI)
        operation = 11'b00000010011;
        #10;
        imediate = 32'h00000001;
        #10;

        // Test case 2: ALU operation 0110011 (ADD)
        operation = 11'b00000110011;
        #10;
        source_b = 32'h12345678;
        #10;

        // Test case 3: ALU operation 0110011 (SUB)
        operation = 11'b00100110011;
        #10;

        // Test case 4: ALU operation store HW
        source_a = 32'b0;
        operation = 11'b00010100011;
        #10;

        // Test case 4: ALU operation 0000011 (LD)
        operation = 11'b00000000011;
        #10;

        // Test case 5: ALU operation 1100011 (BEQ)
        operation = 11'b11000110000;
        #10;

        // Add more test cases here...

        // Finish simulation
        #100;
        
        $finish;
    end

endmodule
