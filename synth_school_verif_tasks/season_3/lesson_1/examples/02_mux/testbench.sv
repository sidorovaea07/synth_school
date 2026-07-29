module testbench;

    logic a;
    logic b;
    logic sel;
    logic c;

    mux DUT(
        .a   ( a   ),
        .b   ( b   ),
        .sel ( sel ),
        .c   ( c   )
    );

    initial begin
        $dumpfile("dump.vcd"); // Имя файла, куда запишутся графики
        $dumpvars(0, testbench); // Записать ВСЕ сигналы из модуля testbench
        a   = 0;
        b   = 1;
        sel = 1;

        #20;
        if(c !== 1) $error("BAD");
        $dumpflush; // <--- ДОБАВЬТЕ ЭТУ СТРОЧКУ ПЕРЕД ВЫХОДОМ!
        $finish;

    end

endmodule
