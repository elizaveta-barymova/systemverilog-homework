//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module halve_tokens
(
    input  clk,
    input  rst,
    input  a,
    output b
);
    // Task:
    // Implement a serial module that reduces amount of incoming '1' tokens by half.
    //
    // Note:
    // Check the waveform diagram in the README for better understanding.
    //
    // Example:
    // a -> 110_011_101_000_1111
    // b -> 010_001_001_000_0101

    logic even_one;  
    
    assign b = a & even_one;  
    
    always_ff @(posedge clk)
        if (rst)
            even_one <= 1'b0;
        else if (a)  // Только при получении единицы меняем состояние флага
            even_one <= ~even_one;  
endmodule
