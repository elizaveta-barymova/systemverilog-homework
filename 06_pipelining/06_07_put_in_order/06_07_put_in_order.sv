module put_in_order
# (
    parameter width    = 16,
              n_inputs = 4
)
(
    input                       clk,
    input                       rst,

    input  [ n_inputs - 1 : 0 ] up_vlds,
    input  [ n_inputs - 1 : 0 ]
           [ width    - 1 : 0 ] up_data,

    output                      down_vld,
    output [ width   - 1 : 0 ]  down_data
);

    // Task:
    //
    // Implement a module that accepts many outputs of the computational blocks
    // and outputs them one by one in order. Input signals "up_vlds" and "up_data"
    // are coming from an array of non-pipelined computational blocks.
    // These external computational blocks have a variable latency.
    //
    // The order of incoming "up_vlds" is not determent, and the task is to
    // output "down_vld" and corresponding data in a round-robin manner,
    // one after another, in order.
    //
    // Comment:
    // The idea of the block is kinda similar to the "parallel_to_serial" block
    // from Homework 2, but here block should also preserve the output order.

    logic [$clog2(n_inputs) - 1:0] counter;

    logic [width - 1:0]    registers [n_inputs - 1:0];
    logic [n_inputs - 1:0] reg_vld;
         

    always_ff @(posedge clk) begin
        if (rst) begin
            counter <= '0;
            for (int i = 0; i < n_inputs; i++) begin
                registers[i] <=  '0;
            end
        end else begin
            // Запись данных
            for (int i = 0; i < n_inputs; i++) begin
                if (up_vlds[i]) begin
                    registers[i] <= up_data[i];
                    reg_vld[i]   <= 1'b1;
                end
            end

            // Чтение данных
            if (reg_vld[counter]) begin
                if (counter == n_inputs - 1)
                    counter <= '0;
                else 
                    counter <= counter + 1'b1;
            end
        end
    end

    // Регистр валидности данных
    always_ff @(posedge clk) begin
        if (rst) begin
            counter <= '0;
            for (int i = 0; i < n_inputs; i++) begin
                reg_vld[i]   <= 1'b0;
            end
        end else begin
            if (reg_vld[counter])
                reg_vld[counter] <= 1'b0;
        end
    end

    assign down_data = registers[counter];
    assign down_vld  = reg_vld[counter];
    
endmodule
