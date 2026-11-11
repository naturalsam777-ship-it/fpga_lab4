`timescale 1ns/1ns
module pixel_clock(input wire sys_clk, output reg vga_clk = 1'b0);
    // Configuration initializes the divider. Display reset leaves it running.
    always @(posedge sys_clk)
        vga_clk <= ~vga_clk;
endmodule
