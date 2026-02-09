//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module double_tokens
(
    input        clk,
    input        rst,
    input        a,
    output       b,
    output logic overflow
);
    // Task:
    // Implement a serial module that doubles each incoming token '1' two times.
    // The module should handle doubling for at least 200 tokens '1' arriving in a row.
    //
    // In case module detects more than 200 sequential tokens '1', it should assert
    // an overflow error. The overflow error should be sticky. Once the error is on,
    // the only way to clear it is by using the "rst" reset signal.
    //
    // Note:
    // Check the waveform diagram in the README for better understanding.
    //
    // Example:
    // a -> 10010011000110100001100100
    // b -> 11011011110111111001111110

    logic [7:0] counter;
    logic [7:0] seq_counter;
    
    assign b = a || (counter > 0);

    always_ff @(posedge clk) begin
        if (rst) begin
            seq_counter <= 8'b0;
            counter     <= 8'b0;
            overflow    <= 1'b0;
        end
        else begin
            if (a) begin
                    seq_counter <= seq_counter + 1;
                if (counter < 255)
                    counter <= counter + 1;
            end else begin
                seq_counter <= 1'b0;
                if (counter > 0) 
                    counter <= counter - 1;
            end

            if (seq_counter > 200)
                overflow <= 1'b1;
        end
    end
endmodule
