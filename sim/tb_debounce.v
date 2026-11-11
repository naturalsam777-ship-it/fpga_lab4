`timescale 1ns/1ps

module tb_debounce;

    reg clk = 0;
    reg rst_n = 1;
    reg key_n = 1;

    wire clean_n;
    wire press_pulse;

    integer pulse_count = 0;
    integer counter_file;

    always @(dut.count) begin
        if (counter_file && (dut.count % 25000 == 0 || dut.count >= 499995))
            $fdisplay(counter_file, "%0t,%0d", $time, dut.count);
    end

    button_debounce #(
        .STABLE_CYCLES(500000)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .key_n(key_n),
        .clean_n(clean_n),
        .press_pulse(press_pulse)
    );

    always #20 clk = ~clk;

    always @(posedge press_pulse) begin
        pulse_count = pulse_count + 1;
        $display("[%0t] Accepted press #%0d",
                 $time, pulse_count);
    end

    task wait_ms;
        input integer ms;
        begin
            #(ms * 1000000);
        end
    endtask

    initial begin

        $dumpfile("tb_debounce.vcd");
        $dumpvars(0, rst_n, key_n, clean_n, press_pulse, pulse_count, dut.armed);
        counter_file = $fopen("debounce_counter.csv", "w");
        $fdisplay(counter_file, "time_ns,count");
        $timeformat(-9, 0, "", 0);

        rst_n = 0;
        #100;
        rst_n = 1;

        $display("\n===== DEBOUNCE TEST START =====");


        wait_ms(25);

        $display("[%0t] Initial release: clean_n=%b armed=%b",
                 $time, clean_n, dut.armed);

        key_n = 0;
        wait_ms(2);
        key_n = 1;
        wait_ms(3);

        $display("[%0t] Short glitch: clean_n=%b pulses=%0d",
                 $time, clean_n, pulse_count);

        key_n = 0;
        wait_ms(2);
        key_n = 1;
        wait_ms(1);
        key_n = 0;
        wait_ms(3);
        key_n = 1;
        wait_ms(2);

        $display("[%0t] Press bounce finished: pulses=%0d",
                 $time, pulse_count);

        key_n = 0;
        wait_ms(19);

        $display("[%0t] Near debounce threshold: count=%0d",
                 $time, dut.count);

        wait_ms(2);

        $display("[%0t] Stable press accepted: clean_n=%b pulses=%0d",
                 $time, clean_n, pulse_count);

        wait_ms(80);

        $display("[%0t] Long hold finished: pulses=%0d armed=%b",
                 $time, pulse_count, dut.armed);

       
        key_n = 1;
        wait_ms(2);
        key_n = 0;
        wait_ms(1);
        key_n = 1;
        wait_ms(3);
        key_n = 0;
        wait_ms(2);
        key_n = 1;
        wait_ms(25);

        $display("[%0t] Stable release: clean_n=%b armed=%b",
                 $time, clean_n, dut.armed);

        key_n = 0;
        wait_ms(25);

        $display("[%0t] Second press: pulses=%0d",
                 $time, pulse_count);

        rst_n = 0;
        #100;
        rst_n = 1;

        wait_ms(25);

        $display("[%0t] Reset while held: clean_n=%b armed=%b pulses=%0d",
                 $time, clean_n, dut.armed, pulse_count);

      
        key_n = 1;
        wait_ms(25);

       
        key_n = 0;
        wait_ms(25);

        $display("[%0t] Third press: pulses=%0d",
                 $time, pulse_count);

        key_n = 1;
        wait_ms(25);

        $display("DEBOUNCE TEST FINISHED");
        $display("Total accepted pulses: %0d", pulse_count);

        $fclose(counter_file);
        $finish;
    end

endmodule
