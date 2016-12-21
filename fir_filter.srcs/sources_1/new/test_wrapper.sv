`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/20/2016 01:55:05 PM
// Design Name: 
// Module Name: wrapper
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module test_wrapper(

    );
    parameter nData = 16;
    parameter dataBitwidth = 16;
    
    reg   [dataBitwidth - 1 : 0]  fixedArray [0 : nData - 1];
    reg   [dataBitwidth * nData - 1 : 0] flatCoeff;
    reg   [dataBitwidth * nData - 1 : 0] flatSample;
    reg   [2 * nData - 1 : 0]     mac_1_sum;    
    reg   [4:0]                   i;
    reg   [16 - 1 : 0]            delayCounter=0; 
    wire  [dataBitwidth - 1 : 0]  fakeSample;
    wire                          mac_done;

//------Fake Clock generator---------------------------//
    reg clk = 0;
    reg clk_sampler = 0;
    reg clk_mac;    
    always begin
      #5 clk <= ~clk;
    end
    
    assign clk_mac = clk;
    
    reg [$clog2(nData) - 1 - 1: 0] counter = 0;
    always @(posedge clk_mac) begin
      counter <= counter + 1;
      if (counter == 0) begin
        clk_sampler <= ~clk_sampler;
      end
    end
    
//------Fake Clock generator end-----------------------//

//    This is to populate the fixed array for coefficients
    initial begin
      clk <= 0;
      $display("clog2(nData) = %d", $clog2(nData));
      for (i = 0; i < nData; i ++) begin
        $display("i = %d",i);
        fixedArray[i] = i;
        flatCoeff[i * dataBitwidth +: dataBitwidth] = 1;
        flatSample[i * dataBitwidth +: dataBitwidth] = 5+i;
        $display("testArray[%d] = %d", i,fixedArray[i]);
      end
    end

//------Sampler----------------------------------------//
    always @(posedge clk_sampler) begin
      
    end
//------Sampler end------------------------------------//    

//------Multiply Accumulator---------------------------//
  wire mac_1_rst = 0;
  
  multiplyAccumulator mac_1(
		.inA(flatCoeff), 
		.inB(flatSample), 
		.clk(clk_mac), 
		.rst(mac_1_rst),
		.result(mac_1_sum),
		.mac_done(mac_done)
		);
//------Multiply Accumulator end-----------------------//
    
   
//  Making fakeData 
    assign fakeSample = delayCounter * 2;
    
    always @(posedge clk) begin
      delayCounter <= delayCounter + 1;
      
      $display("Delay counter = %d", delayCounter);
      $display("fakeData = %d", fakeSample);
      
    end
endmodule    

    

    