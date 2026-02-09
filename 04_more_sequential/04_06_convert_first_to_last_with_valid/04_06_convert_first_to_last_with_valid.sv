//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module conv_first_to_last_no_ready
# (
    parameter width = 8
)
(
    input                clock,
    input                reset,

    input                up_valid,
    input                up_first,
    input  [width - 1:0] up_data,

    output               down_valid,
    output               down_last,
    output [width - 1:0] down_data
);
    // Task:
    // Implement a module that converts 'first' input status signal
    // to the 'last' output status signal.
    //
    // See README for full description of the task with timing diagram.

    logic [width - 1:0] data;
    logic               valid;

    assign down_data  = up_valid ? data  : '0;
    assign down_valid = up_valid ? valid : '0;
    assign down_last  = up_valid & up_first;
    
    always_ff @(posedge clock) begin
        if (reset) begin
            data  <=  'b0;
            valid <= 1'b0;
        end else begin
            if (up_valid) begin
                data <= up_data;
                valid <= up_valid;
            end
        end
    end
    
endmodule
