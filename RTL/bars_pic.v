`timescale 1ns/1ns
module bars_pic(input wire clk, input wire [9:0] x,y,
                output reg [15:0] data);

    always @(posedge clk) begin
        if (x >= 640 || y >= 480) data <= 16'h0000;
        else case (x[9:6])
            0: data <= 16'hf800;
            1: data <= 16'hfc00;
            2: data <= 16'hffe0;
            3: data <= 16'h07e0;
            4: data <= 16'h07ff;
            5: data <= 16'h001f;
            6: data <= 16'hf81f;
            7: data <= 16'h0000;
            8: data <= 16'hffff;
            9: data <= 16'hd69a;
            default: data <= 16'h0000;
        endcase
    end
endmodule
