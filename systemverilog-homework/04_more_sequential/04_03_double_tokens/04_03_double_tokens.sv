//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module double_tokens
(
    input        clk,
    input        rst,
    input        a,
    output       b,
    output logic overflow
);
    // Task:
    // Implement a serial module that doubles each incoming token '1' two times.
    // The module should handle doubling for at least 200 tokens '1' arriving in a row.
    //
    // In case module detects more than 200 sequential tokens '1', it should assert
    // an overflow error. The overflow error should be sticky. Once the error is on,
    // the only way to clear it is by using the "rst" reset signal.
    //
    // Note:
    // Check the waveform diagram in the README for better understanding.
    //
    // Example:
    // a -> 10010011000110100001100100
    // b -> 11011011110111111001111110

    logic [$clog2(200) - 1:0] one_cnt, next_should_be_one;
    assign overflow = one_cnt > 8'd200 ? 1 : 0; 

    logic ans;
    assign b = ans;

    always_ff @(posedge clk)
      if (rst) begin
            next_should_be_one <=                            '0;
            one_cnt            <=                            '0;
      end    
      else 
        if (a) begin
            next_should_be_one <=     next_should_be_one + 1'b1;
            one_cnt            <=                one_cnt + 1'b1;
            ans                <=                            '1;
        end
        else if (next_should_be_one) begin
            ans                <=                            '1;
            next_should_be_one <= next_should_be_one - 1'b1 + a;
            one_cnt            <=                            '0;
        end
        else begin
            ans                <=                            '0;
            one_cnt            <=                            '0;
        end


endmodule
