//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_2_pipe_using_fifos
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
    // Implement a pipelined module formula_2_pipe_using_fifos that computes the result
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
    // 3. Your solution should use FIFOs instead of shift registers
    // which were used in 06_04_formula_2_pipe.sv.
    //
    // You can read the discussion of this problem
    // in the article by Yuri Panchul published in
    // FPGA-Systems Magazine :: FSM :: Issue ALFA (state_0)
    // You can download this issue from https://fpga-systems.org/fsm#state_0


    logic [1:0]        down_vld, up_vld;
    logic [1:0][31:0] comb_res, up_data;
    logic [1:0][15:0]               y_r;
    logic [31:0]               b_r, a_r;

    parameter n_pipe_stages = 16;

    isqrt c_calc 
    (
        .clk   ( clk        ),
        .rst   ( rst        ),
        .x_vld ( arg_vld    ),
        .x     ( c          ),
        .y_vld ( down_vld[0]),
        .y     ( y_r[0]     )
    );

    flip_flop_fifo_with_counter #(32, n_pipe_stages)         b_shift 
    (
        .clk      ( clk     ),
        .rst      ( rst     ),
        .push     ( arg_vld ),
        .pop      ( down_vld[0] ),
        .write_data  ( b       ),
        .read_data ( b_r     ),
        .empty    (         ),
        .full     (         )
    );

    flip_flop_fifo_with_counter #(32, 2 * n_pipe_stages + 1) a_shift 
    (
        .clk        ( clk     ),
        .rst        ( rst     ),
        .push       ( arg_vld ),
        .pop        ( down_vld[1] ),
        .write_data ( a       ),
        .read_data  ( a_r     ),
        .empty      (         ),
        .full       (         )
    );

    assign comb_res[0] = 32'(y_r[0]) + b_r;

    always_ff @(posedge clk) begin
        if (rst) begin
            up_vld[0]  <= '0;
            up_data[0] <= '0;
        end    
        else begin
            up_vld[0]  <= down_vld[0];
            up_data[0] <= comb_res[0];
        end    
    end

    isqrt bc_calc 
    (
        .clk   ( clk ),
        .rst   ( rst ),
        .x_vld ( up_vld[0]   ),
        .x     ( up_data[0]  ),
        .y_vld ( down_vld[1] ),
        .y     ( y_r[1] )
    );

    assign comb_res[1] = 32'(y_r[1]) + a_r;

    always_ff @(posedge clk) begin
        if (rst) begin
            up_vld[1]  <= '0;
            up_data[1] <= '0;
        end    
        else begin
            up_vld[1]  <= down_vld[1];
            up_data[1] <= comb_res[1];
        end    
    end

    isqrt abc_calc 
    (
        .clk   ( clk ),
        .rst   ( rst ),
        .x_vld ( up_vld[1]   ),
        .x     ( up_data[1]  ),
        .y_vld ( res_vld     ),
        .y     ( res )
    );

endmodule

