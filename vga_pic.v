`timescale 1ns/1ns
module vga_pic(
    input wire vga_clk, sys_rst_n,
    input wire [9:0] pix_x, pix_y,
    output reg [15:0] pix_data
);
    localparam [15:0] WHITE=16'hffff, BLACK=16'h0000;
    localparam [7:0] M_ROW_0=8'b11000011;
    localparam [7:0] M_ROW_1=8'b11100111;
    localparam [7:0] M_ROW_2=8'b11111111;
    localparam [7:0] M_ROW_3=8'b11011011;
    localparam [7:0] M_ROW_4=8'b11000011;
    localparam [7:0] M_ROW_5=8'b11000011;
    localparam [7:0] M_ROW_6=8'b11000011;
    localparam [7:0] M_ROW_7=8'b11000011;
    localparam [7:0] U_ROW_0=8'b11000011;
    localparam [7:0] U_ROW_1=8'b11000011;
    localparam [7:0] U_ROW_2=8'b11000011;
    localparam [7:0] U_ROW_3=8'b11000011;
    localparam [7:0] U_ROW_4=8'b11000011;
    localparam [7:0] U_ROW_5=8'b11000011;
    localparam [7:0] U_ROW_6=8'b01111110;
    localparam [7:0] U_ROW_7=8'b00111100;
    localparam [7:0] S_ROW_0=8'b01111110;
    localparam [7:0] S_ROW_1=8'b11000011;
    localparam [7:0] S_ROW_2=8'b11000000;
    localparam [7:0] S_ROW_3=8'b01111110;
    localparam [7:0] S_ROW_4=8'b00000011;
    localparam [7:0] S_ROW_5=8'b00000011;
    localparam [7:0] S_ROW_6=8'b11000011;
    localparam [7:0] S_ROW_7=8'b01111110;
    localparam [7:0] T_ROW_0=8'b11111111;
    localparam [7:0] T_ROW_1=8'b11111111;
    localparam [7:0] T_ROW_2=8'b00011000;
    localparam [7:0] T_ROW_3=8'b00011000;
    localparam [7:0] T_ROW_4=8'b00011000;
    localparam [7:0] T_ROW_5=8'b00011000;
    localparam [7:0] T_ROW_6=8'b00011000;
    localparam [7:0] T_ROW_7=8'b00011000;
    wire [9:0] local_y = pix_y - 10'd208;
    wire [2:0] char_y = local_y[5:3];
    wire [9:0] x_m = pix_x - 10'd144;
    wire [9:0] x_u = pix_x - 10'd240;
    wire [9:0] x_s = pix_x - 10'd336;
    wire [9:0] x_t = pix_x - 10'd432;
    // Each stored bit occupies an 8x8 block. Bit 7 is the leftmost column.
    always @(posedge vga_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) pix_data <= BLACK;
        else if (pix_y >= 10'd208 && pix_y < 10'd272) begin
            if (pix_x >= 10'd144 && pix_x < 10'd208) begin
                case (char_y)
                    3'd0: pix_data <= M_ROW_0[3'd7-x_m[5:3]] ? WHITE : BLACK;
                    3'd1: pix_data <= M_ROW_1[3'd7-x_m[5:3]] ? WHITE : BLACK;
                    3'd2: pix_data <= M_ROW_2[3'd7-x_m[5:3]] ? WHITE : BLACK;
                    3'd3: pix_data <= M_ROW_3[3'd7-x_m[5:3]] ? WHITE : BLACK;
                    3'd4: pix_data <= M_ROW_4[3'd7-x_m[5:3]] ? WHITE : BLACK;
                    3'd5: pix_data <= M_ROW_5[3'd7-x_m[5:3]] ? WHITE : BLACK;
                    3'd6: pix_data <= M_ROW_6[3'd7-x_m[5:3]] ? WHITE : BLACK;
                    3'd7: pix_data <= M_ROW_7[3'd7-x_m[5:3]] ? WHITE : BLACK;
                    default: pix_data <= BLACK;
                endcase
            end
            else if (pix_x >= 10'd240 && pix_x < 10'd304) begin
                case (char_y)
                    3'd0: pix_data <= U_ROW_0[3'd7-x_u[5:3]] ? WHITE : BLACK;
                    3'd1: pix_data <= U_ROW_1[3'd7-x_u[5:3]] ? WHITE : BLACK;
                    3'd2: pix_data <= U_ROW_2[3'd7-x_u[5:3]] ? WHITE : BLACK;
                    3'd3: pix_data <= U_ROW_3[3'd7-x_u[5:3]] ? WHITE : BLACK;
                    3'd4: pix_data <= U_ROW_4[3'd7-x_u[5:3]] ? WHITE : BLACK;
                    3'd5: pix_data <= U_ROW_5[3'd7-x_u[5:3]] ? WHITE : BLACK;
                    3'd6: pix_data <= U_ROW_6[3'd7-x_u[5:3]] ? WHITE : BLACK;
                    3'd7: pix_data <= U_ROW_7[3'd7-x_u[5:3]] ? WHITE : BLACK;
                    default: pix_data <= BLACK;
                endcase
            end
            else if (pix_x >= 10'd336 && pix_x < 10'd400) begin
                case (char_y)
                    3'd0: pix_data <= S_ROW_0[3'd7-x_s[5:3]] ? WHITE : BLACK;
                    3'd1: pix_data <= S_ROW_1[3'd7-x_s[5:3]] ? WHITE : BLACK;
                    3'd2: pix_data <= S_ROW_2[3'd7-x_s[5:3]] ? WHITE : BLACK;
                    3'd3: pix_data <= S_ROW_3[3'd7-x_s[5:3]] ? WHITE : BLACK;
                    3'd4: pix_data <= S_ROW_4[3'd7-x_s[5:3]] ? WHITE : BLACK;
                    3'd5: pix_data <= S_ROW_5[3'd7-x_s[5:3]] ? WHITE : BLACK;
                    3'd6: pix_data <= S_ROW_6[3'd7-x_s[5:3]] ? WHITE : BLACK;
                    3'd7: pix_data <= S_ROW_7[3'd7-x_s[5:3]] ? WHITE : BLACK;
                    default: pix_data <= BLACK;
                endcase
            end
            else if (pix_x >= 10'd432 && pix_x < 10'd496) begin
                case (char_y)
                    3'd0: pix_data <= T_ROW_0[3'd7-x_t[5:3]] ? WHITE : BLACK;
                    3'd1: pix_data <= T_ROW_1[3'd7-x_t[5:3]] ? WHITE : BLACK;
                    3'd2: pix_data <= T_ROW_2[3'd7-x_t[5:3]] ? WHITE : BLACK;
                    3'd3: pix_data <= T_ROW_3[3'd7-x_t[5:3]] ? WHITE : BLACK;
                    3'd4: pix_data <= T_ROW_4[3'd7-x_t[5:3]] ? WHITE : BLACK;
                    3'd5: pix_data <= T_ROW_5[3'd7-x_t[5:3]] ? WHITE : BLACK;
                    3'd6: pix_data <= T_ROW_6[3'd7-x_t[5:3]] ? WHITE : BLACK;
                    3'd7: pix_data <= T_ROW_7[3'd7-x_t[5:3]] ? WHITE : BLACK;
                    default: pix_data <= BLACK;
                endcase
            end
            else pix_data <= BLACK;
        end else pix_data <= BLACK;
    end
endmodule
