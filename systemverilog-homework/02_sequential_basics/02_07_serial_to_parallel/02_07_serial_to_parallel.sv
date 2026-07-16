//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module serial_to_parallel
# (
    parameter width = 8
)
(
    input                      clk,
    input                      rst,

    input                      serial_valid,
    input                      serial_data,

    output logic               parallel_valid,
    output logic [width - 1:0] parallel_data
);
    // Task:
    // Implement a module that converts single-bit serial data to the multi-bit parallel value.
    //
    // The module should accept one-bit values with valid interface in a serial manner.
    // After accumulating 'width' bits and receiving last 'serial_valid' input,
    // the module should assert the 'parallel_valid' at the same clock cycle
    // and output 'parallel_data' value.
    //
    // Note:
    // Check the waveform diagram in the README for better understanding.

    logic [width - 1:0]  data_answer;
    logic [$clog2(width):0]  bit_cnt;

    assign parallel_valid = serial_valid && (bit_cnt == width - 1);
    assign parallel_data  = parallel_valid ? { serial_data, data_answer[width - 1:1] } 
                                           : data_answer;
    
    always_ff @ ( posedge clk )
      if (rst) 
      begin
        data_answer  <= '0;
        bit_cnt      <= '0;
      end  
      else 
      begin
        if (serial_valid) 
        begin
            data_answer <= { serial_data, data_answer[width - 1:1] };
        
            if (bit_cnt == width - 1) 
                bit_cnt <=             '0;
            else
                bit_cnt <= bit_cnt + 1'b1;    
        end
      
      end  


endmodule
