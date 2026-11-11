`timescale 1ns/1ns
module end_pic(input wire clk,rst_n, input wire [9:0] x,y,
               output reg [15:0] data);
    wire [9:0] local_y=y-10'd208;
    wire [2:0] row=local_y[5:3];
    wire [9:0] x_e=x-10'd192;
    localparam [7:0] E_ROW_0=8'b11111111;
    localparam [7:0] E_ROW_1=8'b11000000;
    localparam [7:0] E_ROW_2=8'b11000000;
    localparam [7:0] E_ROW_3=8'b11111100;
    localparam [7:0] E_ROW_4=8'b11000000;
    localparam [7:0] E_ROW_5=8'b11000000;
    localparam [7:0] E_ROW_6=8'b11000000;
    localparam [7:0] E_ROW_7=8'b11111111;
    wire [9:0] x_n=x-10'd288;
    localparam [7:0] N_ROW_0=8'b11000011;
    localparam [7:0] N_ROW_1=8'b11100011;
    localparam [7:0] N_ROW_2=8'b11110011;
    localparam [7:0] N_ROW_3=8'b11011011;
    localparam [7:0] N_ROW_4=8'b11001111;
    localparam [7:0] N_ROW_5=8'b11000111;
    localparam [7:0] N_ROW_6=8'b11000011;
    localparam [7:0] N_ROW_7=8'b11000011;
    wire [9:0] x_d=x-10'd384;
    localparam [7:0] D_ROW_0=8'b11111100;
    localparam [7:0] D_ROW_1=8'b11000110;
    localparam [7:0] D_ROW_2=8'b11000011;
    localparam [7:0] D_ROW_3=8'b11000011;
    localparam [7:0] D_ROW_4=8'b11000011;
    localparam [7:0] D_ROW_5=8'b11000011;
    localparam [7:0] D_ROW_6=8'b11000110;
    localparam [7:0] D_ROW_7=8'b11111100;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) data <= 16'h0000;
        else if (y>=208 && y<272) begin
            if (x>=192 && x<256) begin
                case (row)
                    3'd0: data <= E_ROW_0[3'd7-x_e[5:3]] ? 16'hffff : 16'h0000;
                    3'd1: data <= E_ROW_1[3'd7-x_e[5:3]] ? 16'hffff : 16'h0000;
                    3'd2: data <= E_ROW_2[3'd7-x_e[5:3]] ? 16'hffff : 16'h0000;
                    3'd3: data <= E_ROW_3[3'd7-x_e[5:3]] ? 16'hffff : 16'h0000;
                    3'd4: data <= E_ROW_4[3'd7-x_e[5:3]] ? 16'hffff : 16'h0000;
                    3'd5: data <= E_ROW_5[3'd7-x_e[5:3]] ? 16'hffff : 16'h0000;
                    3'd6: data <= E_ROW_6[3'd7-x_e[5:3]] ? 16'hffff : 16'h0000;
                    3'd7: data <= E_ROW_7[3'd7-x_e[5:3]] ? 16'hffff : 16'h0000;
                    default: data <= 16'h0000;
                endcase
            end
            else if (x>=288 && x<352) begin
                case (row)
                    3'd0: data <= N_ROW_0[3'd7-x_n[5:3]] ? 16'hffff : 16'h0000;
                    3'd1: data <= N_ROW_1[3'd7-x_n[5:3]] ? 16'hffff : 16'h0000;
                    3'd2: data <= N_ROW_2[3'd7-x_n[5:3]] ? 16'hffff : 16'h0000;
                    3'd3: data <= N_ROW_3[3'd7-x_n[5:3]] ? 16'hffff : 16'h0000;
                    3'd4: data <= N_ROW_4[3'd7-x_n[5:3]] ? 16'hffff : 16'h0000;
                    3'd5: data <= N_ROW_5[3'd7-x_n[5:3]] ? 16'hffff : 16'h0000;
                    3'd6: data <= N_ROW_6[3'd7-x_n[5:3]] ? 16'hffff : 16'h0000;
                    3'd7: data <= N_ROW_7[3'd7-x_n[5:3]] ? 16'hffff : 16'h0000;
                    default: data <= 16'h0000;
                endcase
            end
            else if (x>=384 && x<448) begin
                case (row)
                    3'd0: data <= D_ROW_0[3'd7-x_d[5:3]] ? 16'hffff : 16'h0000;
                    3'd1: data <= D_ROW_1[3'd7-x_d[5:3]] ? 16'hffff : 16'h0000;
                    3'd2: data <= D_ROW_2[3'd7-x_d[5:3]] ? 16'hffff : 16'h0000;
                    3'd3: data <= D_ROW_3[3'd7-x_d[5:3]] ? 16'hffff : 16'h0000;
                    3'd4: data <= D_ROW_4[3'd7-x_d[5:3]] ? 16'hffff : 16'h0000;
                    3'd5: data <= D_ROW_5[3'd7-x_d[5:3]] ? 16'hffff : 16'h0000;
                    3'd6: data <= D_ROW_6[3'd7-x_d[5:3]] ? 16'hffff : 16'h0000;
                    3'd7: data <= D_ROW_7[3'd7-x_d[5:3]] ? 16'hffff : 16'h0000;
                    default: data <= 16'h0000;
                endcase
            end
            else data <= 16'h0000;
        end else data <= 16'h0000;
    end
endmodule
