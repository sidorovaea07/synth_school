module sort_floats_using_fsm (
    input                  clk,
    input                  rst,
    input                  valid_in,
    input   [0:2][FLEN - 1:0] unsorted,
    output logic           valid_out,
    output logic [0:2][FLEN - 1:0] sorted,
    output logic           err,
    output                 busy,
    output logic [FLEN - 1:0] f_le_a,
    output logic [FLEN - 1:0] f_le_b,
    input                  f_le_res,
    input                  f_le_err
);

    // Task:
    // Implement a module that accepts three Floating-Point numbers and outputs them in the increasing order using FSM.
    //
    // Requirements:
    // The solution must have latency equal to the three clock cycles.
    // The solution should use the inputs and outputs to the single "f_less_or_equal" module.
    // The solution should NOT create instances of any modules.
    //
    // Notes:
    // res0 must be less or equal to the res1
    // res1 must be less or equal to the res1
    //
    // The FLEN parameter is defined in the "import/preprocessed/cvw/config-shared.vh" file
    // and usually equal to the bit width of the double-precision floating-point number, FP64, 64 bits.

    assign busy = !(state == st_idle);
    assign err  = valid_out ? (err_ | f_le_err) : 1'b0;

    enum logic [3:0] {
        st_idle = 4'd0,
        st_ab   = 4'd1,
        st_ba   = 4'd2,
        st_abc  = 4'd3,
        st_ab_  = 4'd4,
        st_cba  = 4'd5,
        st_ba_  = 4'd6,
        st_cab  = 4'd7,
        st_acb  = 4'd8,
        st_bca  = 4'd9,
        st_bac  = 4'd10
    } state, next_state;

    logic [0:2][FLEN - 1:0] data;
    logic err_;

    always_comb begin
        next_state = state;
        case (state)
            st_idle: begin
                if (valid_in) begin
                    if (f_le_res) next_state = st_ab;
                    else          next_state = st_ba;
                end
            end
            
            st_ab: begin
                if (f_le_res) next_state = st_abc;
                else          next_state = st_ab_;
            end
            
            st_ab_: begin
                if (f_le_res) next_state = st_acb;
                else          next_state = st_cab;
            end

            st_ba: begin
                if (f_le_res) next_state = st_ba_;
                else          next_state = st_cba;
            end
            
            st_ba_: begin
                if (f_le_res) next_state = st_bac;
                else          next_state = st_bca;
            end

            st_abc, st_cab, st_acb, st_cba, st_bca, st_bac: next_state = st_idle;
            
            default: next_state = st_idle;
        endcase
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            err_  <= '0;
            state <= st_idle;
            data  <= '0;
        end else begin
            state <= next_state;
            if (state == st_idle && valid_in) begin
                data <= unsorted;
                err_ <= '0;
            end else begin
                if (f_le_err) err_ <= 1'b1; 
            end
        end
    end

    always_comb begin
        f_le_a    = data[0];
        f_le_b    = data[1];
        valid_out = 1'b0;
        sorted    = data;

        case (state)
            st_idle: begin
                f_le_a = unsorted[0];
                f_le_b = unsorted[1];
            end
            st_ab, st_ba: begin
                f_le_a = data[1];
                f_le_b = data[2];
            end
            st_ab_, st_ba_: begin
                f_le_a = data[0];
                f_le_b = data[2];
            end

            st_abc: begin
                sorted[0] = data[0];
                sorted[1] = data[1];
                sorted[2] = data[2];
                valid_out = 1'b1;
            end
            st_cab: begin
                sorted[0] = data[2];
                sorted[1] = data[0];
                sorted[2] = data[1];
                valid_out = 1'b1;
            end
            st_acb: begin
                sorted[0] = data[0];
                sorted[1] = data[2];
                sorted[2] = data[1];
                valid_out = 1'b1;
            end
            st_cba: begin
                sorted[0] = data[2];
                sorted[1] = data[1];
                sorted[2] = data[0];
                valid_out = 1'b1;
            end
            st_bca: begin
                sorted[0] = data[1];
                sorted[1] = data[2];
                sorted[2] = data[0];
                valid_out = 1'b1;
            end
            st_bac: begin
                sorted[0] = data[1];
                sorted[1] = data[0];
                sorted[2] = data[2];
                valid_out = 1'b1;
            end
        endcase
    end

endmodule
