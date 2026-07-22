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

    output logic        isqrt_x_vld,
    output logic [31:0] isqrt_x,

    input               isqrt_y_vld,
    input        [15:0] isqrt_y
);

    logic [15:0] sqrt_a, sqrt_b;
    logic res_vld_r;
    logic [31:0] res_r;
    
    logic [1:0] res_cnt;
    
    assign res_vld = res_vld_r;
    assign res     = res_r;

    enum logic [1:0] {
        st_idle   = 2'd0,
        st_send_b = 2'd1,
        st_send_c = 2'd2,
        st_collect = 2'd3
    } state, next_state;

    always_ff @(posedge clk) begin
        if (rst) begin
            state     <= st_idle;
            sqrt_a    <= '0;
            sqrt_b    <= '0;
            res_r     <= '0;
            res_vld_r <= '0;
            res_cnt   <= '0;
        end
        else begin
            state <= next_state;
            
            if (isqrt_y_vld) begin
                res_cnt <= res_cnt + 1'b1;
                
                if (res_cnt == 0)
                    sqrt_a <= isqrt_y;
                else if (res_cnt == 1)
                    sqrt_b <= isqrt_y;
                else if (res_cnt == 2) begin
                    res_r     <= 32'(sqrt_a) + 32'(sqrt_b) + 32'(isqrt_y);
                    res_vld_r <= 1'b1;
                    res_cnt   <= '0;
                end
            end
            else begin
                res_vld_r <= 1'b0;
            end
        end
    end

    always_comb begin
        isqrt_x_vld = '0;
        isqrt_x     = '0;
        next_state  = state;

        case (state)
            st_idle: begin
                if (arg_vld) begin
                    isqrt_x_vld = 1'b1;
                    isqrt_x     = a;
                    next_state  = st_send_b;
                end
            end
            
            st_send_b: begin
                isqrt_x_vld = 1'b1;
                isqrt_x     = b;
                next_state  = st_send_c;
            end
            
            st_send_c: begin
                isqrt_x_vld = 1'b1;
                isqrt_x     = c;
                next_state  = st_collect;
            end
            
            st_collect: begin
                if (isqrt_y_vld && res_cnt == 2) begin
                    next_state = st_idle;
                end
            end
            
            default: next_state = st_idle;
        endcase
    end

endmodule