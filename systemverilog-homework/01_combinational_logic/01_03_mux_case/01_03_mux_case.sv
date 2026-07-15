//----------------------------------------------------------------------------
// Example
//----------------------------------------------------------------------------

// module mux_2_1
// (
//   input        [3:0] d0, d1,
//   input              sel,
//   output logic [3:0] y
// );

//   always_comb
//     case (sel)
//       1'd0: y = d0;
//       1'd1: y = d1;
//     endcase

// endmodule

//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module mux_4_1
(
  input        [3:0] d0, d1, d2, d3,
  input        [1:0] sel,
  output logic [3:0] y
);

  always_comb
    case (sel[1])
      1'd0: 
        case (sel[0])
        1'd0: y = d0;
        1'd1: y = d1;
        endcase
      1'd1: 
        case (sel[0])
        1'd0: y = d2;
        1'd1: y = d3;
        endcase
    endcase

  // Task:
  // Using code for mux_2_1 as an example,
  // write code for 4:1 mux using the "case" statement


endmodule
