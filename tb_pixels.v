`timescale 1ns/1ns
module tb_pixels;
    reg clk = 0, rst_n = 1;
    reg [9:0] x = 1023, y = 1023;
    wire [15:0] bars, must_text, end_text;
    integer sample_id = 0, col;
    bars_pic u_bars(clk, x, y, bars);
    vga_pic u_must(clk, rst_n, x, y, must_text);
    end_pic u_end(clk, rst_n, x, y, end_text);
    always #20 clk = ~clk;

    task probe(input [9:0] xx, yy);
        @(negedge clk);
        x = xx;
        y = yy;
        @(posedge clk);
        #1 sample_id = sample_id + 1;
        $display("%0t sample=%0d x=%0d y=%0d BARS=%04h MUST=%04h END=%04h",
                 $time, sample_id, x, y, bars, must_text, end_text);
    endtask

    initial begin
        $dumpfile("tb_pixels.vcd");
        $dumpvars(0, clk, rst_n, x, y, bars, must_text, end_text, sample_id);
        #1 rst_n = 0;
        #60 rst_n = 1;
        // Ten bar interiors, a bar boundary, glyph strokes, gaps and blanking.
        for (col = 0; col < 10; col = col + 1)
            probe(32 + 64*col, 120);
        probe(63, 120); probe(64, 120);
        probe(144, 208); probe(152, 208); probe(143, 208); probe(208, 208);
        probe(240, 208); probe(336, 208); probe(432, 208);
        probe(192, 208); probe(192, 216); probe(208, 216);
        probe(288, 232); probe(304, 232);
        probe(424, 208); probe(432, 208);
        probe(320, 272); probe(640, 120); probe(1023, 1023);
        #40;
        $finish;
    end
endmodule
