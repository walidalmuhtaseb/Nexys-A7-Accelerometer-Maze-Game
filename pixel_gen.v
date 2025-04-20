//////////////////////////////////////////////////////////////////////////////////
// Engineer: Walid Al-Muhtaseb
// 
// Create Date: 16/4/2025 07:14:38 PM
// Design Name: Picel Generator
// Module Name: pixel_gen
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module pixel_gen(
    input bright,     
    input [9:0] x,      
    input [9:0] y,      
    input [9:0] xpos, ypos,
    input block_fill,
    input clk,
    input game_over,
    output reg [11:0] rgb   
    );
    
    // RGB Color Values
    parameter RED       = 12'hF00;
    parameter light_RED = 12'hA00;
    parameter GREEN     = 12'h0F0;
    parameter BLUE      = 12'h22F;
    parameter YELLOW    = 12'hFF0;     
    parameter BLACK     = 12'h000;    
    parameter WHITE     = 12'hFFF;
    parameter PURPLE    = 12'hC0F;
    parameter BACKGROUND = 12'h333;
    parameter BALL      = 12'hF44;
    parameter WALL      = 12'h666;
    parameter USC_CARDINAL = 12'h900;  // USC Cardinal (Red)
    parameter USC_GOLD     = 12'hFC3;  // USC Gold
    
    // Maze dimensions
    parameter MAZE_LEFT = 415;
    parameter MAZE_TOP = 33;
    parameter CELL_SIZE = 32;
    parameter MAZE_WIDTH = 10;
    parameter MAZE_HEIGHT = 15;

    // Sprite position and dimensions
    parameter SPRITE_LEFT = 200; // Desired position
    parameter SPRITE_TOP = 190;  // Desired position
    parameter SPRITE_WIDTH = 250; // Sprite size is 150x250 (width x height)
    parameter SPRITE_HEIGHT = 250;
    
    // Compact maze representation
    // Each row is a 10-bit value where 1=wall, 0=path
    parameter [9:0] MAZE_ROW_0 = 10'b1111111111;
    parameter [9:0] MAZE_ROW_1 = 10'b1000000001;
    parameter [9:0] MAZE_ROW_2 = 10'b1011110111;
    parameter [9:0] MAZE_ROW_3 = 10'b1000010101;
    parameter [9:0] MAZE_ROW_4 = 10'b1011110101;
    parameter [9:0] MAZE_ROW_5 = 10'b1000011101;
    parameter [9:0] MAZE_ROW_6 = 10'b1011010001;
    parameter [9:0] MAZE_ROW_7 = 10'b1010000111;
    parameter [9:0] MAZE_ROW_8 = 10'b1011111101;
    parameter [9:0] MAZE_ROW_9 = 10'b1000110001;
    parameter [9:0] MAZE_ROW_10 = 10'b1010100101;
    parameter [9:0] MAZE_ROW_11 = 10'b1010001101;
    parameter [9:0] MAZE_ROW_12 = 10'b1011111101;
    parameter [9:0] MAZE_ROW_13 = 10'b1000000101;
    parameter [9:0] MAZE_ROW_14 = 10'b1111111111;

    parameter [9:0] WIN_ROW_0 = 10'b0111101111;
    parameter [9:0] WIN_ROW_1 = 10'b0100001001;
    parameter [9:0] WIN_ROW_2 = 10'b0101101001;
    parameter [9:0] WIN_ROW_3 = 10'b0100101001;
    parameter [9:0] WIN_ROW_4 = 10'b0111101111;
    parameter [9:0] WIN_ROW_5 = 10'b0000000000;
    parameter [9:0] WIN_ROW_6 = 10'b0111110000;
    parameter [9:0] WIN_ROW_7 = 10'b0100000000;
    parameter [9:0] WIN_ROW_8 = 10'b0100000000;
    parameter [9:0] WIN_ROW_9 = 10'b0111110000;
    parameter [9:0] WIN_ROW_10 = 10'b0000011111;
    parameter [9:0] WIN_ROW_11 = 10'b0000010000;
    parameter [9:0] WIN_ROW_12 = 10'b0111110000;
    parameter [9:0] WIN_ROW_13 = 10'b0000010000;
    parameter [9:0] WIN_ROW_14 = 10'b0000011111;
    

    wire is_sprite;
    assign is_sprite = (x >= SPRITE_LEFT && x < SPRITE_LEFT + SPRITE_WIDTH &&
                        y >= SPRITE_TOP && y < SPRITE_TOP + SPRITE_HEIGHT);
    
    // Calculate sprite row and column for ROM lookup
    wire [9:0] sprite_row, sprite_col;
    assign sprite_row = (y - SPRITE_TOP); 
    assign sprite_col = (x - SPRITE_LEFT); 
    
    // Wire for sprite color data
    wire [11:0] sprite_color;
    
    // Instantiate sprite ROM
    sprite_rom sprite_display(
        .clk(clk),
        .row(sprite_row),
        .col(sprite_col),
        .color_data(sprite_color)
    );


    // Determine if the current pixel is part of a wall
    wire is_wall;
    assign is_wall = in_maze_wall(x, y);
    
    // Goal position
    wire is_goal;
    assign is_goal = (x >= MAZE_LEFT + 8*CELL_SIZE) && (x < MAZE_LEFT + 9*CELL_SIZE) && 
                     (y >= MAZE_TOP + 13*CELL_SIZE) && (y < MAZE_TOP + 14*CELL_SIZE);
    
    // Function to check if a pixel is part of a maze wall
    function in_maze_wall;
        input [9:0] pixel_x, pixel_y;
        integer grid_x, grid_y;
        reg [9:0] maze_row;
        begin
            // Check if pixel is within maze boundaries
            if (pixel_x >= MAZE_LEFT && pixel_x < MAZE_LEFT + MAZE_WIDTH*CELL_SIZE &&
                pixel_y >= MAZE_TOP && pixel_y < MAZE_TOP + MAZE_HEIGHT*CELL_SIZE) begin
                
                // Convert pixel position to grid position
                grid_x = (pixel_x - MAZE_LEFT) / CELL_SIZE;
                grid_y = (pixel_y - MAZE_TOP) / CELL_SIZE;
                
                // Add a small border around cells for better visibility
                if ((pixel_x - MAZE_LEFT) % CELL_SIZE == 0 || (pixel_y - MAZE_TOP) % CELL_SIZE == 0)
                    in_maze_wall = 1;
                else begin
                 if (game_over) begin
                    case (grid_y)
                        0: maze_row = WIN_ROW_0;
                        1: maze_row = WIN_ROW_1;
                        2: maze_row = WIN_ROW_2;
                        3: maze_row = WIN_ROW_3;
                        4: maze_row = WIN_ROW_4;
                        5: maze_row = WIN_ROW_5;
                        6: maze_row = WIN_ROW_6;
                        7: maze_row = WIN_ROW_7;
                        8: maze_row = WIN_ROW_8;
                        9: maze_row = WIN_ROW_9;
                        10: maze_row = WIN_ROW_10;
                        11: maze_row = WIN_ROW_11;
                        12: maze_row = WIN_ROW_12;
                        13: maze_row = WIN_ROW_13;
                        14: maze_row = WIN_ROW_14;
                        default: maze_row = 10'b1111111111;
                    endcase
                end
                else begin
                    case (grid_y)
                        0: maze_row = MAZE_ROW_0;
                        1: maze_row = MAZE_ROW_1;
                        2: maze_row = MAZE_ROW_2;
                        3: maze_row = MAZE_ROW_3;
                        4: maze_row = MAZE_ROW_4;
                        5: maze_row = MAZE_ROW_5;
                        6: maze_row = MAZE_ROW_6;
                        7: maze_row = MAZE_ROW_7;
                        8: maze_row = MAZE_ROW_8;
                        9: maze_row = MAZE_ROW_9;
                        10: maze_row = MAZE_ROW_10;
                        11: maze_row = MAZE_ROW_11;
                        12: maze_row = MAZE_ROW_12;
                        13: maze_row = MAZE_ROW_13;
                        14: maze_row = MAZE_ROW_14;
                        default: maze_row = 10'b1111111111;
                    endcase
                end
                    
                    // Check the bit at the column position
                    in_maze_wall = maze_row[9-grid_x]; // Note: MSB is leftmost column
                end
            end
            else
                in_maze_wall = 0; // Outside maze boundary
        end
    endfunction
    
    // Set RGB output value based on pixel location
 always @* begin
        if (~bright)
            rgb = BLACK;
        else if (game_over) begin // change background color when game is over
            if (block_fill)
                rgb = USC_GOLD;  // Make the player sprite blue
            else if (is_wall)
                rgb = USC_CARDINAL;   // Change walls to red
            else
                rgb = BLACK;  // Change background to black
        end
        else if (block_fill)
            rgb = USC_CARDINAL;
        else if (is_goal)
            rgb = USC_GOLD;
        else if (is_wall)
            rgb = WALL;
        else if (is_sprite && sprite_color != 12'h000) // Only display non-black sprite pixels
            rgb = sprite_color;
        else if (x >= MAZE_LEFT && x < MAZE_LEFT + MAZE_WIDTH*CELL_SIZE &&
                 y >= MAZE_TOP && y < MAZE_TOP + MAZE_HEIGHT*CELL_SIZE)
            rgb = WHITE; // Maze paths
        else
            rgb = BACKGROUND;
    end
    
endmodule