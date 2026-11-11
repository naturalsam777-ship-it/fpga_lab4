`timescale 1ns/1ns
module vga_ctrl(
    input wire vga_clk,
    input wire [15:0] pix_data,
    output wire [9:0] pix_x, pix_y,
    output wire hsync, vsync, frame_end,
    output wire [15:0] rgb
);
    // Lecture timing: sync, back porch, border, active, border, front porch.
    localparam [9:0] H_SYNC=10'd96, H_START=10'd144, H_END=10'd784;
    localparam [9:0] V_SYNC=10'd2, V_START=10'd35, V_END=10'd515;
    reg [9:0] cnt_h = 10'd0;
    reg [9:0] cnt_v = 10'd0;
    wire rgb_valid, pix_data_req;
    // Scanning continues during reset so reset can show the bars.
    always @(posedge vga_clk) begin
        if (cnt_h == 10'd799) begin
            cnt_h <= 10'd0;
            if (cnt_v == 10'd524) cnt_v <= 10'd0;
            else cnt_v <= cnt_v + 10'd1;
        end else cnt_h <= cnt_h + 10'd1;
    end
    // The course board window expects positive sync pulses.
    assign frame_end = cnt_h == 10'd799 && cnt_v == 10'd524;
    assign hsync = cnt_h < H_SYNC;
    assign vsync = cnt_v < V_SYNC;
    assign rgb_valid = cnt_h >= H_START && cnt_h < H_END &&
                       cnt_v >= V_START && cnt_v < V_END;
    assign pix_data_req = cnt_h >= H_START-10'd1 && cnt_h < H_END-10'd1 &&
                          cnt_v >= V_START && cnt_v < V_END;
    assign pix_x = pix_data_req ? cnt_h-(H_START-10'd1) : 10'h3ff;
    assign pix_y = pix_data_req ? cnt_v-V_START : 10'h3ff;
    assign rgb = rgb_valid ? pix_data : 16'h0000;
endmodule
