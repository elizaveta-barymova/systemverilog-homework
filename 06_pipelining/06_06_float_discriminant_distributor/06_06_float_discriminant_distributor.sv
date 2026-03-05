module float_discriminant_distributor (
    input                           clk,
    input                           rst,

    input                           arg_vld,
    input        [FLEN - 1:0]       a,
    input        [FLEN - 1:0]       b,
    input        [FLEN - 1:0]       c,

    output logic                    res_vld,
    output logic [FLEN - 1:0]       res,
    output logic                    res_negative,
    output logic                    err,

    output logic                    busy
);

    // Task:
    //
    // Implement a module that will calculate the discriminant based
    // on the triplet of input number a, b, c. The module must be pipelined.
    // It should be able to accept a new triple of arguments on each clock cycle
    // and also, after some time, provide the result on each clock cycle.
    // The idea of the task is similar to the task 04_11. The main difference is
    // in the underlying module 03_08 instead of formula modules.
    //
    // Note 1:
    // Reuse your file "03_08_float_discriminant.sv" from the Homework 03.
    //
    // Note 2:
    // Latency of the module "float_discriminant" should be clarified from the waveform.

    logic [$clog2(NE)-1:0] counter;

    logic [FLEN - 1:0] a_reg       [NE-1:0];
    logic [FLEN - 1:0] b_reg       [NE-1:0];
    logic [FLEN - 1:0] c_reg       [NE-1:0];
    logic              arg_vld_reg [NE-1:0];

    logic [FLEN - 1:0] discr       [NE-1:0];
    logic              discr_vld   [NE-1:0];
    logic              discr_neg   [NE-1:0];
    logic              err_array   [NE-1:0];
    logic              busy_array  [NE-1:0];

    logic [FLEN - 1:0] res_mux;
    logic              res_vld_mux;    
    logic              res_neg_mux;

    always_ff @(posedge clk) begin
        if (rst)
            counter <= '0;
        else begin
            if (counter == NE - 1) 
                counter <= '0;
            else if (arg_vld && ~busy_array[counter])
                counter <= counter + 1'b1;
        end
    end

    generate
        for (genvar i = 0; i < NE; i++) begin : calc
            always_ff @(posedge clk) begin
                if (rst) begin
                    a_reg[i]       <= '0;
                    b_reg[i]       <= '0;
                    c_reg[i]       <= '0;
                    arg_vld_reg[i] <= '0;
                end else begin
                    arg_vld_reg[i] <= '0;
                    
                    if (counter == i && arg_vld && ~busy_array[i]) begin
                        a_reg[i]       <= a;
                        b_reg[i]       <= b;
                        c_reg[i]       <= c;
                        arg_vld_reg[i] <= 1'b1;
                    end
                end
            end

            float_discriminant f_discr (
                .clk         ( clk            ),
                .rst         ( rst            ),
                .arg_vld     ( arg_vld_reg[i] ),
                .a           ( a_reg[i]       ),
                .b           ( b_reg[i]       ),
                .c           ( c_reg[i]       ),
                .res_vld     ( discr_vld[i]   ),
                .res         ( discr[i]       ),
                .res_negative( discr_neg[i]   ),
                .err         ( err_array[i]   ),
                .busy        ( busy_array[i]  )
            );
        end
    endgenerate

    always_comb begin
        res_mux     = '0;
        res_vld_mux = '0;
        for (int k = 0; k < NE; k++) begin
            if (discr_vld[k]) begin
                res_mux     = discr[k];
                res_vld_mux = '1;
                res_neg_mux = discr_neg[k];
            end
        end 
    end

    assign res          = res_mux;
    assign res_vld      = res_vld_mux;
    assign res_negative = res_neg_mux;
    assign busy         = busy_array[counter];

    always_comb begin
        err = 1'b0;
        for (int k = 0; k < NE; k++) begin
            err |= err_array[k];
        end
    end    
    
endmodule
