`timescale 1ns / 1ps

module uart_tx (
    input clk,
    input rst,
    input tx_start,
    input tick,
    input [7:0] tx_data,
    output reg tx_out,
    output reg tx_done
);
    // State Encoding
    localparam IDLE  = 2'b00,
               START = 2'b01,
               DATA  = 2'b10,
               STOP  = 2'b11;

    reg [1:0] state, next_state;
    reg [2:0] bit_index;
    reg [7:0] data_reg;

    // FSM State Transition
    always @(posedge clk or posedge rst) begin
        if (rst) state <= IDLE;
        else if (tick) state <= next_state;
    end

    // Next State Logic
    always @(*) begin
        next_state = state;
        tx_out = 1'b1;
        tx_done = 1'b0;

        case (state)
            IDLE: begin
                tx_out = 1'b1;
                if (tx_start) next_state = START;
            end
            START: begin
                tx_out = 1'b0; // Start bit is logic low
                next_state = DATA;
            end
            DATA: begin
                tx_out = data_reg[bit_index];
                if (bit_index == 7) next_state = STOP;
            end
            STOP: begin
                tx_out = 1'b1; // Stop bit is logic high
                tx_done = 1'b1;
                next_state = IDLE;
            end
        endcase
    end

    // Internal Data Register
    always @(posedge clk) begin
        if (tick) begin
            if (state == IDLE && tx_start) data_reg <= tx_data;
            if (state == DATA) bit_index <= bit_index + 1;
            else if (state == IDLE) bit_index <= 0;
        end
    end
endmodule
