//////////////////////////////////////////////////////////////////////////////////
// top.v - main entry point for this design
// Benjamin Blundell
// https://benjamin.computer
// Create Date: 22.01.2018 17:17:15
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module top(
    input wire CLK,
    input wire RST_BTN,
    output wire VGA_HS_O,
    output wire VGA_VS_O,
    output reg [3:0] VGA_R,
    output reg [3:0] VGA_G,
    output reg [3:0] VGA_B
    );

    wire rst = ~RST_BTN;  // active low
    
    // generate a 25 MHz pixel strobe
    reg [15:0] cnt = 0;
    reg pix_stb = 0;
    always @(posedge CLK)
        {pix_stb, cnt} <= cnt + 16'h4000;  // divide clock by 4: (2^16)/4 = 0x4000
    

    wire [9:0] x_disp;  // 10-bit value: 0-1023 
    wire [8:0] y_disp;  //  9-bit value: 0-511
    
    wire active;        // high during active pixel drawing
    wire screenend;     // high for one tick at the end of screen
    wire blanking;      // high within the blanking period
    wire animate;
    
    integer tcount = 0;
    
    vga320x180 display (
        .i_clk(CLK), 
        .i_pix_stb(pix_stb),
        .o_hs(VGA_HS_O), 
        .o_vs(VGA_VS_O), 
        .o_x(x_disp), 
        .o_y(y_disp),
        .o_blanking(blanking),
        .o_active(active),
        .o_screenend(screenend),
        .o_animate(animate)
    );

    localparam SCREEN_WIDTH = 180;
    localparam SCREEN_HEIGHT = 90;

    // both VRAM buffers are the same size
    localparam VRAM_A_WIDTH = 16; 
    localparam VRAM_D_WIDTH = 8; 
    localparam VRAM_DEPTH = SCREEN_WIDTH*SCREEN_HEIGHT  ; 

    reg [VRAM_A_WIDTH-1:0] address_a, address_b;
    wire [VRAM_D_WIDTH-1:0] dataout_a, dataout_b;
    reg [VRAM_D_WIDTH-1:0] datain_a, datain_b; 
    
    reg write_buffer_a = 0;
    reg write_buffer_b = 1;
    reg clear_buffer_a = 0;
    reg clear_buffer_b = 0;
    reg front_buffer_is_a = 1;
    
    sram #(
        .ADDR_WIDTH(VRAM_A_WIDTH), 
        .DATA_WIDTH(VRAM_D_WIDTH), 
        .DEPTH(VRAM_DEPTH),
        .MEMFILE("init.mem")) 
        vram_a (
        .i_addr(address_a), 
        .i_clk(CLK), 
        .i_clear(clear_buffer_a),
        .i_write(write_buffer_a),  // we're always reading
        .i_data(datain_a), 
        .o_data(dataout_a)
    );
    
    sram #(
        .ADDR_WIDTH(VRAM_A_WIDTH), 
        .DATA_WIDTH(VRAM_D_WIDTH), 
        .DEPTH(VRAM_DEPTH),
        .MEMFILE("init.mem")) 
        vram_b (
        .i_addr(address_b), 
        .i_clk(CLK), 
        .i_clear(clear_buffer_b),
        .i_write(write_buffer_b),  // we're always reading
        .i_data(datain_b), 
        .o_data(dataout_b)
    );
    
    // Global and shared between the metaballs - which pixels
    // are we actually updating?
    integer x_met;
    integer y_met;

    // Metaball A
    wire [31:0] mb_a_f;
    wire mb_a_complete;
    metaball #(.IX(20), .IY(20), .RD(10), .D_WIDTH(180), .D_HEIGHT(90), .WAIT(4)) mb_a_anim (
        .i_clk(CLK),
        .i_rst(rst),
        .i_x(x_met),
        .i_y(y_met),
        .i_animate(screenend),
        .o_f(mb_a_f),
        .o_complete(mb_a_complete));
    
    // Metaball B    
    wire [31:0] mb_b_f;
    wire mb_b_complete; 
    metaball #(.IX(60), .IY(60), .RD(15), .IX_DIR(-1), .D_WIDTH(180), .D_HEIGHT(90), .WAIT(16)) mb_b_anim (
          .i_clk(CLK),
          .i_rst(rst),
          .i_x(x_met),
          .i_y(y_met),
          .i_animate(screenend),
          .o_f(mb_b_f),
          .o_complete(mb_b_complete));
          
   wire [31:0] mb_c_f;
   wire mb_c_complete; 
   metaball #(.IX(25), .IY(25), .RD(5), .D_WIDTH(180), .D_HEIGHT(90), .WAIT(2)) mb_c_anim (
     .i_clk(CLK),
     .i_rst(rst),
     .i_x(x_met),
     .i_y(y_met),
     .i_animate(screenend),
     .o_f(mb_c_f),
     .o_complete(mb_c_complete));

    // Fixed point addition x 2
    wire [31:0] mb_sum_0;
    qadd #(15,32) my_adder_0 (
        .a(mb_a_f),
        .b(mb_b_f),
        .c(mb_sum_0)
    );
    
    wire [31:0] mb_sum_1;
    qadd #(15,32) my_adder_1 (
        .a(mb_sum_0),
        .b(mb_c_f),
        .c(mb_sum_1)
    );
       
    reg [11:0] palette [0:255];  // 256 x 12-bit colour palette entries
    reg [11:0] colour;
    initial begin
        $display("Loading palette.");
        $readmemh("sprites_palette.mem", palette);
        x_met = 0;
        y_met = 0;
    end

    always @ (posedge CLK)
    begin
        // Check out metaballs
        // WRITING to buffer step
        // Write to buffer B
        if (front_buffer_is_a) begin
            if (mb_a_complete == 1) begin
                address_b <= y_met * SCREEN_WIDTH + x_met;
                datain_b <= mb_sum_1 >> 15 >= 1 ? 12 : 0;
                write_buffer_b <= 1;
                 
                // Advance metaball pixel pos
                x_met <= x_met + 1; 
                if (x_met >= SCREEN_WIDTH)
                begin
                    x_met <= 0;
                    y_met <= y_met + 1;
                    if (y_met >= SCREEN_HEIGHT)
                    begin
                        y_met <= 0;
                    end
                end
            end  else  begin
                write_buffer_b <= 0;
            end
        end
        // Write to buffer A
        else
        begin
          
           if (mb_a_complete == 1) begin
                address_a <= y_met * SCREEN_WIDTH + x_met;
                datain_a <= mb_sum_1 >> 15 >= 1 ? 12 : 0;
                write_buffer_a <= 1;
                
                // Advance metaball pixel pos
                x_met <= x_met + 1;
                if (x_met >= SCREEN_WIDTH)
                begin
                    x_met <= 0;
                    y_met <= y_met + 1;
                    if (y_met >= SCREEN_HEIGHT)
                    begin
                        y_met <= 0;
                    end
                end
            end else  begin
                write_buffer_a <= 0;
            end
        end
      
        // READING from Buffer Step - also includes swapping and clearing buffers
        if (pix_stb)
        begin
            // Swap buffers
            // Should really occur only when one has been completely filled.
            // Hopefully our division and metaballs bit is fast enough to do this
            // Might have to work out the timing? 47 * 360 * 180 ticks?
            //if (mb_a_complete)
            if (screenend)  // switch active buffer once per frame
            begin
                front_buffer_is_a = !front_buffer_is_a;
     
                // We need to clear out the back buffer before writing
                // Essentially, write the background colour to it
                if (front_buffer_is_a)
                begin
                    clear_buffer_a <= 0;
                    clear_buffer_b <= 1;
                end
                else
                begin
                    clear_buffer_a <= 1;
                    clear_buffer_b <= 0;
                end
                
            end
            else
            begin
                clear_buffer_a <= 0;
                clear_buffer_b <= 0;
            end
        
            // Read from buffer a
            if (front_buffer_is_a)
            begin
                write_buffer_a = 0;
                address_a <= y_disp * SCREEN_WIDTH + x_disp;
                colour <= palette[dataout_a];
            end
            // Read from Buffer B
            else
            begin
                write_buffer_b = 0;
                address_b <= y_disp * SCREEN_WIDTH + x_disp;
                colour <= palette[dataout_b];
            end
        end
        
        // Turns out we really need this line even though Will's latest does not :/
        if (blanking)
        begin
          colour <= 0;
        end
        
        VGA_R <= colour[11:8];
        VGA_G <= colour[7:4];
        VGA_B <= colour[3:0];
    end
endmodule