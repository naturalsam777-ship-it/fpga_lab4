`timescale 1ns/1ns
module tb_pixels;
 reg clk=0,rst_n=0;reg[9:0]x=0,y=0;
 wire[15:0]bars,must_text,end_text;
 reg[15:0]golden[0:921599];reg[15:0]actual;
 integer s,xx,yy,checks=0,fd,ppm;
 bars_pic b(clk,x,y,bars);
 vga_pic m(clk,rst_n,x,y,must_text);
 end_pic e(clk,rst_n,x,y,end_text);
 always #20 clk=~clk;
 initial begin
  $readmemh("design/golden_0.hex",golden,0,307199);
  $readmemh("design/golden_1.hex",golden,307200,614399);
  $readmemh("design/golden_2.hex",golden,614400,921599);
  fd=$fopen("evidence/pixel_results.csv","w");
  $fdisplay(fd,"state,x,y,expected_rgb565,actual_rgb565");
  #1;rst_n=0;#99;rst_n=1;
  for(s=0;s<3;s=s+1)begin
   case(s)
    0:ppm=$fopen("evidence/actual_bars.ppm","w");
    1:ppm=$fopen("evidence/actual_must.ppm","w");
    2:ppm=$fopen("evidence/actual_end.ppm","w");
   endcase
   $fdisplay(ppm,"P3\n640 480\n255");
   for(yy=0;yy<480;yy=yy+1)for(xx=0;xx<640;xx=xx+1)begin
    @(negedge clk);x=xx[9:0];y=yy[9:0];@(posedge clk);#1;
    actual=s==0?bars:s==1?must_text:end_text;
    if(actual!==golden[s*307200+yy*640+xx])$fatal(1,"Pixel state%0d at%0d,%0d expected%h actual%h",s,xx,yy,golden[s*307200+yy*640+xx],actual);
    if((yy==0||yy==208||yy==216||yy==240||yy==271||yy==272||yy==479)&&(xx%8==0))
     $fdisplay(fd,"%0d,%0d,%0d,%04h,%04h",s,xx,yy,golden[s*307200+yy*640+xx],actual);
    $fdisplay(ppm,"%0d %0d %0d",actual[15:11]*255/31,actual[10:5]*255/63,actual[4:0]*255/31);
    checks=checks+1;
   end
   $fclose(ppm);
  end
  @(negedge clk);x=1023;y=1023;@(posedge clk);#1;
  if(bars!==0||must_text!==0||end_text!==0)$fatal(1,"Blanking coordinate");
  $display("PASS pixels: %0d independent golden-pixel comparisons, all three screens, invalid coordinates",checks);
  $fclose(fd);$finish;
 end
endmodule
