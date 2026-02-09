//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module round_robin_arbiter_with_2_requests
(
    input        clk,
    input        rst,
    input  [1:0] requests,
    output [1:0] grants
);
    // Task:
    // Implement a "arbiter" module that accepts up to two requests
    // and grants one of them to operate in a round-robin manner.
    //
    // The module should maintain an internal register
    // to keep track of which requester is next in line for a grant.
    //
    // Note:
    // Check the waveform diagram in the README for better understanding.
    //
    // Example:
    // requests -> 01 00 10 11 11 00 11 00 11 11
    // grants   -> 01 00 10 01 10 00 01 00 10 01

    logic [1:0] prev_grants;
    logic [1:0] grants_intern;

    always_comb
    case (requests)
      2'b00: grants_intern = 'b00;
      2'b01: grants_intern = 'b01;
      2'b10: grants_intern = 'b10;
      2'b11: grants_intern = ~ prev_grants;
    endcase

    assign grants = grants_intern;

    always_ff @ (posedge clk)
        if (rst) 
            prev_grants <= 'b10;
        else begin
            if (requests == 'b11) 
                prev_grants <= grants_intern;
            else if (requests != 'b00) 
                prev_grants <= requests;
        end

endmodule
