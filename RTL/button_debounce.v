`timescale 1ns/1ns
module button_debounce #(parameter integer STABLE_CYCLES=500000)(
    input wire clk, rst_n, key_n,
    output reg clean_n, press_pulse
);
    localparam integer CW = STABLE_CYCLES <= 1 ? 1 : $clog2(STABLE_CYCLES);
    localparam [CW-1:0] LAST = CW'(STABLE_CYCLES-1);
    (* ASYNC_REG = "TRUE" *) reg sync1, sync2;
    reg [CW-1:0] count;
    reg armed;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin sync1 <= 0; sync2 <= 0; end
        else begin sync1 <= key_n; sync2 <= sync1; end
    end
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clean_n <= 0; press_pulse <= 0; count <= 0; armed <= 0;
        end else begin
            press_pulse <= 0;
            if (sync2 == clean_n) count <= 0;
            else if (count == LAST) begin
                clean_n <= sync2;
                count <= 0;
                if (sync2) armed <= 1;
                else begin press_pulse <= armed; armed <= 0; end
            end else count <= count + 1'b1;
        end
    end
endmodule
