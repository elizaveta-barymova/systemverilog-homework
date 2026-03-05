//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_1_pipe_aware_fsm
(
    input               clk,
    input               rst,

    input               arg_vld,
    input        [31:0] a,
    input        [31:0] b,
    input        [31:0] c,

    output logic        res_vld,
    output logic [31:0] res,

    // isqrt interface

    output logic        isqrt_x_vld,
    output logic [31:0] isqrt_x,

    input               isqrt_y_vld,
    input        [15:0] isqrt_y
);

    // Task:
    //
    // Implement a module formula_1_pipe_aware_fsm
    // with a Finite State Machine (FSM)
    // that drives the inputs and consumes the outputs
    // of a single pipelined module isqrt.
    //
    // The formula_1_pipe_aware_fsm module is supposed to be instantiated
    // inside the module formula_1_pipe_aware_fsm_top,
    // together with a single instance of isqrt.
    //
    // The resulting structure has to compute the formula
    // defined in the file formula_1_fn.svh.
    //
    // The formula_1_pipe_aware_fsm module
    // should NOT create any instances of isqrt module,
    // it should only use the input and output ports connecting
    // to the instance of isqrt at higher level of the instance hierarchy.
    //
    // All the datapath computations except the square root calculation,
    // should be implemented inside formula_1_pipe_aware_fsm module.
    // So this module is not a state machine only, it is a combination
    // of an FSM with a datapath for additions and the intermediate data
    // registers.
    //
    // Note that the module formula_1_pipe_aware_fsm is NOT pipelined itself.
    // It should be able to accept new arguments a, b and c
    // arriving at every N+3 clock cycles.
    //
    // In order to achieve this latency the FSM is supposed to use the fact
    // that isqrt is a pipelined module.
    //
    // For more details, see the discussion of this problem
    // in the article by Yuri Panchul published in
    // FPGA-Systems Magazine :: FSM :: Issue ALFA (state_0)
    // You can download this issue from https://fpga-systems.ru/fsm#state_0

    logic [31:0] a_reg, b_reg, c_reg;
    logic [31:0] pre_res;

    // FSM for isqrt inputs
    enum logic [1:0]
    {
        st_x_idle   = 2'b00,
        st_x_1      = 2'b01,
        st_x_2      = 2'b10,
        st_x_3      = 2'b11
    }
    state;

    always_ff @ (posedge clk)
    if (rst)
        state <= st_x_idle;
    else
        case (state)
        st_x_idle : if ( arg_vld ) state <= st_x_1;
        st_x_1    :                state <= st_x_2;
        st_x_2    :                state <= st_x_3;
        st_x_3    :                state <= st_x_idle;
        endcase

    // Save values
    always_ff @ (posedge clk)
        if (rst) begin
            a_reg <= '0;
            b_reg <= '0;
            c_reg <= '0;
        end else if (state == st_x_idle && arg_vld) begin
            a_reg <= a;
            b_reg <= b;
            c_reg <= c;
        end

    // Datapath
    always_comb begin
        isqrt_x_vld = '0;
        isqrt_x = 'x;

        case (state)
        st_x_idle: begin 
            isqrt_x_vld = arg_vld;
            isqrt_x     = a;
        end

        st_x_1 : begin
            isqrt_x_vld = '1;
            isqrt_x     = b_reg;
        end

        st_x_2 : begin
            isqrt_x_vld = '1;
            isqrt_x     = c_reg;
        end
        endcase
    end

    // FSM for isqrt outputs
    enum logic [1:0]
    {
        st_wait_idle = 2'b00,
        st_wait_1    = 2'b01,
        st_wait_2    = 2'b10,
        st_wait_3    = 2'b11
    }
    state_y, next_state;

    always_comb begin
        next_state = state_y;

        case (state_y)
        st_wait_idle : if ( arg_vld     ) next_state = st_wait_1;
        st_wait_1    : if ( isqrt_y_vld ) next_state = st_wait_2;
        st_wait_2    : if ( isqrt_y_vld ) next_state = st_wait_3;
        st_wait_3    : if ( isqrt_y_vld ) next_state = st_wait_idle;
        endcase
    end

    always_ff @ (posedge clk)
        if (rst)
            state_y <= st_wait_idle;
        else
            state_y <= next_state;

    // Result
    always_ff @ (posedge clk)
        if (rst) begin
            res     <= '0;
            res_vld <= '0;
        end else begin
            if (state_y == st_wait_idle)
                res <= '0;
            else if (isqrt_y_vld)
                res <= res + {16'b0, isqrt_y};

            if (state_y == st_wait_3 & isqrt_y_vld) 
                res_vld <= '1;
            else
                res_vld <= '0;
        end

endmodule
