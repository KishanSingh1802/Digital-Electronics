`timescale 1ns / 1ps

module tb_traffic_controller();
    reg clk;
    reg rst;
    reg emergency_trigger;
    
    wire [2:0] ns_lights;
    wire [2:0] ew_lights;

    // Instantiate the Unit Under Test (UUT)
    traffic_controller uut (
        .clk(clk),
        .rst(rst),
        .emergency_trigger(emergency_trigger),
        .ns_lights(ns_lights),
        .ew_lights(ew_lights)
    );

    // Clock Generation (100 MHz -> 10ns period)
    always #5 clk = ~clk;

    initial begin
        // Initialize Inputs
        clk = 0;
        rst = 1;
        emergency_trigger = 0;

        // Release Reset
        #50;
        rst = 0;

        // Let the traffic lights run normally through standard cycles
        #400;

        // Trigger the Emergency Override
        emergency_trigger = 1;
        #200;

        // Clear the emergency override
        emergency_trigger = 0;
        #300;

        $finish;
    end
endmodule
