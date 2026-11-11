`timescale 1ns/1ns
module screen_fsm(
    input wire clk, rst_n, frame_end, press_pulse,
    output wire [1:0] screen
);
    localparam [1:0] BARS=2'd0, MUST=2'd1, END_TEXT=2'd2;
    reg [1:0] state, next_state;
    reg pending;
    wire advance = frame_end && (pending || press_pulse);
    assign screen = state;
    always @* begin
        next_state = state;
        case (state)
            BARS:     if (advance) next_state = MUST;
            MUST:     if (advance) next_state = END_TEXT;
            END_TEXT: if (advance) next_state = BARS;
            default:  next_state = BARS;
        endcase
    end
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin state <= BARS; pending <= 0; end
        else begin
            state <= next_state;
            if (frame_end) pending <= 0;
            else if (press_pulse) pending <= 1;
        end
    end
endmodule
