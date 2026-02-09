//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_2_fsm
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
    // Implement a module that calculates the formula from the `formula_2_fn.svh` file
    // using only one instance of the isqrt module.
    //
    // Design the FSM to calculate answer step-by-step and provide the correct `res` value
    //
    // You can read the discussion of this problem
    // in the article by Yuri Panchul published in
    // FPGA-Systems Magazine :: FSM :: Issue ALFA (state_0)
    // You can download this issue from https://fpga-systems.ru/fsm

    logic [31:0] a_reg, b_reg;
    logic [31:0] intermediate_result;

    // FSM
    enum logic [1:0]
    {
        st_idle   = 2'b00,
        st_wait_1 = 2'b01,
        st_wait_2 = 2'b10,
        st_wait_3 = 2'b11
    }
    state, next_state;

    always_comb begin
        next_state = state;

        case (state)
        st_idle   : if ( arg_vld     ) next_state = st_wait_1;
        st_wait_1 : if ( isqrt_y_vld ) next_state = st_wait_2;
        st_wait_2 : if ( isqrt_y_vld ) next_state = st_wait_3;
        st_wait_3 : if ( isqrt_y_vld ) next_state = st_idle;
        endcase
    end

    always_ff @ (posedge clk)
        if (rst)
            state <= st_idle;
        else
            state <= next_state;

    // Save values
    always_ff @ (posedge clk)
        if (rst) begin
            a_reg <= '0;
            b_reg <= '0;
        end else if (state == st_idle & arg_vld) begin
            a_reg <= a;
            b_reg <= b;
        end

    always_ff @ (posedge clk)
        if (rst) begin
            intermediate_result <= '0;
        end else if (isqrt_y_vld) begin
            case (state)
            st_wait_1: intermediate_result <= b_reg + isqrt_y;
            st_wait_2: intermediate_result <= a_reg + isqrt_y;
            endcase
        end

    // Datapath
    always_comb begin
        isqrt_x_vld = '0;
        isqrt_x = 'x;

        case (state)
        st_idle: begin 
            isqrt_x_vld = arg_vld;
            isqrt_x = c;
        end

        st_wait_1 : begin
            isqrt_x_vld = isqrt_y_vld;
            intermediate_result = isqrt_y + b_reg;
            isqrt_x = intermediate_result;
        end

        st_wait_2 : begin
            isqrt_x_vld = isqrt_y_vld;
            intermediate_result = isqrt_y + a_reg;
            isqrt_x = intermediate_result;
        end
        endcase
    end

    // The result
    always_ff @ (posedge clk)
        if (rst) begin
            res_vld <= '0;
            res     <= '0;
        end else if (state == st_wait_3 & isqrt_y_vld) begin
            res_vld <= '1;
            res     <= isqrt_y;
        end else 
            res_vld <= '0;
endmodule
