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

    parameter N = 50;

    logic [N - 1:0][FLEN - 1:0] a_r, b_r, c_r, y_r;
    logic [N - 1:0] up_vld, down_vld, sel, busy_r, err_r, y_neg;
    logic [FLEN - 1:0] res_r;
    logic res_neg, vld_r;

    assign res_vld = vld_r;
    assign res = res_r;
    assign res_negative = res_neg;
    assign err = | err_r;
    assign busy = & busy_r;

    always_ff @(posedge clk) begin          // Counter
        if (rst)
            sel <= 1;
        else if (arg_vld)
            sel <= {sel[N-2:0], sel[N-1]};
    end

    always_ff @(posedge clk) begin          // Registers
        if (rst) begin
            a_r    <= '0;
            b_r    <= '0;
            c_r    <= '0;
            up_vld <= '0;
        end
        else begin
            for (int i = 0; i < N; i ++) begin
                if (arg_vld && sel[i]) begin
                    a_r[i] <= a;
                    b_r[i] <= b;
                    c_r[i] <= c;
                    up_vld[i] <= '1;
                end
                else up_vld[i] <= '0;
            end
        end
    end    

    generate                                // Instances
        for (genvar i = 0; i < N; i ++) begin: gen2
            float_discriminant inst (
                .clk ( clk ),
                .rst ( rst ),
                .arg_vld ( up_vld[i] ),
                .a   ( a_r[i] ),
                .b   ( b_r[i] ),
                .c   ( c_r[i] ),
                .res_vld ( down_vld[i]),
                .res ( y_r[i] ),
                .res_negative (y_neg[i]),
                .err ( err_r[i] ),
                .busy ( busy_r[i] )
            );
        end    
    endgenerate

    always_ff @(posedge clk) begin          // Output logic
        vld_r <= | down_vld;
        for (int i = 0; i < N; i ++) begin
            if (down_vld[i]) begin
                res_r <= y_r[i];
                res_neg <= y_neg[i];
            end
        end
    end


endmodule
