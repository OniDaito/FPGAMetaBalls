//////////////////////////////////////////////////////////////////////////////////
// metaball.v - main entry point for this design
// Benjamin Blundell
// https://benjamin.computer
// Create Date: 22.01.2018 17:17:15
//
// Metaballs algorithm - see http://jamie-wong.com/2014/08/19/metaballs-and-marching-squares/ for a good overview
//
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module metaball #(
    IX = 50,       // Initial position X
    IY = 50,       // Initial position Y
    RD = 30,        // Radius
    IX_DIR=1,       // initial horizontal direction: 1 is increasing
    IY_DIR=1,       // initial vertical direction: 0 is decreasing
    D_WIDTH=360,    // width of display
    D_HEIGHT=180,    // height of display
    WAIT = 4
    ) 
    (
    input wire i_clk,
    input wire i_rst,
    input wire integer i_x, // shared among metaballs
    input wire integer i_y,   
    input wire i_animate,
    output reg [31:0] o_f,
    output reg o_complete
    );
    
    integer x = IX;   // 12-bit value: 0-4095
    integer y = IY;
    reg x_dir = IX_DIR;
    reg y_dir = IY_DIR;
    
    // Division related
    integer td, r_fixed;
    reg start = 0;
    wire done_o;

    wire[31:0] dd_o;
    wire overflow_o;
    
    reg[8:0] counter;
    
    qdiv #(15,32) my_divider (
        .i_dividend(r_fixed),
        .i_divisor(td),
        .i_clk(i_clk),
        .i_start(start),
        .o_quotient_out(dd_o),
        .o_complete(done_o),
        .o_overflow(overflow_o) 
        );
        
    initial begin
        // Initialize Inputs
        o_complete = 0;
        td <= (x - i_x) * ( x - i_x) + (y - i_y) * ( y - i_y);
        counter = 0;        
        r_fixed <= RD * RD;

    end
    
    //always @(posedge done_o)
    //    $display ("%b,%b,%b, %b", tn, td, o_f, overflow_o);        //    Monitor the stuff we care about
    
    always @ (posedge i_clk)
        begin            
            // Reset to the beginning
            if (i_rst) 
            begin
                x <= IX;
                y <= IY;
                x_dir <= IX_DIR;
                y_dir <= IY_DIR;
            end
            
       
            // We move the metaball and hope we've covered all the pixels
            if (i_animate == 1)
            begin
                counter <= counter + 1;
                if (counter >= WAIT) begin
                    counter <= 0;
                    o_complete <= 1;
                    x <= (x_dir) ? x + 1 : x - 1;
                    y <= (y_dir) ? y + 1 : y - 1; 
                    if (x <= RD)
                        x_dir <= 1;
                    if (x >= (D_WIDTH - RD - 1))
                        x_dir <= 0;          
                    if (y <= RD)
                        y_dir <= 1;
                    if (y >= (D_HEIGHT - RD - 1))
                        y_dir <= 0;
                end else begin
                    counter <= counter + 1;
                end
            end
            
  
            // Division for field functions
            // Apparently it takes 47 clock cycles for a 31 / 15 divisor
            // When we are done, we set td again.
            if (done_o == 1) begin
                o_f <= dd_o; // Now copy the output to the register. No shift yet
                td <= (x - i_x) * ( x - i_x) + (y - i_y) * ( y - i_y);
                // Test bit
                /*if (x < (i_x + RD) && x >  (i_x - RD) && y < (i_y + RD) && y > (i_y - RD))
                begin
                   o_f <= 1;
                end
                else
                begin
                   o_f <= 0;
                end */
                

                // We are ready to output a pixel position   
                // Now start another divide
                o_complete <= 1;
                start <= 1;
        
            end
            else begin			
                o_complete <= 0;
            end                  
        end
endmodule
