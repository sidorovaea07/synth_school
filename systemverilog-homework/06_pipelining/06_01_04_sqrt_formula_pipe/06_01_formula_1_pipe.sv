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
    // You can download this issue from https://fpga-systems.org/fsm#state_0

    logic res_vld_r, res_vld_final;
    logic [2:0][15:0] y_r;
    logic [31:0] res_r;

    assign res = res_r;
    assign res_vld = res_vld_final;
    
    isqrt a_calc (
        .clk (clk),
        .rst (rst),
        .x_vld (arg_vld),
        .x   ( a ),
        .y_vld (res_vld_r),
        .y   (y_r[0])
    );

    isqrt b_calc (
        .clk (clk),
        .rst (rst),
        .x_vld (arg_vld),
        .x   ( b ),
        .y_vld (),
        .y   (y_r[1])
    );

    isqrt c_calc (
        .clk (clk),
        .rst (rst),
        .x_vld (arg_vld),
        .x   ( c ),
        .y_vld (),
        .y   (y_r[2])
    );

    
    always_ff @(posedge clk)
        if (rst) begin
            res_r <= '0;
            res_vld_final <= '0;
        end
        else begin
            res_vld_final <= res_vld_r;
            if (res_vld_r)
                res_r <= 32'(y_r[0]) + 32'(y_r[1]) + 32'(y_r[2]);
            end
        

endmodule
