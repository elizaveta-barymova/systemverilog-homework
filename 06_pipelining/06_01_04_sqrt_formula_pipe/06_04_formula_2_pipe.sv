//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_2_pipe
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
    // Implement a pipelined module formula_2_pipe that computes the result
    // of the formula defined in the file formula_2_fn.svh.
    //
    // The requirements:
    //
    // 1. The module formula_2_pipe has to be pipelined.
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

    localparam   depth = 16;
    localparam   width = 32;

    logic [15:0] sqrt_c;
    logic [15:0] sqrt_bc;
    logic [15:0] sqrt_abc;
    logic [31:0] sum_1;
    logic [31:0] sum_2;
    logic [31:0] reg_b;
    logic [31:0] reg_a;
    logic        vld_sqrt_c;
    logic        vld_sqrt_bc;
    logic        vld_sqrt_abc;
    logic        reg_vld_sqrt_c;
    logic        reg_vld_sqrt_bc;

    isqrt isqrt_1 (
        .clk  ( clk      ),
        .rst  ( rst      ),
        .x_vld( arg_vld  ),
        .x    ( c        ),
        .y_vld( vld_sqrt_c ),
        .y    ( sqrt_c   )
    ); 
 
    isqrt isqrt_2 ( 
        .clk  ( clk         ),
        .rst  ( rst         ),
        .x_vld( reg_vld_sqrt_c ),    
        .x    ( sum_1       ),
        .y_vld( vld_sqrt_bc ),
        .y    ( sqrt_bc     )
    ); 
 
    isqrt isqrt_3 ( 
        .clk  ( clk          ),
        .rst  ( rst          ),
        .x_vld( reg_vld_sqrt_bc ),     
        .x    ( sum_2        ),
        .y_vld( vld_sqrt_abc ),
        .y    ( sqrt_abc     )
    );

    shift_register_with_valid  
    # (
        .depth(depth),
        .width(width)
    )
    shift_reg_b (
        .clk     ( clk     ),
        .rst     ( rst     ),
        .in_vld  ( arg_vld ),
        .in_data ( b       ),
        .out_vld (         ),
        .out_data( reg_b   )
    );

    shift_register_with_valid
    # (
        .depth(2 * depth + 1),
        .width(width)
    )
    shift_reg_a (
        .clk     ( clk     ),
        .rst     ( rst     ),
        .in_vld  ( arg_vld ),
        .in_data ( a       ),
        .out_vld (         ),
        .out_data( reg_a   )
    );

    always_ff @(posedge clk) begin
        if (rst) begin
            sum_1           <= '0;
            sum_2           <= '0;
            reg_vld_sqrt_c  <= '0;
            reg_vld_sqrt_bc <= '0;
        end else begin
            if (vld_sqrt_c)
                sum_1 <= reg_b + {16'b0, sqrt_c };
            if (vld_sqrt_bc)
                sum_2 <= reg_a + {16'b0, sqrt_bc};
            reg_vld_sqrt_c  <= vld_sqrt_c;
            reg_vld_sqrt_bc <= vld_sqrt_bc;
        end
    end
    
    assign res_vld = vld_sqrt_abc;
    assign res     = sqrt_abc;

endmodule
