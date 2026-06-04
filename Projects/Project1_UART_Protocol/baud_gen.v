`timescale 1ns / 1ps

module baud_gen (
    input clk,      // 50 MHz FPGA Clock
    input rst,      // Active High Reset
    output reg tick // Generates a single-cycle pulse at 9600 Baud rate
);
    reg [12:0] counter;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter <= 0;
            tick <= 0;
        end else if (counter == 5207) begin // 50,000,000 / 9600 = 5208 ticks
            counter <= 0;
            tick <= 1;
        end else begin
            counter <= counter + 1;
            tick <= 0;
        end
    end
endmodule
