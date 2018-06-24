//////////////////////////////////////////////////////////////////////////////////
// sram.v - SRAM
// Will Green
// https://timetoexplore.net/
// Create Date: 22.01.2018 17:17:15
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps
`default_nettype none

module sram #(parameter ADDR_WIDTH = 8, DATA_WIDTH = 8, DEPTH = 256, MEMFILE="") (
    input wire i_clk,
    input wire [ADDR_WIDTH-1:0] i_addr, 
    input wire i_write,
    input wire i_clear,
    input wire [DATA_WIDTH-1:0] i_data,
    output reg [DATA_WIDTH-1:0] o_data 
    );

    reg [DATA_WIDTH-1:0] memory_array [0:DEPTH-1]; 

    initial begin
        $display("Loading memory array.");
        $readmemh(MEMFILE, memory_array);
    end

    always @ (posedge i_clk)
    begin
        if(i_write) begin
            memory_array[i_addr] <= i_data;
        end
        else begin
            o_data <= memory_array[i_addr];
        end 
        
        if (i_clear) begin
            $readmemh(MEMFILE, memory_array);
        end
    end
endmodule