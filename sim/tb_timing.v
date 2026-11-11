`timescale 1ns/1ns
module tb_timing;
    reg sys_clk = 0;
    wire pixel_clk, hsync, vsync, frame_end;
    wire [9:0] x, y;
    wire [15:0] rgb;
    integer fd, frames = 0;
    pixel_clock clock_divider(sys_clk, pixel_clk);
    vga_ctrl dut(pixel_clk, 16'hffff, x, y, hsync, vsync, frame_end, rgb);
    always #10 sys_clk = ~sys_clk;

    always @(negedge pixel_clk) begin
        if (frames == 0 && dut.cnt_v == 35)
            $fdisplay(fd, "%0t,%0d,%0d,%b,%b,%b,%b,%0d,%0d,%04h",
                      $time, dut.cnt_h, dut.cnt_v, hsync, vsync,
                      dut.rgb_valid, dut.pix_data_req, x, y, rgb);
    end

    always @(posedge frame_end) begin
        frames = frames + 1;
        $display("%0t frame_end #%0d h=%0d v=%0d", $time, frames, dut.cnt_h, dut.cnt_v);
    end

    initial begin
        $dumpfile("tb_timing.vcd");
        $dumpvars(0, hsync, vsync, frame_end, dut.rgb_valid, dut.pix_data_req, rgb);
        fd = $fopen("timing_line.csv", "w");
        $fdisplay(fd, "time_ns,h,v,hsync,vsync,active,request,x,y,rgb565");
        #33601000;
        $fclose(fd);
        $finish;
    end
endmodule
