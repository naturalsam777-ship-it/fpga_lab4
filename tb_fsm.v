`timescale 1ns/1ns
module tb_fsm;
 reg clk=0,rst_n=0,frame_end=0,press_pulse=0;
 wire[1:0]screen;
 integer i,fd;
 screen_fsm dut(clk,rst_n,frame_end,press_pulse,screen);
 always #20 clk=~clk;
 task step(input bit f,input bit p);begin
  @(negedge clk);frame_end=f;press_pulse=p;@(posedge clk);#1;
 end endtask
 task check(input[1:0]expected);begin
  if(screen!==expected)$fatal(1,"FSM expected%0d got%0d",expected,screen);
  $fdisplay(fd,"%0t,%0d,%0d,%0d,%0d,%0d",$time,frame_end,press_pulse,dut.pending,expected,screen);
 end endtask
 initial begin
  fd=$fopen("evidence/fsm_unit.csv","w");$fdisplay(fd,"time_ns,frame_end,press_pulse,pending,expected,actual");
  #1;rst_n=0;#99;rst_n=1;check(0);
  for(i=1;i<=3;i=i+1)begin
   step(0,1);check((i-1)%3);step(0,0);check((i-1)%3);
   step(1,0);check(i%3);step(1,0);check(i%3);
  end
  step(1,1);check(1);step(0,0);
  rst_n=0;#1;check(0);rst_n=1;
  step(1,1);check(1);step(1,1);check(2);step(0,1);
  rst_n=0;#1;check(0);rst_n=1;step(1,0);check(0);
  force dut.state=2'b11;#1;release dut.state;step(0,0);check(0);
  $display("PASS FSM: cycle, pending press, same-cycle press/frame, reset all states, pending reset, invalid-state recovery");
  $fclose(fd);$finish;
 end
endmodule
