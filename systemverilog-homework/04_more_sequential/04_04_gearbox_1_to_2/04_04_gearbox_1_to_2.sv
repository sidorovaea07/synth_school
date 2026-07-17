//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module gearbox_1_to_2
# (
    parameter width = 0
)
(
    input                    clk,
    input                    rst,

    input                    up_vld,    // upstream
    input  [    width - 1:0] up_data,

    output                   down_vld,  // downstream
    output [2 * width - 1:0] down_data
);
    // Task:
    // Implement a module that transforms a stream of data
    // from 'width' to the 2*'width' data width.
    //
    // The module should be capable to accept new data at each
    // clock cycle and produce concatenated 'down_data'
    // at each second clock cycle.
    //
    // The module should work properly with reset 'rst'
    // and valid 'vld' signals

    logic [    width - 1:0] first_part;
    logic [2 * width - 1:0] final_data;

    logic                   cycle, vld;

    assign down_vld             =                   vld;
    assign down_data            =            final_data;

    always_ff @(posedge clk) 
    begin
        if (rst) 
        begin
            cycle              <=                    '0;
            vld                <=                    '0;
            first_part         <=                    '0;
            final_data         <=                    '0;
        end
        else begin
            vld                <=                    '0;
            if (up_vld) 
                if (~ cycle) 
                begin
                    first_part <=               up_data;
                    cycle      <=               ~ cycle;
                end
                else 
                begin
                    final_data <= {first_part, up_data};
                    cycle      <=               ~ cycle;
                    vld        <=                    '1;
                end
        end        
    end


endmodule
