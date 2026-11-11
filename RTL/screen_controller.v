`timescale 1ns/1ns
module screen_controller #(parameter integer DEBOUNCE_CYCLES=500000)(
    input wire sys_clk, sys_rst_n, key_in,
    output wire hsync, vsync,
    output wire [15:0] rgb
);
    wire pixel_clk, frame_end, clean_n, press_pulse;
    wire [9:0] pix_x,pix_y;
    wire [1:0] screen;
    wire [15:0] bars_data,must_data,end_data,pix_data;
    pixel_clock u_clock(sys_clk,pixel_clk);
    vga_ctrl u_vga(pixel_clk,pix_data,pix_x,pix_y,hsync,vsync,frame_end,rgb);
    button_debounce #(.STABLE_CYCLES(DEBOUNCE_CYCLES))
        u_button(pixel_clk,sys_rst_n,key_in,clean_n,press_pulse);
    screen_fsm u_fsm(pixel_clk,sys_rst_n,frame_end,press_pulse,screen);
    bars_pic u_bars(pixel_clk,pix_x,pix_y,bars_data);
    vga_pic u_must(pixel_clk,sys_rst_n,pix_x,pix_y,must_data);
    end_pic u_end(pixel_clk,sys_rst_n,pix_x,pix_y,end_data);
    assign pix_data = screen==2'd1 ? must_data :
                      screen==2'd2 ? end_data : bars_data;
endmodule
