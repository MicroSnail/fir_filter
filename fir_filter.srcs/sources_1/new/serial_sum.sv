`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/23/2016 10:11:10 AM
// Design Name: 
// Module Name: serial_sum
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


module serial_sum
#(
parameter nMAC = 50,
parameter datBW = 16,
parameter outBW = 32
)
    (
      input [outBW * nMAC - 1: 0]   mac_output,
      input                         start_sum,
      input                         clk,
      input                         rst,
      output reg [outBW - 1:0]      mac_sum = 0,
      output                        sum_finished
    );
    
    reg [$clog2(nMAC)  : 0] n = 0;
    assign sum_finished = (n==nMAC);
    
    always @(posedge clk) begin
      if(rst | sum_finished) begin
        mac_sum <= 0;
        n <= 0;
      
      end else begin
        n <= n + 1;
        mac_sum <= sum_finished ? mac_sum  : (mac_sum + mac_output[n * outBW +: outBW]);
      end
    end
    


   
endmodule
