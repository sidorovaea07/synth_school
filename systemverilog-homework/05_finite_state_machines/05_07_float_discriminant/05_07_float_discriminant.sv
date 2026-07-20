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
    
    logic [1:0]           up_vld_r;
    logic [3:0]         down_vld_r;
    logic [3:0][FLEN - 1:0]  res_r;
    logic [3:0]              err_r;
    logic [3:0]             busy_r;
    logic [2:0][FLEN - 1:0] data_r;
    
    assign busy = (| busy_r ) | (| up_vld_r);
    assign err  = | err_r         ;
    assign res  = res_r[3]        ;
    assign res_vld = down_vld_r[3];
    assign res_negative = res_r[3][FLEN - 1];

    always_ff @(posedge clk) begin
        if (rst) begin
            up_vld_r  <= '0;
            data_r <= '0;
        end
        else begin
            up_vld_r <= '0;

            if (arg_vld && ~ busy) begin
                data_r[0] <= a;
                data_r[1] <= b;
                data_r[2] <= c;
                up_vld_r <= 2'b11;
            end
        end
    end

    f_mult for_mult0_bb (
        .clk (clk),
        .rst (rst),
        .a   ( data_r[1] ),
        .b   ( data_r[1] ),
        .up_valid ( up_vld_r[0] ),
        .res ( res_r[0] ),
        .down_valid ( down_vld_r[0] ),
        .busy ( busy_r[0] ),
        .error ( err_r[0] )
    ); 

    f_mult for_mult1_ac (
        .clk (clk),
        .rst (rst),
        .a   ( data_r[0] ),
        .b   ( data_r[2] ),
        .up_valid ( up_vld_r[1] ),
        .res ( res_r[1] ),
        .down_valid ( down_vld_r[1] ),
        .busy ( busy_r[1] ),
        .error ( err_r[1] )
    ); 

    f_mult for_mult2_4ac (
        .clk (clk),
        .rst (rst),
        .a   ( four ),
        .b   ( res_r[1] ),
        .up_valid ( down_vld_r[1] ),
        .res ( res_r[2] ),
        .down_valid ( down_vld_r[2] ),
        .busy ( busy_r[2] ),
        .error ( err_r[2] )
    ); 

    f_sub for_sub (
        .clk (clk),
        .rst (rst),
        .a   ( res_r[0] ),
        .b   ( res_r[2] ),
        .up_valid ( down_vld_r[2] ),
        .res ( res_r[3] ),
        .down_valid ( down_vld_r[3] ),
        .busy ( busy_r[3] ),
        .error ( err_r[3] )
    ); 


endmodule
