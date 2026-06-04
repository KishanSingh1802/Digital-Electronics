`timescale 1ns / 1ps

module uart_rx (
    input clk,
    input rst,
    input rx_in,
    input tick,
    output reg [7:0] rx_data,
    output reg rx_ready
);
    localparam IDLE  = 2'b00,
               START = 2'b01,
               DATA  = 2'b10,
               STOP  = 2'b11;

    reg [1:0] state;
    reg [2:0] bit_index;
    reg [3:0] sample_counter; 
    reg [7:0] shift_reg;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            rx_ready <= 0;
            bit_index <= 0;
            sample_counter <= 0;
            rx_data <= 8'b0;
        end else if (tick) begin
            case (state)
                IDLE: begin
                    rx_ready <= 0;
                    if (rx_in == 1'b0) begin 
                        state <= START;
                        sample_counter <= 0;
                    end
                end
                START: begin
                    if (sample_counter == 7) begin // Sample at middle of bit
                        state <= DATA;
                        sample_counter <= 0;
                        bit_index <= 0;
                    end else sample_counter <= sample_counter + 1;
                end
                DATA: begin
                    if (sample_counter == 15) begin 
                        sample_counter <= 0;
                        shift_reg[bit_index] <= rx_in;
                        if (bit_index == 7) state <= STOP;
                        else bit_index <= bit_index + 1;
                    end else sample_counter <= sample_counter + 1;
                end
                STOP: begin
                    if (sample_counter == 15) begin
                        rx_data <= shift_reg;
                        rx_ready <= 1'b1;
                        state <= IDLE;
                    end else sample_counter <= sample_counter + 1;
                end
            endcase
        end
    end
endmodule
