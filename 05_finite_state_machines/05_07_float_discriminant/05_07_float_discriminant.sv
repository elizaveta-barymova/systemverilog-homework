//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module float_discriminant (
    input                     clk,
    input                     rst,

    input                     arg_vld,
    input        [FLEN - 1:0] a,
    input        [FLEN - 1:0] b,
    input        [FLEN - 1:0] c,

    output logic              res_vld,
    output logic [FLEN - 1:0] res,
    output logic              res_negative,
    output logic              err,

    output logic              busy
);

    // Task:
    // Implement a module that accepts three Floating-Point numbers and outputs their discriminant.
    // The resulting value res should be calculated as a discriminant of the quadratic polynomial.
    // That is, res = b^2 - 4ac == b*b - 4*a*c
    //
    // Note:
    // If any argument is not a valid number, that is NaN or Inf, the "err" flag should be set.
    //
    // The FLEN parameter is defined in the "import/preprocessed/cvw/config-shared.vh" file
    // and usually equal to the bit width of the double-precision floating-point number, FP64, 64 bits.
    localparam [FLEN - 1:0] four = 64'h4010_0000_0000_0000;

    // Промежуточные значения
    wire [FLEN - 1:0] mul_1_res, mul_2_res, sub_res;
    wire mul_1_vld, mul_2_vld, sub_vld;
    wire err_mul1, err_mul2, err_sub;
    
    // Регистры
    logic [FLEN - 1:0] mul_1_reg, mul_2_reg;
    logic [FLEN - 1:0] arg_1, arg_2;
    logic arg_mul_vld, up_sub_vld;
    logic mul_1_vld_reg, mul_2_vld_reg, sub_vld_reg;

    // FSM
    enum logic [1:0]
    {
        st_idle = 2'b00,
        st_mul1 = 2'b01,
        st_mul2 = 2'b10,
        st_sub  = 2'b11
    }
    state, next_state;

    always_comb begin
        next_state = state;

        case (state)
            st_idle : if ( arg_vld       ) next_state = st_mul1;
            st_mul1 : if ( mul_2_vld_reg ) next_state = st_mul2;
            st_mul2 : if ( mul_2_vld_reg ) next_state = st_sub;
            st_sub  : if ( sub_vld_reg   ) next_state = st_idle;
            default :                      next_state = st_idle;
        endcase
    end

    always_ff @ (posedge clk)
        if (rst)
            state <= st_idle;
        else
            state <= next_state;

    // Управление 2-м умножителем
    always_comb begin
        arg_1       = '0;
        arg_2       = '0;
        arg_mul_vld = '0;
        if (state == st_idle && arg_vld) begin
            arg_1       = a;
            arg_2       = c;
            arg_mul_vld = arg_vld;
        end else if (state == st_mul1) begin
            arg_1       = four;
            arg_2       = mul_2_reg;
            arg_mul_vld = mul_2_vld_reg;
        end else
            arg_mul_vld = '0;
    end

    // Управление вычитанием
    always_comb begin
        up_sub_vld = 1'b0;
        if (state == st_mul2 && mul_2_vld_reg)
            up_sub_vld = 1'b1;
    end

    // Сохранение промежуточных значений в регисты
    always_ff @(posedge clk) begin
        if (rst) begin
            mul_1_reg     <= '0;
            mul_2_reg     <= '0;
            mul_1_vld_reg <= '0;
            mul_2_vld_reg <= '0;
            sub_vld_reg   <= '0;
        end else
            if (mul_1_vld && (state == st_mul1 || state == st_mul2))
                mul_1_reg <= mul_1_res;
            if (mul_2_vld)
                mul_2_reg <= mul_2_res;

            mul_2_vld_reg <= mul_2_vld;
            sub_vld_reg   <= sub_vld;
    end

    // Отрицательный дискриминант
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            res_negative <= 1'b0;
        else if (sub_vld && sub_res[FLEN-1])
            res_negative <= 1'b1;
        else 
            res_negative <= 1'b0;
    end

    // Выходные сигналы
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            res_vld <= '0;
            res     <= '0;
        end else begin
            if (sub_vld) begin
                res_vld <= '1;
                res     <= sub_res;
            end else begin
                res_vld <= '0;
            end
        end
    end

    // Errors
    assign err = err_mul1 | err_mul2 | err_sub;

    // Busy 
    assign busy = (state != st_idle);

    f_mult mul_1(
        .clk       ( clk       ),
        .rst       ( rst       ),
        .a         ( b         ),
        .b         ( b         ),
        .up_valid  ( arg_vld   ),
        .res       ( mul_1_res ),
        .down_valid( mul_1_vld ),
        .busy      (           ),
        .error     ( err_mul1  )
    );

    f_mult mul_2(
        .clk       ( clk         ),
        .rst       ( rst         ),
        .a         ( arg_1       ),
        .b         ( arg_2       ),
        .up_valid  ( arg_mul_vld ),
        .res       ( mul_2_res   ),
        .down_valid( mul_2_vld   ),
        .busy      (             ),
        .error     ( err_mul2    )
    );

    f_sub sub(
        .clk       ( clk        ),
        .rst       ( rst        ),
        .a         ( mul_1_reg  ),
        .b         ( mul_2_reg  ),
        .up_valid  ( up_sub_vld ),
        .res       ( sub_res    ),
        .down_valid( sub_vld    ),
        .busy      (            ),
        .error     ( err_sub    )
    );

endmodule
