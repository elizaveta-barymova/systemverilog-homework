//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module parallel_to_serial
# (
    parameter width = 8
)
(
    input                      clk,
    input                      rst,

    input                      parallel_valid,
    input        [width - 1:0] parallel_data,

    output                     busy,
    output logic               serial_valid,
    output logic               serial_data
);
    // Task:
    // Implement a module that converts multi-bit parallel value to the single-bit serial data.
    //
    // The module should accept 'width' bit input parallel data when 'parallel_valid' input is asserted.
    // At the same clock cycle as 'parallel_valid' is asserted, the module should output
    // the least significant bit of the input data. In the following clock cycles the module
    // should output all the remaining bits of the parallel_data.
    // Together with providing correct 'serial_data' value, module should also assert the 'serial_valid' output.
    //
    // Note:
    // Check the waveform diagram in the README for better understanding.

    logic [$clog2(width) - 1:0] counter;
    logic         [width - 1:0] shift_reg;
    logic                       processing;

    assign busy = processing;

    always_comb begin
        if (parallel_valid & ~processing) begin
            serial_valid = '1;
            serial_data  = parallel_data[0];
        end else begin
            if (processing) begin
                serial_valid = '1;
                serial_data  = shift_reg[0];
            end else begin
                serial_valid = '0;
                serial_data  = '0;
            end
        end
    end

    always_ff @ (posedge clk)
        if (rst) begin
            counter      <= '0;
            shift_reg    <= '0;
            processing   <= '0;
        end else begin
            if (parallel_valid & ~processing) begin
                shift_reg    <= parallel_data[width-1:1];
                counter      <= width - 2;
                processing   <= '1;
            end else if (processing) begin
                if (counter > 0) begin
                    shift_reg  <= shift_reg >> 1;
                    counter    <= counter - 1;
                end else 
                    processing <= '0;
            end
        end
    
endmodule
