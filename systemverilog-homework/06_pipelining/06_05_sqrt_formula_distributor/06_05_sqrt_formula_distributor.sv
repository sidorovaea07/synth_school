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

    parameter N = 50;

    logic [N - 1:0][31:0] a_r, b_r, c_r, y_r;
    logic [N - 1:0]    up_vld, down_vld, sel;
    logic [31:0]                       res_r;
    logic                              vld_r;

    assign res_vld = vld_r;;
    assign res     = res_r;

    always_ff @(posedge clk) begin          // Counter
        if (rst)
            sel <= 1'b1;
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
                    a_r[i]    <=  a;
                    b_r[i]    <=  b;
                    c_r[i]    <=  c;
                    up_vld[i] <= '1;
                end
                else 
                    up_vld[i] <= '0;
            end
        end
    end    

    generate                                // Instances
        for (genvar i = 0; i < N; i ++) begin: gen2
            if (formula == 2)
                formula_2_top inst1 (
                    .clk ( clk ),
                    .rst ( rst ),
                    .arg_vld ( up_vld[i] ),
                    .a   ( a_r[i] ),
                    .b   ( b_r[i] ),
                    .c   ( c_r[i] ),
                    .res_vld ( down_vld[i] ),
                    .res ( y_r[i] )
                );
            else if (impl == 1)
                formula_1_impl_1_top inst2 (
                    .clk ( clk ),
                    .rst ( rst ),
                    .arg_vld ( up_vld[i] ),
                    .a   ( a_r[i] ),
                    .b   ( b_r[i] ),
                    .c   ( c_r[i] ),
                    .res_vld ( down_vld[i] ),
                    .res ( y_r[i] )
                );
            else
                formula_1_impl_2_top inst3 (
                    .clk ( clk ),
                    .rst ( rst ),
                    .arg_vld ( up_vld[i] ),
                    .a   ( a_r[i] ),
                    .b   ( b_r[i] ),
                    .c   ( c_r[i] ),
                    .res_vld ( down_vld[i] ),
                    .res ( y_r[i] )
                );       
        end    
    endgenerate

    always_ff @(posedge clk) begin          // Output logic
        vld_r <= | down_vld;        
        for (int i = 0; i < N; i ++) begin
            if (down_vld[i])
                res_r <= y_r[i];
        end
    end

endmodule
