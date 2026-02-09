//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module gearbox_1_to_2
# (
    parameter width = 0
)
(
    input                    clk,
    input                    rst,

    input                    up_vld,    // upstream
    input  [    width - 1:0] up_data,

    output                   down_vld,  // downstream
    output [2 * width - 1:0] down_data
);
    // Task:
    // Implement a module that transforms a stream of data
    // from 'width' to the 2*'width' data width.
    //
    // The module should be capable to accept new data at each
    // clock cycle and produce concatenated 'down_data'
    // at each second clock cycle.
    //
    // The module should work properly with reset 'rst'
    // and valid 'vld' signals

    logic [width - 1:0] first_part;
    logic buf_full;

    assign down_data = (buf_full == 1) ? {first_part, up_data} : 'b0;
    assign down_vld  = buf_full & up_vld;
        
    always_ff @ (posedge clk) begin
        if (rst) begin
            first_part <=  'b0;
            buf_full   <= 1'b0;
        end else begin
            if (up_vld) begin
                if (!buf_full) begin
                    first_part <= up_data;
                    buf_full   <= 1'b1;
                end else
                    buf_full   <= 1'b0;
            end 
        end
    end
endmodule
