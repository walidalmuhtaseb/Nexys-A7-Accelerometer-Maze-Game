//////////////////////////////////////////////////////////////////////////////////
// Engineer: Walid Al-Muhtaseb
// 
// Create Date: 15/4/2025 04:32:07 PM
// Design Name: Block Controller
// Module Name: block_controller
//////////////////////////////////////////////////////////////////////////////////

module block_controller(
    input clk,
    input bright,
    input rst,
    input up, input down, input left, input right,
    input [9:0] hCount, vCount,
    input [14:0] acl_data,
    output wire block_fill,
    output reg [9:0] xpos, ypos,
    output reg [11:0] background,
	output reg game_over // for game end
   );
    
    parameter RED = 12'h900;
    
    // Create a 10x10 pixel block for the player
    assign block_fill = vCount>=(ypos-9) && vCount<=(ypos+9) && hCount>=(xpos-9) && hCount<=(xpos+9);
    
    // Maze dimensions - must match with pixel_gen.v
    parameter MAZE_LEFT = 415;
    parameter MAZE_TOP = 33;
    parameter CELL_SIZE = 32;

	// Goal position 
	parameter GOAL_X = MAZE_LEFT + 8*CELL_SIZE + (CELL_SIZE/2);
	parameter GOAL_Y = MAZE_TOP + 13*CELL_SIZE + (CELL_SIZE/2);
    
    // Compact maze representation - identical to pixel_gen.v
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
    
    // Function to check if a position is in a wall
    function is_wall_at;
        input [9:0] check_x, check_y;
        integer grid_x, grid_y;
        reg [9:0] maze_row;
        begin
            // Convert position to grid coordinates
            grid_x = (check_x - MAZE_LEFT) / CELL_SIZE;
            grid_y = (check_y - MAZE_TOP) / CELL_SIZE;
            
            // Check if position is within valid grid range
            if (grid_x < 0 || grid_x > 9 || grid_y < 0 || grid_y > 14)
                is_wall_at = 1; // Outside maze bounds is a wall
            else begin
                // Select the correct row
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
                is_wall_at = maze_row[9-grid_x]; // Note: MSB is leftmost column
            end
        end
    endfunction
    
    // Temporary variables for next position
    reg [9:0] next_xpos, next_ypos;
    wire will_hit_wall;
    
    always@(posedge clk, posedge rst) 
    begin
        if(rst) begin 
            // Start position at grid (2,2) (the red circle in your design)
            xpos <= 382 + 9*CELL_SIZE + (CELL_SIZE/2); // 382 (left edge) + 9 cells + half cell width
            ypos <= 3 + 4*CELL_SIZE + (CELL_SIZE/2);  // 3 (top edge) + 4 cells + half cell height
			game_over <= 0;  // Initialize game_over to 0
        end
        else if (clk) begin
            // Calculate potential next position
            next_xpos = xpos;
            next_ypos = ypos;
            
            // Apply movement based on inputs
            if(right) begin
                if(acl_data[13:10] > 4'b0100)
                    next_xpos = xpos - 2;
                else
                    next_xpos = xpos - 1;
            end
            else if(left) begin
                if(acl_data[13:10] > 4'b1011)
                    next_xpos = xpos + 1;
                else
                    next_xpos = xpos + 2;
            end

            if(up) begin
                if(acl_data[8:5] > 4'b0100)
                    next_ypos = ypos - 2;
                else
                    next_ypos = ypos - 1;
            end
            else if(down) begin
                if(acl_data[8:5] > 4'b1100)
                    next_ypos = ypos + 1;
                else
                    next_ypos = ypos + 2;
            end
            
            // No movement for small accelerometer values
            if((acl_data[13:10] < 4'b0010) || (acl_data[13:10] > 4'b1110))
                next_xpos = xpos;
            if(acl_data[9:5] < 4'b0010)
                next_ypos = ypos;
            
            // Check for wall collision at new position
            if (!is_wall_at(next_xpos, next_ypos)) begin
                // Only update position if not hitting a wall
                xpos <= next_xpos;
                ypos <= next_ypos;

				if ((next_xpos >= GOAL_X - (CELL_SIZE/2)) && (next_xpos <= GOAL_X + (CELL_SIZE/2)) &&
					(next_ypos >= GOAL_Y - (CELL_SIZE/2)) && (next_ypos <= GOAL_Y + (CELL_SIZE/2))) begin
					game_over <= 1;  // Set game over to true
					end
            end
        end
    end
    
    // Background color
    always@(posedge clk, posedge rst) begin
        if(rst)
            background <= 12'hFED;
        else
            background <= 12'hFED;
    end
    
endmodule