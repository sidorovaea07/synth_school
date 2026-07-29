module testbench;

    logic [7:0] A;
    logic [7:0] B;
    logic [7:0] C;

    sum DUT(
        .a ( A ),
        .b ( B ),
        .c ( C )
    );

    initial begin
        $dumpfile("dump.vcd"); // Имя файла, куда запишутся графики
        $dumpvars(0, testbench); // Записать ВСЕ сигналы из модуля testbench
        A = 2;
        B = 3;

        #20;
        if(C !== 5) $error("BAD");
        $dumpflush; // <--- ДОБАВЬТЕ ЭТУ СТРОЧКУ ПЕРЕД ВЫХОДОМ!
        $finish;

    end

endmodule
