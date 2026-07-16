//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module round_robin_arbiter_with_2_requests
(
    input        clk,
    input        rst,
    input  [1:0] requests,
    output [1:0] grants
);
    // Task:
    // Implement a "arbiter" module that accepts up to two requests
    // and grants one of them to operate in a round-robin manner.
    //
    // The module should maintain an internal register
    // to keep track of which requester is next in line for a grant.
    //
    // Note:
    // Check the waveform diagram in the README for better understanding.
    //
    // Example:
    // requests -> 01 00 10 11 11 00 11 00 11 11
    // grants   -> 01 00 10 01 10 00 01 00 10 01

 logic prty;   

 assign grants[0] = requests[0] & ( ~ prty | ~ requests[1]);
 assign grants[1] = requests[1] & (   prty | ~ requests[0]);
 
 always_ff @( posedge clk ) 
  if (rst) begin
   prty <= '0;
  end
  else
    case (grants)
        2'b01: prty <= 1;
        2'b10: prty <= 0;
        default: ;
    endcase

endmodule

