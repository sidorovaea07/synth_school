//----------------------------------------------------------------------------
// Example
//----------------------------------------------------------------------------

module mux
(
  input  d0, d1,
  input  sel,
  output y
);

  assign y = sel ? d1 : d0;

endmodule

//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module or_gate_using_mux
(
    input  a,
    input  b,
    output o
);

  mux for_or_gate (
    .d0  ( b ),
    .d1  ( 1 ),
    .sel ( a ),
    .y   ( o )
  );

  // Task:

  // Implement or gate using instance(s) of mux,
  // constants 0 and 1, and wire connections


endmodule
