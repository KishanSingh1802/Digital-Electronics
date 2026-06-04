`timescale 1ns / 1ps

module tb_uart();
    reg clk;
    reg rst;
    reg tx_start;
    reg [7:0] tx_data;
    reg rx_in;
    
    wire tx_out;
    wire [7:0] rx_data;
    wire rx_ready;
    wire tx_done;

    // Connect our clean Top-Level Module wrapper
    uart_top uut (
        .clk(clk),
        .rst(rst),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .rx_in(rx_in),
        .tx_out(tx_out),
        .rx_data(rx_data),
        .rx_ready(rx_ready),
        .tx_done(tx_done)
    );

    // Generate a 50 MHz Clock signal (20ns clock cycle period)
    always #10 clk = ~clk;

    initial begin
        // Initialize all input signals
        clk = 0;
        rst = 1;
        tx_start = 0;
        tx_data = 8'h00;
        rx_in = 1'b1; // The UART serial line idles at a logic high (1)

        // Hold reset for 100ns, then release it
        #100;
        rst = 0; 
        #40;

        // --- START TRANSMISSION ---
        // Let's send the data byte 8'hA5 (Binary: 10100101)
        tx_data = 8'hA5;
        tx_start = 1; // Pulse the transmission start line
        #20;
        tx_start = 0;

        // Loopback Link: Direct physical wire from TX output back into RX input
        forever begin
            #1 rx_in = tx_out;
        end
    end

    // Monitor the receiver to see if it successfully captures the transmitted byte
    initial begin
        wait(rx_ready == 1'b1);
        #100;
        $display("SUCCESS: Data byte received perfectly over loopback wire!");
        $finish;
    end
endmodule
