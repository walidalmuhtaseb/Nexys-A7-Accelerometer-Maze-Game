# Nexys-A7-Maze-Game

Nexys A7 Accelerometer Maze Game
Overview
This project implements an interactive maze game for the Nexys A7 FPGA board, utilizing the onboard accelerometer to control player movement. The player navigates through a maze displayed on a VGA monitor by tilting the board in different directions. The goal is to reach the purple exit square.

Hardware Requirements:
Nexys A7 FPGA board
VGA monitor
FPGA programming cable


Features:
Accelerometer-based movement control
VGA display output (640x480)
Maze with collision detection
Victory detection and special victory display
Player position shown on 7-segment display
LED debugging output for accelerometer values


Game Mechanics:
Tilt the board to move the player (red block) through the maze
Navigate around walls (gray blocks)
Reach the purple goal block to win
After winning, the maze will transform to display a "GO SC" pattern in USC Cardinal and Gold colors


Module Structure:
merged_top.v: Main module that connects all submodules
block_controller.v: Handles player movement, collision detection, and game state
pixel_gen.v: Generates pixel colors for the VGA display
display_controller.v: Handles VGA timing signals
spi_master.v: Communicates with the accelerometer via SPI
iclk_gen.v: Generates the 4MHz clock for SPI communication
seg7_control.v: Controls the 7-segment display
sprite_rom.v: Stores image data for the game graphics


Implementation Details:
The accelerometer data is processed to control the player's movement
Collision detection prevents the player from moving through walls
A victory condition is triggered when the player reaches the goal
The VGA display shows the game state in real-time
The 7-segment display shows the current accelerometer readings


Controls:
Reset Button (BtnC): Resets the game to the starting position
Tilt Forward: Move player up
Tilt Backward: Move player down
Tilt Left: Move player left
Tilt Right: Move player right


Color Scheme
The game uses the following colors:
Walls: Gray (12'h666)
Player: Red (12'hF44)
Goal: Purple (12'hC0F)
Background: Dark Gray (12'h333)
Victory Colors: USC Cardinal (12'h900) and USC Gold (12'hFC3)


Installation and Setup:
Clone the repository
Open the project in Vivado
Generate the bitstream
Program the FPGA board
Connect the VGA monitor
Reset the game with BtnC
Enjoy the game!

Author:
Walid Al-Muhtaseb
Sprite Creator:
Roman Mejia
Creation Date: 4,20,2025
