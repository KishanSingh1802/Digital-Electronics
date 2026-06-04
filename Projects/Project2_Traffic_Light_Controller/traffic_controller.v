`timescale 1ns / 1ps

module traffic_controller (
    input clk,               // System clock
    input rst,               // Synchronous active-high reset
    input emergency_trigger, // High overrides state for emergency vehicles on NS road
    output reg [2:0] ns_lights, // Outputs: [Red, Yellow, Green]
    output reg [2:0] ew_lights  // Outputs: [Red, Yellow, Green]
);

    // FSM State Encoding
    localparam NS_GREEN    = 3'b000,
               NS_YELLOW   = 3'b001,
               EW_GREEN    = 3'b010,
               EW_YELLOW   = 3'b011,
               EMERGENCY_NS = 3'b100;

    reg [2:0] current_state, next_state;
    reg [3:0] timer; 

    // State Transitions & Timer Logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            current_state <= NS_GREEN;
            timer <= 0;
        end else begin
            if (emergency_trigger && current_state != EMERGENCY_NS) begin
                if (current_state == EW_GREEN) begin
                    current_state <= EW_YELLOW; // Safely transition EW to yellow first
                    timer <= 0;
                end else begin
                    current_state <= EMERGENCY_NS;
                    timer <= 0;
                end
            end else if (timer >= 10) begin // Change state every 10 clock ticks
                current_state <= next_state;
                timer <= 0;
            end else begin
                timer <= timer + 1;
            end
        end
    end

    // FSM Combinational Next State Logic
    always @(*) begin
        next_state = current_state;
        case (current_state)
            NS_GREEN:  next_state = NS_YELLOW;
            NS_YELLOW: next_state = EW_GREEN;
            EW_GREEN:  next_state = EW_YELLOW;
            EW_YELLOW: next_state = NS_GREEN;
            EMERGENCY_NS: begin
                if (!emergency_trigger) next_state = NS_GREEN; 
                else next_state = EMERGENCY_NS;
            end
            default:   next_state = NS_GREEN;
        endcase
    end

    // Output Mapping (1'b1 turns individual lamp color ON)
    always @(*) begin
        case (current_state)
            NS_GREEN: begin
                ns_lights = 3'b001; // Green
                ew_lights = 3'b100; // Red
            end
            NS_YELLOW: begin
                ns_lights = 3'b010; // Yellow
                ew_lights = 3'b100; // Red
            end
            EW_GREEN: begin
                ns_lights = 3'b100; // Red
                ew_lights = 3'b001; // Green
            end
            EW_YELLOW: begin
                ns_lights = 3'b100; // Red
                ew_lights = 3'b010; // Yellow
            end
            EMERGENCY_NS: begin
                ns_lights = 3'b001; // Emergency lane gets Green
                ew_lights = 3'b100; // Block opposing lane with Red
            end
            default: begin
                ns_lights = 3'b100;
                ew_lights = 3'b100;
            end
        endcase
    end
endmodule
