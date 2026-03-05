module sqrt_formula_distributor
# (
    parameter formula = 1,
              impl    = 1
)
(
    input         clk,
    input         rst,

    input         arg_vld,
    input  [31:0] a,
    input  [31:0] b,
    input  [31:0] c,

    output        res_vld,
    output [31:0] res
);

    // Task:
    //
    // Implement a module that will calculate formula 1 or formula 2
    // based on the parameter values. The module must be pipelined.
    // It should be able to accept new triple of arguments a, b, c arriving
    // at every clock cycle.
    //
    // The idea of the task is to implement hardware task distributor,
    // that will accept triplet of the arguments and assign the task
    // of the calculation formula 1 or formula 2 with these arguments
    // to the free FSM-based internal module.
    //
    // The first step to solve the task is to fill 03_04 and 03_05 files.
    //
    // Note 1:
    // Latency of the module "formula_1_isqrt" should be clarified from the corresponding waveform
    // or simply assumed to be equal 50 clock cycles.
    //
    // Note 2:
    // The task assumes idealized distributor (with 50 internal computational blocks),
    // because in practice engineers rarely use more than 10 modules at ones.
    // Usually people use 3-5 blocks and utilize stall in case of high load.
    //
    // Hint:
    // Instantiate sufficient number of "formula_1_impl_1_top", "formula_1_impl_2_top",
    // or "formula_2_top" modules to achieve desired performance.

    localparam N_f1_i1 = 14;
    localparam N_f1_i2 = 34;
    localparam N_f2    = 50;
    localparam N = (formula == 1 && impl == 1) ? N_f1_i1 :
                   (formula == 1 && impl == 2) ? N_f1_i2 :
                   (formula == 2)              ? N_f2    : 0;

    logic [$clog2(N)-1:0] counter;

    logic [31:0] a_reg       [N-1:0];
    logic [31:0] b_reg       [N-1:0];
    logic [31:0] c_reg       [N-1:0];
    logic        arg_vld_reg [N-1:0];

    logic [31:0] isqrt_y     [N-1:0];
    logic        isqrt_y_vld [N-1:0];

    logic [31:0] res_mux;
    logic        res_vld_mux;

    always_ff @(posedge clk) begin
        if (rst)
            counter <= '0;
        else begin
            if (counter == N - 1) 
                counter <= '0;
            else if (arg_vld)
                counter <= counter + 1'b1;
        end
    end

    generate
        for (genvar i = 0; i < N; i++) begin : calc
            always_ff @(posedge clk) begin
                if (rst) begin
                    a_reg[i]       <= '0;
                    b_reg[i]       <= '0;
                    c_reg[i]       <= '0;
                    arg_vld_reg[i] <= '0;
                end else begin
                    arg_vld_reg[i] <= '0;
                    
                    if (counter == i && arg_vld) begin
                        a_reg[i]       <= a;
                        b_reg[i]       <= b;
                        c_reg[i]       <= c;
                        arg_vld_reg[i] <= 1'b1;
                    end
                end
            end

            if (formula == 1 && impl == 1) begin
                formula_1_impl_1_top u_calc (
                        .clk    ( clk            ),
                        .rst    ( rst            ),
                        .arg_vld( arg_vld_reg[i] ),
                        .a      ( a_reg[i]       ),
                        .b      ( b_reg[i]       ),
                        .c      ( c_reg[i]       ),
                        .res_vld( isqrt_y_vld[i] ),
                        .res    ( isqrt_y[i]     )
                );
            end else if (formula == 1 && impl == 2) begin
                formula_1_impl_2_top u_calc (
                        .clk    ( clk            ),
                        .rst    ( rst            ),
                        .arg_vld( arg_vld_reg[i] ),
                        .a      ( a_reg[i]       ),
                        .b      ( b_reg[i]       ),
                        .c      ( c_reg[i]       ),
                        .res_vld( isqrt_y_vld[i] ),
                        .res    ( isqrt_y[i]     )
                );
            end else begin
                formula_2_top u_calc (
                        .clk    ( clk            ),
                        .rst    ( rst            ),
                        .arg_vld( arg_vld_reg[i] ),
                        .a      ( a_reg[i]       ),
                        .b      ( b_reg[i]       ),
                        .c      ( c_reg[i]       ),
                        .res_vld( isqrt_y_vld[i] ),
                        .res    ( isqrt_y[i]     )
                );
            end
        end
    endgenerate

    always_comb begin
        res_mux     = '0;
        res_vld_mux = '0;
        for (int k = 0; k < N; k++) begin
            if (isqrt_y_vld[k]) begin
                res_mux     = isqrt_y[k];
                res_vld_mux = '1;
            end
        end 
    end

    assign res     = res_mux;
    assign res_vld = res_vld_mux;

endmodule
