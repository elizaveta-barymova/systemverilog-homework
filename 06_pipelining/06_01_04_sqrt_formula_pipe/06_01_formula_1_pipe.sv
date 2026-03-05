//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_1_pipe
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
    // Implement a pipelined module formula_1_pipe that computes the result
    // of the formula defined in the file formula_1_fn.svh.
    //
    // The requirements:
    //
    // 1. The module formula_1_pipe has to be pipelined.
    //
    // It should be able to accept a new set of arguments a, b and c
    // arriving at every clock cycle.
    //
    // It also should be able to produce a new result every clock cycle
    // with a fixed latency after accepting the arguments.
    //
    // 2. Your solution should instantiate exactly 3 instances
    // of a pipelined isqrt module, which computes the integer square root.
    //
    // 3. Your solution should save dynamic power by properly connecting
    // the valid bits.
    //
    // You can read the discussion of this problem
    // in the article by Yuri Panchul published in
    // FPGA-Systems Magazine :: FSM :: Issue ALFA (state_0)
    // You can download this issue from https://fpga-systems.ru/fsm#state_0

    logic [15:0] sqrt_a, sqrt_b, sqrt_c;
    logic [31:0] sum_reg;
    
    logic vld_a;
    logic vld_reg;

    isqrt isqrt_1 (
        .clk  ( clk     ),
        .rst  ( rst     ),
        .x_vld( arg_vld ),
        .x    ( a       ),
        .y_vld( vld_a   ),
        .y    ( sqrt_a  )
    );

    isqrt isqrt_2 (
        .clk  ( clk     ),
        .rst  ( rst     ),
        .x_vld( arg_vld ),
        .x    ( b       ),
        .y_vld(         ),
        .y    ( sqrt_b  )
    );

    isqrt isqrt_3 (
        .clk  ( clk     ),
        .rst  ( rst     ),
        .x_vld( arg_vld ),
        .x    ( c       ),
        .y_vld(         ),
        .y    ( sqrt_c  )
    );

    always_ff @ (posedge clk or posedge rst)
    if (rst) begin
        vld_reg <= '0;
        sum_reg <= '0;
    end
    else begin
        vld_reg <= vld_a;
        if (vld_a)
            sum_reg <= {16'b0, sqrt_a} + {16'b0, sqrt_b} + {16'b0, sqrt_c};
    end

    assign res     = sum_reg;
    assign res_vld = vld_reg;

    // Второй вариант реализации - учитываются сигналы валидности от всех isqrt
    
    // assign res     = sum_reg;
    // assign res_vld = vld_reg;

    // logic [15:0] sqrt_a, sqrt_b, sqrt_c;
    // logic [31:0] sum_reg;
    
    // logic vld_a, vld_b, vld_c;
    // logic all_vld;
    // logic vld_reg;


    // isqrt isqrt_1 (
    //     .clk(      clk),
    //     .rst(      rst),
    //     .x_vld(arg_vld),
    //     .x(          a),
    //     .y_vld(  vld_a),
    //     .y(     sqrt_a)
    // );

    // isqrt isqrt_2 (
    //     .clk(      clk),
    //     .rst(      rst),
    //     .x_vld(arg_vld),
    //     .x(          b),
    //     .y_vld(  vld_b),
    //     .y(     sqrt_b)
    // );

    // isqrt isqrt_3 (
    //     .clk(      clk),
    //     .rst(      rst),
    //     .x_vld(arg_vld),
    //     .x(          c),
    //     .y_vld(  vld_c),
    //     .y(     sqrt_c)
    // );

    // assign all_vld = vld_a & vld_b & vld_c;

    // always_ff @ (posedge clk or posedge rst)
    // if (rst) begin
    //     vld_reg <= '0;
    //     sum_reg <= '0;
    // end
    // else begin
    //     vld_reg <= all_vld;
    //     if (all_vld)
    //         sum_reg <= {16'b0, sqrt_a} + {16'b0, sqrt_b} + {16'b0, sqrt_c};
    // end

    // assign res     = sum_reg;
    // assign res_vld = vld_reg;

endmodule
