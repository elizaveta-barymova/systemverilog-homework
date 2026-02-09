//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module conv_last_to_first
# (
    parameter width = 8
)
(
    input                clock,
    input                reset,

    input                up_valid,
    input                up_last,
    input  [width - 1:0] up_data,

    output               down_valid,
    output               down_first,
    output [width - 1:0] down_data
);
    // Task:
    // Implement a module that converts 'last' input status signal
    // to the 'first' output status signal.
    //
    // See README for full description of the task with timing diagram.

    logic next_package_first;

    assign down_data  = up_data;
    assign down_valid = up_valid;
    assign down_first = next_package_first & up_valid;
    
    always_ff @(posedge clock) begin
        if (reset)
            next_package_first <= 1'b1;
        else 
            if (next_package_first & up_valid)
                next_package_first <= 1'b0;
            if (up_last) 
                next_package_first <= 1'b1;
    end
endmodule
