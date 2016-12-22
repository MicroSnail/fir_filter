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
  parameter nMAC  = 50,
  parameter linCounterBW = 16,    //This is for simulation anddebugging
  parameter outputBW = dataBitwidth * 2
  )
   (
    output [2 * dataBitwidth - 1 : 0] debug
 
    );
    // total number of sample/ size of the sample array is
    // (nData * nMAC)
    // The total number of bits in the flatten array then 
    // is given by (nData * nMAC * dataBitwidth)
    localparam totalNBits = nData * dataBitwidth * nMAC;
    localparam totalNSamples = nData * nMAC;
    localparam nBits_MAC  = nData * dataBitwidth;
//-------------------End of parameters-----------------//

    
    
    
    reg   [totalNBits - 1 : 0]      flatCoeff;
//    reg   [dataBitwidth * nData - 1 : 0]  flatSample;
    reg   [outputBW - 1 : 0]        mac_1_out;
    reg   [outputBW * nMAC - 1 : 0] mac_out;
    reg   [outputBW - 1 : 0]        mac_sum;
    reg   [linCounterBW - 1 : 0]    linCounter = 0;
    wire                            mac_done;
    assign debug = mac_1_out;
    
//------defining mac_sum ------------------------------//
    integer i_ms;
    always_comb  begin
      for (i_ms = 0; i_ms < nMAC; i_ms ++) begin: mac_sum_block
        mac_sum = mac_sum + mac_out[i_ms * outputBW - 1 +: outputBW];
      end
    end
    // NOT THE CORRECT WAY EITHER...
//------defining mac_sum end---------------------------//
    
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
    integer i;
    initial begin
      clk <= 0;
      for (i = 0; i < totalNSamples; i ++) begin
        flatCoeff[i * dataBitwidth +: dataBitwidth] = 1;
      end
    end

//------Sampler----------------------------------------//
    reg   [totalNBits - 1 : 0]  flatSample = 0;
    reg sampled = 0;
    reg mac_1_rst = 0;
    wire  [dataBitwidth - 1 : 0]  newSample;

//  Making fakeData 
    assign newSample = linCounter + 3;
    
    always @(posedge clk_sampler) begin
        linCounter <= linCounter + 1;
        flatSample <= {newSample, flatSample[totalNBits - 1 : dataBitwidth]};
        sampled <= 1;
    end

//------Sampler end------------------------------------//    


//-------Create multiple arrays, each for a MAC--------//
    wire   [nBits_MAC - 1 : 0] sampleSplit  [0 : nMAC-1];
    wire   [nBits_MAC - 1 : 0] coeffSplit   [0 : nMAC-1];
    genvar iMAC;
    generate
      for ( iMAC = 0; iMAC < nMAC; iMAC ++) begin : MACs_block
        assign sampleSplit[iMAC] = flatSample[(iMAC+1) * nBits_MAC - 1 : iMAC * nBits_MAC];
        assign coeffSplit[iMAC]  = flatCoeff[(iMAC+1) * nBits_MAC - 1 : iMAC * nBits_MAC];
      end
    endgenerate
//-------Create multiple arrays, (each for a MAC) end--//


//------Multiply Accumulator reset counter-------------//

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
//------Multiply Accumulator reset counter end---------//  

//----Instantiate multiple MACs -----------------------//
multiplyAccumulator MACs [nMAC-1 : 0] (
.inA(flatCoeff),
.inB(flatSample),
.clk(clk_mac),
.rst(mac_rst),
.mac_out(mac_out)
);
//----Instantiate multiple MACs end--------------------//




//------Multiply Accumulator---------------------------//  
//  multiplyAccumulator mac_1(
//		.inA(flatCoeff), 
//		.inB(flatSample), 
//		.clk(clk_mac), 
//		.rst( mac_rst ),
//		.mac_out(mac_1_out),
//		.mac_done(mac_done)
//		);
//------Multiply Accumulator end-----------------------//
    
   

endmodule    

    

    