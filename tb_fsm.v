`timescale 1ns/1ns
module tb_fsm;
    reg clk = 0, rst_n = 1, frame_end = 0, press_pulse = 0;
    wire [1:0] screen;
    integer round;
    screen_fsm dut(clk, rst_n, frame_end, press_pulse, screen);
    always #20 clk = ~clk;

    task step(input bit boundary, input bit press);
        @(negedge clk);
        frame_end = boundary;
        press_pulse = press;
        @(posedge clk);
        #1;
        $display("%0t frame_end=%b press=%b pending=%b screen=%0d",
                 $time, frame_end, press_pulse, dut.pending, screen);
    endtask

    task reset;
        #2 rst_n = 0;
        #2;
        $display("%0t RESET pending=%b screen=%0d", $time, dut.pending, screen);
        #2 rst_n = 1;
    endtask

    initial begin
        $dumpfile("tb_fsm.vcd");
        $dumpvars(0, tb_fsm);
        reset(); // BARS, pending cleared.
        for (round = 0; round < 3; round = round + 1) begin
            step(0, 1); // Latch the request and hold the current state.
            step(0, 0);
            step(1, 0); // Advance one state.
            step(0, 0);
            step(1, 0); // An empty boundary holds the new state.
            step(0, 0);
        end
        step(1, 1); // Same-cycle request and boundary advance to MUST.
        step(0, 1); // Queue a request, then clear it with RESET.
        reset();
        step(0, 0);
        step(1, 0); // BARS with no queued request.
        force dut.state = 2'b11;
        #5 release dut.state;
        step(0, 0); // Recover to BARS.
        $finish;
    end
endmodule
