`timescale 1ns / 1ps

module uart_tx_tb;

    // Testbench parametreleri
    localparam CLK_FRE      = 50;       // Clock frekansı (MHz)
    localparam BAUD_RATE    = 115200;   // Baud hızı
    localparam CLK_PERIOD   = 1000 / CLK_FRE; // Clock periyodu (ns)

    // DUT (Device Under Test) giriş ve çıkış sinyalleri
    reg         clk;
    reg         rst_n;
    reg  [7:0]  tx_data;
    reg         tx_data_valid;
    wire        tx_data_ready;
    wire        tx_pin;

    // DUT'u (uart_tx) testbench'e dahil etme
    uart_tx #(
        .CLK_FRE(CLK_FRE),
        .BAUD_RATE(BAUD_RATE)
    ) UUT (
        .clk(clk),
        .rst_n(rst_n),
        .tx_data(tx_data),
        .tx_data_valid(tx_data_valid),
        .tx_data_ready(tx_data_ready),
        .tx_pin(tx_pin)
    );

    // Clock sinyali üretimi
    always begin
        clk = 1'b0;
        #(CLK_PERIOD / 2);
        clk = 1'b1;
        #(CLK_PERIOD / 2);
    end

    // Test senaryosu
    initial begin
        // --- VCD (Waveform) Dosyası Oluşturma ---
        $dumpfile("uart_tx_tb.vcd"); // Dalga formunun kaydedileceği dosyanın adı
        $dumpvars(0, uart_tx_tb);    // Hangi sinyallerin kaydedileceğini belirtir (0: hepsi)

        // Başlangıç değerleri
        rst_n = 1'b0;
        tx_data = 8'h00;
        tx_data_valid = 1'b0;

        // Reset sinyalini uygula
        #100; // 100ns bekle
        rst_n = 1'b1;
        $display("T=%0t: Reset sinyali kaldirildi. Modul baslatiliyor...", $time);

        // Modülün veri göndermeye hazır olmasını bekle
        wait (tx_data_ready == 1'b1);
        $display("T=%0t: UART TX veri gondermeye hazir.", $time);

        // --- 1. Baytı Gönder: 8'hA5 ---
        $display("T=%0t: 1. Bayt (0xA5) gonderiliyor...", $time);
        tx_data = 8'hA5;
        tx_data_valid = 1'b1;
        @(posedge clk);
        tx_data_valid = 1'b0;

        // Gönderim bitene kadar bekle
        wait (tx_data_ready == 1'b1);
        $display("T=%0t: 1. Bayt gonderildi.", $time);
        #1000; // Bir sonraki bayttan önce biraz bekle

        // --- 2. Baytı Gönder: 8'h5A ---
        $display("T=%0t: 2. Bayt (0x5A) gonderiliyor...", $time);
        tx_data = 8'h5A;
        tx_data_valid = 1'b1;
        @(posedge clk);
        tx_data_valid = 1'b0;

        // Gönderim bitene kadar bekle
        wait (tx_data_ready == 1'b1);
        $display("T=%0t: 2. Bayt gonderildi.", $time);
        
        // --- 3. Baytı Gönder: 8'hC3 ---
        $display("T=%0t: 3. Bayt (0xC3) gonderiliyor...", $time);
        tx_data = 8'hC3;
        tx_data_valid = 1'b1;
        @(posedge clk);
        tx_data_valid = 1'b0;

        // Gönderim bitene kadar bekle
        wait (tx_data_ready == 1'b1);
        $display("T=%0t: 3. Bayt gonderildi.", $time);


        // Simülasyonu bitir
        $display("T=%0t: Test senaryosu tamamlandi.", $time);
        #2000;
        $finish;
    end

    // Sinyal değişimlerini izlemek için monitör (bu kalabilir, zararı yok)
    initial begin
        $monitor("T=%0t | rst_n: %b, tx_data: %h, tx_data_valid: %b, tx_data_ready: %b, tx_pin: %b",
                 $time, rst_n, tx_data, tx_data_valid, tx_data_ready, tx_pin);
    end

endmodule