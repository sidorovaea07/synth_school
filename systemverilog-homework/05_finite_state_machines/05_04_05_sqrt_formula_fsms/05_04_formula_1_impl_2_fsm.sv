module formula_1_impl_2_fsm (
    input             clk,
    input             rst,
    input             arg_vld,
    input      [31:0] a,
    input      [31:0] b,
    input      [31:0] c,
    output logic      res_vld,
    output logic [31:0] res,

    output logic        isqrt_1_x_vld,
    output logic [31:0] isqrt_1_x,
    input               isqrt_1_y_vld,
    input        [15:0] isqrt_1_y,

    output logic        isqrt_2_x_vld,
    output logic [31:0] isqrt_2_x,
    input               isqrt_2_y_vld,
    input        [15:0] isqrt_2_y
);

    enum logic [1:0] {
        st_idle       = 2'd0,
        st_wait_a_b   = 2'd1,
        st_wait_c     = 2'd2
    } state, next_state;

    logic [31:0] c_reg;

    //------------------------------------------------------------------------
    always_comb begin
        next_state = state;
        case (state)
            st_idle: 
                if (arg_vld) 
                    next_state = st_wait_a_b;
            st_wait_a_b: 
                if (isqrt_1_y_vld & isqrt_2_y_vld) 
                    next_state = st_wait_c;
            st_wait_c: 
                if (isqrt_1_y_vld)
                    if (arg_vld) 
                        next_state = st_wait_a_b;
                    else
                        next_state = st_idle;
        endcase
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            state <= st_idle;
            c_reg <= '0;
        end
        else begin
            state <= next_state;
            if (state == st_idle && arg_vld)
                c_reg <= c;
            else if (state == st_wait_c && isqrt_1_y_vld && arg_vld)
                c_reg <= c;
        end
    end

    //------------------------------------------------------------------------
    always_comb begin
        isqrt_1_x_vld = 1'b0;
        isqrt_1_x     = a;
        isqrt_2_x_vld = 1'b0;
        isqrt_2_x     = b;

        case (state)
            st_idle: begin
                isqrt_1_x_vld = arg_vld;
                isqrt_2_x_vld = arg_vld;
            end
            st_wait_a_b: begin
                if (isqrt_1_y_vld & isqrt_2_y_vld) begin
                    isqrt_1_x_vld = 1'b1;
                    isqrt_1_x     = c_reg;
                end
            end
            st_wait_c: begin
                if (isqrt_1_y_vld && arg_vld) begin
                    isqrt_1_x_vld = 1'b1;
                    isqrt_1_x     = a;
                    isqrt_2_x_vld = 1'b1;
                    isqrt_2_x     = b;
                end
            end
        endcase
    end

    //------------------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (rst) begin
            res     <= '0;
            res_vld <= 1'b0;
        end 
        else begin
            res_vld <= 1'b0;

            if (state == st_wait_a_b && isqrt_1_y_vld)
                res <= 32'(isqrt_1_y) + 32'(isqrt_2_y);

            else if (state == st_wait_c && isqrt_1_y_vld) begin
                res     <= res + 32'(isqrt_1_y);
                res_vld <= 1'b1;
            end    
        end
    end

endmodule
