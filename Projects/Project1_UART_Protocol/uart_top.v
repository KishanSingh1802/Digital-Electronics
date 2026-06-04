`timescale 1ns / 1ps

module uart_top (
    input clk,
    input rst,
    input tx_start,
    input [7:0] tx_data,
    input rx_in,
    output tx_out,
    output [7:0] rx_data,
    output rx_ready,
    output tx_done
);

    wire tick; // Internal wire connecting baud generator tick to TX and RX

    // 1. Instantiate Baud Rate Generator
    baud_gen bg_inst (
        .clk(clk),
        .rst(rst),
        .tick(tick)
    );

    // 2. Instantiate UART Transmitter
    uart_tx tx_inst (
        .clk(clk),
        .rst(rst),
        .tx_start(tx_start),
        .tick(tick),
        .tx_data(tx_data),
        .tx_out(tx_out),
        .tx_done(tx_done)
    );

    // 3. Instantiate UART Receiver
    uart_rx rx_inst (
        .clk(clk),
        .rst(rst),
        .rx_in(rx_in),
        .tick(tick),
        .rx_data(rx_data),
        .rx_ready(rx_ready)
    );

endmodule
