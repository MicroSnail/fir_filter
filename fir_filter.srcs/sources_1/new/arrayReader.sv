`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/22/2016 03:19:08 PM
// Design Name: 
// Module Name: arrayReader
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


module arrayReader
#(
  parameter nData = 16,
  parameter datBW = 16
  )
  (
  input   [nData * datBW - 1 : 0]   inA,
  input                             clk,
  output  reg [datBW - 1 : 0]       Q,
  input                             rst
    );
    
    always @(posedge clk) begin
      if (rst) begin
        Q <= 0;
      end else begin
        Q <= inA[nData * datBW - 1 : (nData - 1) * datBW - 1];
      end
      
    end
    
endmodule
