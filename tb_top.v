`timescale 1ns/1ns
module tb_top;
    reg sys_clk = 0, rst_n = 1, key_in = 1;
    wire hsync, vsync;
    wire [15:0] rgb;
    integer pulses = 0, advances = 0;
    screen_controller dut(sys_clk, rst_n, key_in, hsync, vsync, rgb);
    always #10 sys_clk = ~sys_clk;

    always @(posedge dut.press_pulse)
        if (rst_n) pulses = pulses + 1;
    always @(dut.screen)
        if (rst_n && $time > 10) begin
            advances = advances + 1;
            $display("%0t advance screen=%0d raster=(%0d,%0d)",
                     $time, dut.screen, dut.u_vga.cnt_h, dut.u_vga.cnt_v);
        end

    task note(input string label);
        $display("%0t %s: screen=%0d pulses=%0d advances=%0d pending=%b armed=%b",
                 $time, label, dut.screen, pulses, advances, dut.u_fsm.pending, dut.u_button.armed);
    endtask

    task click;
        key_in = 0;
        #40000000;
        note("click");
    endtask

    task release_key;
        key_in = 1;
        #25000000;
    endtask

    task reset_held;
        rst_n = 0;
        #1 note("reset_asserted"); // BARS and cleared pending.
        #999999 rst_n = 1;
        #45000000 note("held_after_reset"); // No new press until release.
    endtask

    initial begin
        $dumpfile("tb_top.vcd");
        $dumpvars(0, rst_n, key_in, dut.screen, dut.clean_n, dut.press_pulse,
                  dut.u_button.armed, dut.u_fsm.pending, dut.frame_end, pulses, advances);
        #3 rst_n = 0;
        #200 rst_n = 1;
        #25000000 note("startup"); // BARS
        click(); release_key(); // MUST
        click(); release_key(); // END
        click();               // BARS
        reset_held(); release_key();

        key_in = 0; #2000000;
        key_in = 1; #1000000;
        key_in = 0; #3000000;
        key_in = 1; #2000000;
        note("after_bounce_before_stable_press"); // BARS, no new event.
        click();                                // MUST once.
        #60000000 note("long_hold");            // Same counts as after acceptance.
        reset_held(); release_key();            // Reset from MUST.
        click(); release_key(); click();        // END.
        reset_held(); release_key();            // Reset from END.
        click(); release_key();                 // MUST.
        key_in = 0;
        #5000000 reset_held();                   // Reset mid-qualification.
        release_key(); click();                  // A new press may advance again.
        note("after_rearm");
        $finish;
    end
endmodule
