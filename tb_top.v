`timescale 1ns/1ns
module tb_top;
 reg sys_clk=0,rst_n=0,key_in=1;
 wire hs,vs;wire[15:0]rgb;
 reg[15:0]golden[0:921599];reg[15:0]expected;
 integer fd,fr,ppm,transitions=0,pulses=0,checks=0,h,v,x,y,before_count;
 screen_controller dut(sys_clk,rst_n,key_in,hs,vs,rgb);
 always #10 sys_clk=~sys_clk;
 always @(posedge dut.press_pulse) if(rst_n)pulses=pulses+1;
 always @(dut.screen) begin
  #1;
  if(rst_n)begin
   transitions=transitions+1;
   if(dut.u_vga.cnt_h!=0||dut.u_vga.cnt_v!=0)$fatal(1,"State changed inside a frame");
  end
 end
 task record(input[255:0]label,input integer exp);
  begin
   if(dut.screen!==exp[1:0])$fatal(1,"%s expected%0d actual%0d",label,exp,dut.screen);
   $fdisplay(fd,"%0t,%0s,%0d,%0d,%0d,%0d",$time,label,exp,dut.screen,transitions,pulses);
  end
 endtask
 task release_key;begin key_in=1;#25000000;end endtask
 task click(input integer expected_screen);begin
  before_count=transitions;key_in=0;#40000000;
  record("clean_click",expected_screen);
  if(transitions!=before_count+1)$fatal(1,"Not exactly one transition per click");
 end endtask
 task reset_held;begin
  rst_n=0;#1;record("async_reset",0);#1000000;rst_n=1;
  before_count=transitions;#45000000;record("held_after_reset",0);
  if(transitions!=before_count)$fatal(1,"Held button retriggered after reset");
 end endtask
 task frame_check(input integer s);begin
  @(negedge dut.pixel_clk);
  while(dut.u_vga.cnt_h!=0||dut.u_vga.cnt_v!=0)@(negedge dut.pixel_clk);
  case(s)
   0:ppm=$fopen("evidence/top_bars.ppm","w");
   1:ppm=$fopen("evidence/top_must.ppm","w");
   2:ppm=$fopen("evidence/top_end.ppm","w");
  endcase
  $fdisplay(ppm,"P3\n640 480\n255");
  for(v=0;v<525;v=v+1)for(h=0;h<800;h=h+1)begin
   if(hs!==(h<96)||vs!==(v<2)||dut.screen!==s[1:0])$fatal(1,"Unstable frame or wrong sync");
   expected=0;
   if(h>=144&&h<784&&v>=35&&v<515)begin
    x=h-144;y=v-35;expected=golden[s*307200+y*640+x];
    $fdisplay(ppm,"%0d %0d %0d",rgb[15:11]*255/31,rgb[10:5]*255/63,rgb[4:0]*255/31);
   end
   if(rgb!==expected)$fatal(1,"Top state%0d pixel%0d,%0d exp%h actual%h",s,h,v,expected,rgb);
   checks=checks+1;@(negedge dut.pixel_clk);
  end
  $fclose(ppm);$fdisplay(fr,"%0t,%0d,420000,0",$time,s);
 end endtask
 initial begin
  $readmemh("design/golden_0.hex",golden,0,307199);
  $readmemh("design/golden_1.hex",golden,307200,614399);
  $readmemh("design/golden_2.hex",golden,614400,921599);
  fd=$fopen("evidence/test_results.csv","w");$fdisplay(fd,"time_ns,test,expected_state,actual_state,click_transitions,accepted_pulses");
  fr=$fopen("evidence/frame_results.csv","w");$fdisplay(fr,"time_ns,state,raster_samples,mismatches");
  $dumpfile("evidence/controller.vcd");
  $dumpvars(0,rst_n,key_in,dut.screen,dut.u_fsm.pending,dut.clean_n,dut.press_pulse,dut.u_button.armed,dut.frame_end,hs,vs);
  #1;rst_n=0;#199;rst_n=1;#30000000;record("powerup",0);frame_check(0);
  before_count=transitions;
  key_in=0;#2000000;key_in=1;#1000000;key_in=0;#3000000;key_in=1;#2000000;
  if(transitions!=before_count)$fatal(1,"Bounce caused early transition");
  key_in=0;#40000000;record("bouncing_click",1);
  if(transitions!=before_count+1)$fatal(1,"Bounce not one transition");
  #60000000;record("long_hold",1);
  if(transitions!=before_count+1)$fatal(1,"Hold repeated");
  frame_check(1);
  key_in=1;#2000000;key_in=0;#1000000;key_in=1;#3000000;key_in=0;#2000000;
  release_key;click(2);frame_check(2);
  release_key;click(0);record("wrap_to_bars",0);reset_held;
  release_key;click(1);reset_held;
  release_key;click(1);release_key;click(2);reset_held;
  release_key;click(1);release_key;
  key_in=0;#5000000;rst_n=0;#1;record("reset_mid_qualification",0);#1000;rst_n=1;#45000000;
  record("no_delayed_click",0);release_key;click(1);
  release_key;click(2);release_key;click(0);record("three_clean_clicks_wrap",0);
  $display("PASS top: %0d raster comparisons; cycle, bounce, long hold, reset every state/while held/mid-qualification; transitions=%0d pulses=%0d",checks,transitions,pulses);
  $fclose(fd);$fclose(fr);$finish;
 end
 initial begin #1200000000;$fatal(1,"Top timeout");end
endmodule
