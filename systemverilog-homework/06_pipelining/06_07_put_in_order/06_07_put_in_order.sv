module put_in_order
# (
    parameter width    = 16,
              n_inputs = 4
)
(
    input                       clk,
    input                       rst,

    input  [ n_inputs - 1 : 0 ] up_vlds,
    input  [ n_inputs - 1 : 0 ]
           [ width    - 1 : 0 ] up_data,

    output                      down_vld,
    output [ width   - 1 : 0 ]  down_data
);

    // Task:
    //
    // Implement a module that accepts many outputs of the computational blocks
    // and outputs them one by one in order. Input signals "up_vlds" and "up_data"
    // are coming from an array of non-pipelined computational blocks.
    // These external computational blocks have a variable latency.
    //
    // The order of incoming "up_vlds" is not determent, and the task is to
    // output "down_vld" and corresponding data in a round-robin manner,
    // one after another, in order.
    //
    // Comment:
    // The idea of the block is kinda similar to the "parallel_to_serial" block
    // from Homework 2, but here block should also preserve the output order.

    logic [n_inputs - 1:0][width - 1:0] data    ;
    logic [n_inputs - 1:0]              data_vld;
    logic [$clog2(n_inputs) - 1:0] down_data_idx;

    assign down_data = data[down_data_idx]; 
    assign down_vld  = data_vld[down_data_idx]; 

    always_ff @(posedge clk) begin
        if (rst) begin
            data          <= '0;
            data_vld      <= '0;
        end
        else begin    
            for (int i = 0; i < n_inputs; i ++) begin
                if (up_vlds[i]) begin
                    data[i]     <= up_data[i];
                    data_vld[i] <= '1;
                end 
                // else if (down_vld && (down_data_idx == i)) begin
                //     data_vld[i] <= '0;
                // end
            end                   
        end
    end

    always_ff @(posedge clk) begin
        if (rst) 
            down_data_idx <= '0;
        else
            if (down_vld || !(data_vld[down_data_idx])) begin
                if (down_data_idx == n_inputs - 1)
                    down_data_idx <= '0;
                else
                    down_data_idx <= down_data_idx + '1;    
            end
    end    

endmodule
