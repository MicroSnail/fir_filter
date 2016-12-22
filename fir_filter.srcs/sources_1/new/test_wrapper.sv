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


module test_wrapper
  #(
  parameter nData = 16,
  parameter dataBitwidth = 16,
  parameter linCounterBW = 4)
   (
    output [2 * dataBitwidth - 1 : 0] debug
 
    );

    
    reg   [dataBitwidth * nData - 1 : 0]  flatCoeff;
//    reg   [dataBitwidth * nData - 1 : 0]  flatSample;
    reg   [2 * dataBitwidth - 1 : 0]      mac_1_out;    
    reg   [4:0]                           i;
    reg   [linCounterBW - 1 : 0]          linCounter = 0;
    wire                          mac_done;
  
    assign debug = mac_1_out;
    
    
//------Clock generator for simulation-----------------//
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
      if (counter == 0) begin      clk_sampler <= ~clk_sampler;
      end
    end
    
//-----------Clock generator end-----------------------//

//    This is to populate the fixed array for coefficients
    initial begin
      clk <= 0;
      for (i = 0; i < nData; i ++) begin
        flatCoeff[i * dataBitwidth +: dataBitwidth] = 1;
      end
    end

//------Sampler----------------------------------------//
    reg   [dataBitwidth * nData - 1 : 0]  flatSample = 0;
    reg sampled = 0;
    reg mac_1_rst = 0;
    wire  [dataBitwidth - 1 : 0]  newSample;

//  Making fakeData 
    assign newSample = linCounter * 2 + 10;
    
    always @(posedge clk_sampler) begin
        linCounter <= linCounter + 1;
        flatSample <= {newSample, flatSample[nData * dataBitwidth - 1 : dataBitwidth ]};
        sampled <= 1;
    end

//------Sampler end------------------------------------//    

//------Multiply Accumulator---------------------------//

/* These are for generating clocks to clear the MAC, for
 * n MACs in parallel, they can use the same clear signal.
 */
    reg [$clog2(nData) : 0] resetCounter = 0;
    wire mac_rst;
    assign mac_rst = (resetCounter == nData);
    always @(posedge clk_mac) begin
      if(mac_rst) begin
        resetCounter <= 0;
      end else begin
        resetCounter <= resetCounter + 1;
      end
    end
  
  
  multiplyAccumulator mac_1(
		.inA(flatCoeff), 
		.inB(flatSample), 
		.clk(clk_mac), 
		.rst( mac_rst ),
//		.execute(sampled),
		.mac_out(mac_1_out),
		.mac_done(mac_done)
		);
//------Multiply Accumulator end-----------------------//
    
   

endmodule    

    

    