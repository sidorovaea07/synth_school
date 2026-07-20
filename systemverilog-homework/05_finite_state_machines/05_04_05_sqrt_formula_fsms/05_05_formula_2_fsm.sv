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
    // You can download this issue from https://fpga-systems.org/fsm#state_0

    enum logic [2:0] {
        st_idle     = 3'd0,
        st_wait_c   = 3'd1,
        st_wait_bc  = 3'd2,
        st_wait_abc = 3'd3
    } state, next_state;

    logic [31:0] a_reg, b_reg, bc_reg;

    always_comb begin
        next_state = state;
        case (state)
            st_idle:
                if (arg_vld)
                    next_state = st_wait_c;
            st_wait_c:
                if (isqrt_y_vld)
                    next_state = st_wait_bc;
            st_wait_bc:
                if (isqrt_y_vld)
                    next_state = st_wait_abc;
            st_wait_abc:
                if (isqrt_y_vld)
                    if (arg_vld)
                        next_state = st_wait_c;
                    else
                        next_state = st_idle;
        endcase                                            
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            state  <= st_idle;
            a_reg  <= '0;
            b_reg  <= '0;
            bc_reg <= '0;
        end
        else begin
            state <= next_state;
            if  ((state == st_idle && arg_vld) 
              || (state == st_wait_c && isqrt_y_vld && arg_vld)) begin
                a_reg <= a;
                b_reg <= b;
            end
        end
    end

    always_comb begin
        isqrt_x_vld = '0;
        isqrt_x     =  c;

        case (state)
            st_idle:
                isqrt_x_vld = arg_vld;
            st_wait_c:
                if (isqrt_y_vld) begin
                    isqrt_x_vld = '1;
                    isqrt_x     = b_reg + isqrt_y;
                end
            st_wait_bc:
                if (isqrt_y_vld) begin
                    isqrt_x_vld = '1;
                    isqrt_x     = a_reg + isqrt_y;
                end    
            st_wait_abc:
                if (isqrt_y_vld && arg_vld) begin
                    isqrt_x_vld = '1;
                    isqrt_x     =  c;
                end
        endcase
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            res     <= '0;
            res_vld <= '0;
        end
        else begin
            res_vld <= '0;

            if (state == st_wait_abc && isqrt_y_vld) begin
                res <= isqrt_y; 
                res_vld <= '1;
            end    
        end 

    end

endmodule
