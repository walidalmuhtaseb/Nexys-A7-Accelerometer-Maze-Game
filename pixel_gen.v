`timescale 1ns / 1ps

module pixel_gen(
    input bright,     
    input [9:0] x,      
    input [9:0] y,      
    input [9:0] xpos, ypos,
    input block_fill,
    output reg [11:0] rgb   
    
    );
    
    // RGB Color Values
    parameter RED       = 12'hF00;
    parameter GREEN     = 12'h0F0;
    parameter BLUE      = 12'h8CF;  // Baby blue
    parameter YELLOW    = 12'hFF0;     
    parameter BLACK     = 12'h000;    
    parameter WHITE     = 12'hFFF;
    parameter PURPLE    = 12'hC0F;
    parameter BACKGROUND = 12'h333;  // Dark gray background
    parameter BALL      = 12'hF44;   // Player ball color
    parameter WALL      = 12'h666;   // Maze wall color
    
    // Maze dimensions
    parameter MAZE_LEFT = 385;  // Position of the left edge of the maze
    parameter MAZE_TOP = 40;    // Position of the top edge of the maze
    parameter CELL_SIZE = 32;   // Size of each cell (32x32 pixels)
    parameter MAZE_WIDTH = 10;  // 10 columns
    parameter MAZE_HEIGHT = 15; // 15 rows
    
    // Determine if the current pixel is part of a wall
    wire is_wall;
    assign is_wall = in_maze_wall(x, y);
    
    // Goal position (the purple square in your design) at grid position (8,14)
    wire is_goal;
    assign is_goal = (x >= MAZE_LEFT + 8*CELL_SIZE) && (x < MAZE_LEFT + 9*CELL_SIZE) && 
                    (y >= MAZE_TOP + 13*CELL_SIZE) && (y < MAZE_TOP + 14*CELL_SIZE);
    
    // Function to check if a pixel is part of a maze wall
    function in_maze_wall;
        input [9:0] pixel_x, pixel_y;
        reg [0:9] maze [0:14]; // 10x15 maze
        integer grid_x, grid_y;
        begin
            // Initialize maze layout (1 = wall, 0 = path)
            // Top row (all walls)
            maze[0][0] = 1; maze[0][1] = 1; maze[0][2] = 1; maze[0][3] = 1; maze[0][4] = 1;
            maze[0][5] = 1; maze[0][6] = 1; maze[0][7] = 1; maze[0][8] = 1; maze[0][9] = 1;
            
            // Row 1 
            maze[1][0] = 1; maze[1][1] = 0; maze[1][2] = 0; maze[1][3] = 0; maze[1][4] = 0;
            maze[1][5] = 0; maze[1][6] = 0; maze[1][7] = 0; maze[1][8] = 0; maze[1][9] = 1;
            
            // Row 2 
            maze[2][0] = 1; maze[2][1] = 0; maze[2][2] = 1; maze[2][3] = 1; maze[2][4] = 1;
            maze[2][5] = 1; maze[2][6] = 0; maze[2][7] = 1; maze[2][8] = 1; maze[2][9] = 1;
            
            // Row 3
            maze[3][0] = 1; maze[3][1] = 0; maze[3][2] = 0; maze[3][3] = 0; maze[3][4] = 0;
            maze[3][5] = 1; maze[3][6] = 0; maze[3][7] = 1; maze[3][8] = 0; maze[3][9] = 1;
            
            // Row 4
            maze[4][0] = 1; maze[4][1] = 0; maze[4][2] = 1; maze[4][3] = 1; maze[4][4] = 1;
            maze[4][5] = 1; maze[4][6] = 0; maze[4][7] = 1; maze[4][8] = 0; maze[4][9] = 1;
            
            // Row 5
            maze[5][0] = 1; maze[5][1] = 0; maze[5][2] = 0; maze[5][3] = 0; maze[5][4] = 0;
            maze[5][5] = 1; maze[5][6] = 1; maze[5][7] = 7; maze[5][8] = 0; maze[5][9] = 1;
            
            // Row 6
            maze[6][0] = 1; maze[6][1] = 0; maze[6][2] = 1; maze[6][3] = 1; maze[6][4] = 0;
            maze[6][5] = 1; maze[6][6] = 0; maze[6][7] = 0; maze[6][8] = 0; maze[6][9] = 1;
            
            // Row 7
            maze[7][0] = 1; maze[7][1] = 0; maze[7][2] = 1; maze[7][3] = 0; maze[7][4] = 0;
            maze[7][5] = 0; maze[7][6] = 0; maze[7][7] = 1; maze[7][8] = 1; maze[7][9] = 1;
            
            // Row 8
            maze[8][0] = 1; maze[8][1] = 0; maze[8][2] = 1; maze[8][3] = 1; maze[8][4] = 1;
            maze[8][5] = 1; maze[8][6] = 1; maze[8][7] = 1; maze[8][8] = 0; maze[8][9] = 1;
            
            // Row 9
            maze[9][0] = 1; maze[9][1] = 0; maze[9][2] = 0; maze[9][3] = 0; maze[9][4] = 0;
            maze[9][5] = 1; maze[9][6] = 0; maze[9][7] = 0; maze[9][8] = 0; maze[9][9] = 1;
            
            // Row 10
            maze[10][0] = 1; maze[10][1] = 0; maze[10][2] = 1; maze[10][3] = 0; maze[10][4] = 1;
            maze[10][5] = 0; maze[10][6] = 0; maze[10][7] = 0; maze[10][8] = 0; maze[10][9] = 1;
            
            // Row 11
            maze[11][0] = 1; maze[11][1] = 0; maze[11][2] = 1; maze[11][3] = 0; maze[11][4] = 0;
            maze[11][5] = 0; maze[11][6] = 0; maze[11][7] = 1; maze[11][8] = 0; maze[11][9] = 1;
            
            // Row 12
            maze[12][0] = 1; maze[12][1] = 0; maze[12][2] = 1; maze[12][3] = 1; maze[12][4] = 1;
            maze[12][5] = 1; maze[12][6] = 1; maze[12][7] = 1; maze[12][8] = 0; maze[12][9] = 1;
            
            // Row 13
            maze[13][0] = 1; maze[13][1] = 0; maze[13][2] = 0; maze[13][3] = 0; maze[13][4] = 0;
            maze[13][5] = 0; maze[13][6] = 0; maze[13][7] = 1; maze[13][8] = 0; maze[13][9] = 1;
            
            // Row 14 (bottom row - all walls)
            maze[14][0] = 1; maze[14][1] = 1; maze[14][2] = 1; maze[14][3] = 1; maze[14][4] = 1;
            maze[14][5] = 1; maze[14][6] = 1; maze[14][7] = 1; maze[14][8] = 1; maze[14][9] = 1;
            
            // Check if pixel is within maze boundaries
            if (pixel_x >= MAZE_LEFT && pixel_x < MAZE_LEFT + MAZE_WIDTH*CELL_SIZE &&
                pixel_y >= MAZE_TOP && pixel_y < MAZE_TOP + MAZE_HEIGHT*CELL_SIZE) begin
                
                // Convert pixel position to grid position
                grid_x = (pixel_x - MAZE_LEFT) / CELL_SIZE;
                grid_y = (pixel_y - MAZE_TOP) / CELL_SIZE;
                
                // Add a small border around cells for better visibility
                if ((pixel_x - MAZE_LEFT) % CELL_SIZE == 0 || (pixel_y - MAZE_TOP) % CELL_SIZE == 0)
                    in_maze_wall = 1;
                else
                    in_maze_wall = maze[grid_y][grid_x];
            end
            else
                in_maze_wall = 0; // Outside maze boundary
        end
    endfunction
    
    // Set RGB output value based on pixel location
    always @* begin
        if (~bright)
            rgb = BLACK;
        else if (block_fill)
            rgb = BALL;
        else if (is_goal)
            rgb = BLUE;
        else if (is_wall)
            rgb = WALL;
        else if (x >= MAZE_LEFT && x < MAZE_LEFT + MAZE_WIDTH*CELL_SIZE &&
                 y >= MAZE_TOP && y < MAZE_TOP + MAZE_HEIGHT*CELL_SIZE)
            rgb = WHITE; // Maze paths
        else
            rgb = BACKGROUND;
    end
    
endmodule


/*
TODO list:
- Add a start and end point for the maze (functioning begin and end)
-Add a name and a cool title for the maze on the left side of the maze
-Add a start and end point for the maze

*/