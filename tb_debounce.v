`timescale 1ns/1ns
module tb_debounce;
 reg clk=0,rst_n=0,key_n=1,previous_pulse=0;
 wire clean_n,press_pulse;
 integer pulses=0,fd;
 button_debounce dut(clk,rst_n,key_n,clean_n,press_pulse);
 always #20 clk=~clk;
 always @(posedge press_pulse) pulses=pulses+1;
 always @(negedge clk)begin
  if(dut.count>=499990||press_pulse||previous_pulse)
   $fdisplay(fd,"%0t,%0d,%0d,%0d,%0d,%0d,%0d",$time,key_n,dut.sync2,dut.count,clean_n,press_pulse,dut.armed);
  previous_pulse=press_pulse;
 end
 task level(input bit value,input integer ns);begin key_n=value;#(ns);end endtask
 initial begin
  fd=$fopen("evidence/debounce_threshold.csv","w");$fdisplay(fd,"time_ns,key_n,sync2,count,clean_n,press_pulse,armed");
  $dumpfile("evidence/debounce.vcd");$dumpvars(0,rst_n,key_n,clean_n,press_pulse,dut.armed);
  #1;rst_n=0;#99;rst_n=1;#25000000;
  if(clean_n!==1||dut.armed!==1)$fatal(1,"Initial release not qualified");
  level(0,20);level(1,1000000);if(pulses!=0)$fatal(1,"Short glitch");
  level(0,2000000);level(1,1000000);level(0,3000000);level(1,2000000);
  if(pulses!=0)$fatal(1,"Press bounce");
  level(0,19000000);if(pulses!=0)$fatal(1,"19 ms accepted early");
  #1001000;if(pulses!=1||clean_n!==0)$fatal(1,"20 ms press missing");
  #80000000;if(pulses!=1)$fatal(1,"Long press repeated");
  level(1,2000000);level(0,1000000);level(1,3000000);level(0,2000000);
  level(1,19000000);if(clean_n!==0)$fatal(1,"Release accepted early");
  #1001000;if(clean_n!==1)$fatal(1,"Release missing");
  level(0,30000000);if(pulses!=2)$fatal(1,"Second press missing");
  rst_n=0;#101;rst_n=1;#30000000;
  if(pulses!=2||dut.armed!==0)$fatal(1,"Held through RESET produced new press");
  level(1,25000000);level(0,30000000);if(pulses!=3)$fatal(1,"Rearm after reset failed");
  $display("PASS debounce: 20ns glitch, both-edge bounce, exact threshold, 100ms hold, reset-held lockout, three qualified presses");
  $fclose(fd);$finish;
 end
 initial begin #350000000;$fatal(1,"Timeout");end
endmodule
