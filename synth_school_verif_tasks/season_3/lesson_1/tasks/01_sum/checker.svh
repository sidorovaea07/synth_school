// Объявляем событие окончания генерации
event gen_done;

// Массивы-счетчики для 8 интервалов (размер фиксирован [7:0])
reg [7:0] covered_A;
reg [7:0] covered_B;

// Размер одного интервала
localparam [31:0] INTERVAL_SIZE = 32'hFFFF_FFFF / 8;

// Логика отслеживания сигналов
initial begin
    fork
        // Каждую итерацию проверяем, куда попали A и B
        forever begin
            #1; // Ждем 1 шаг времени
            
            // Запоминаем, в какой интервал попало значение A
            for (int i = 0; i < 8; i++) begin
                if (A >= i * INTERVAL_SIZE && (i == 7 || A < (i + 1) * INTERVAL_SIZE)) begin
                    covered_A[i] = 1'b1;
                end
            end
            
            // Запоминаем, в какой интервал попало значение B
            for (int i = 0; i < 8; i++) begin
                if (B >= i * INTERVAL_SIZE && (i == 7 || B < (i + 1) * INTERVAL_SIZE)) begin
                    covered_B[i] = 1'b1;
                end
            end
        end

        // Ждем, пока в основном тестбенче сработает окончание (исправлено под iverilog)
        @(gen_done);
    join_any

    // Считаем процент покрытия (переменные вынесены наружу для избавления от warning)
    begin: report_block
        real score_a;
        real score_b;
        int count_a;
        int count_b;
        
        count_a = 0;
        count_b = 0;

        for (int i = 0; i < 8; i++) begin
            if (covered_A[i] == 1'b1) count_a++;
            if (covered_B[i] == 1'b1) count_b++;
        end

        score_a = (count_a / 8.0) * 100.0;
        score_b = (count_b / 8.0) * 100.0;

        // Выводим красивую статистику прямо в консоль VS Code!
        $display("========================================");
        $display("        РУЧНОЙ ОТЧЕТ ПО ПОКРЫТИЮ        ");
        $display("========================================");
        $display("Операнд A покрыт на: %3.1f%% (%0d из 8 интервалов)", score_a, count_a);
        $display("Операнд B покрыт на: %3.1f%% (%0d из 8 интервалов)", score_b, count_b);
        $display("========================================");
    end
end
