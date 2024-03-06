module decoder(
    input  [31:0]instruction ,
    input clock,
    input  enable,
    output reg [4:0]index_ra, 
    output reg [4:0]index_rb, 
    output reg [10:0]operation,
    output reg [4:0]index_rd,
    output reg [31:0]immeadiate
    );

    reg [2:0] funct3;
    reg [6:0] funct7;

    always @(*)begin

        // indetifying the index for ra if apropriate
        if(
            (instruction[6:0] == 7'b0110011) || 
            (instruction[6:0] == 7'b0010011) ||
            (instruction[6:0] == 7'b0000011) ||
            (instruction[6:0] == 7'b1100011) ||
            (instruction[6:0] == 7'b0100011) 
        )begin
            index_ra = instruction[19:15];
        end
        else begin
            index_ra = 5'b0;
        end

            // indetifying the index for rb if apropriate
        if(
            (instruction[6:0] == 7'b0110011) || 
            (instruction[6:0] == 7'b1100011) ||
            (instruction[6:0] == 7'b0100011) 
        )begin
            index_rb = instruction[24:20];
        end
        else begin
            index_rb = 5'b0;
        end

            // indetifying the index for rd if apropriate
        if(
            (instruction[6:0] == 7'b0110011) || 
            (instruction[6:0] == 7'b0010011) ||
            (instruction[6:0] == 7'b0000011) ||
            (instruction[6:0] == 7'b0110111) ||
            (instruction[6:0] == 7'b1101111) ||
            (instruction[6:0] == 7'b0010111)
        )begin
            index_rd = instruction[11:7];
        end
        else begin
            index_rd = 5'b0;
        end

            // indetifying the funct3 if apropriate
        if(
            (instruction[6:0] == 7'b0110011) || 
            (instruction[6:0] == 7'b0010011) ||
            (instruction[6:0] == 7'b0000011) ||
            (instruction[6:0] == 7'b1100011) ||
            (instruction[6:0] == 7'b0100011) 
        )begin
            funct3 = instruction[14:12];
        end
        else begin
            funct3 = 3'b0;
        end

            // indetifying the funct7 if apropriate
        if(
            instruction[6:0] == 7'b0110011 
        )begin
            funct7 = instruction[31:25];
        end
        else begin
            funct7 = 3'b0;
        end
            
            // indetifying the immeadiate if apropriate

            // imediate for I instruction

        if(
            (instruction[6:0] == 7'b0000011) || 
            (instruction[6:0] == 7'b0010011) 
        )begin
            immeadiate = {{21{instruction[31]}},instruction[30:20]};
        end

            // imediate for S instruction

        else if(
            instruction[6:0] == 7'b0100011
        )begin
            immeadiate = {{21{instruction[31]}}, instruction[30:25],instruction[11:7]};
        end

            // imediate for B instruction

        else if(
            instruction[6:0] == 7'b0100011
        )begin
            immeadiate = {{20{instruction[31]}}, instruction[7] , instruction[30:25],instruction[11:8], 1'b0};
        end

            // imediate for U instruction

        else if(
            (instruction[6:0] == 7'b0100011) || 
            (instruction[6:0] == 7'b0010111)
        )begin
            immeadiate = {instruction[31],instruction[30:20] , instruction[19:12] , 12'b0};
        end

            // imediate for J instruction

        else if(
            instruction[6:0] == 7'b0100011
        )begin
            immeadiate = {{12{instruction[31]}} , instruction[19:12] , instruction[20] , instruction[30:21] , 1'b0};
        end
        else begin
            immeadiate = 32'b0;
        end

        // concatenating operation from funct3 funct 7 and opcode

        operation = {funct7[1] , funct3 , instruction[6:0]};

    end

endmodule

/*

module decoder_tb;

    // Signals
    reg [31:0] instruction;
    reg enable;
    wire [4:0] index_ra;
    wire [4:0] index_rb;
    wire [10:0] operation;
    wire [4:0] index_rd;
    wire [31:0] immeadiate;

    // Instantiate the decoder module
    decoder dut (
        .instruction(instruction),
        .clock(1'b0), // Placeholder for clock, not used
        .enable(enable),
        .index_ra(index_ra),
        .index_rb(index_rb),
        .operation(operation),
        .index_rd(index_rd),
        .immeadiate(immeadiate)
    );

    // Test stimulus
    initial begin
        enable = 1;
        instruction = 32'b0;

        // Finish simulation after a few time units
        #1000;
        $finish;
    end

    // Monitor
    initial begin
        $monitor(" time = %t index_ra=%h, index_rb=%h, operation=%h, index_rd=%h, immeadiate=%h instruction = %h",$time , index_ra, index_rb, operation, index_rd, immeadiate,instruction);
    end

endmodule

*/