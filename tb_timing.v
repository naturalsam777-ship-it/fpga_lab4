`timescale 1ns/1ns
module tb_timing;
 reg sys_clk=0;wire clk,hs,vs,frame_end;wire[9:0]x,y;wire[15:0]rgb;
 integer h,v,n=0;
 pixel_clock pc(sys_clk,clk);
 vga_ctrl dut(clk,16'hffff,x,y,hs,vs,frame_end,rgb);
 always #10 sys_clk=~sys_clk;
 initial begin
  @(negedge clk);while(dut.cnt_h!=0||dut.cnt_v!=0)@(negedge clk);
  for(v=0;v<525;v=v+1)for(h=0;h<800;h=h+1)begin
   if(hs!==(h<96)||vs!==(v<2)||frame_end!==((h==799)&&(v==524)))$fatal(1,"Sync/frame timing");
   if(rgb!==((h>=144&&h<784&&v>=35&&v<515)?16'hffff:16'h0000))$fatal(1,"Valid window");
   if(h>=143&&h<783&&v>=35&&v<515)begin
    if(x!=h-143||y!=v-35)$fatal(1,"Early pixel request");
   end else if(x!=1023||y!=1023)$fatal(1,"Invalid coordinate");
   n=n+1;@(negedge clk);
  end
  if($time!=33599990)$fatal(1,"Pixel-clock/period time %0t",$time);
  $display("PASS timing: %0d raster samples; 40ns pixel clock, 32us line, 16.8ms frame, positive sync and one-cycle early request",n);$finish;
 end
endmodule
