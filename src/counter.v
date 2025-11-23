module counter (
    // peripheral clock signals
    input clk,
    input rst_n,
    // register facing signals
    output reg[15:0] count_val,
    input[15:0] period,
    input en,
    input count_reset,
    input upnotdown,
    input[7:0] prescale
);

reg[7:0] prescaler_count; //contor intern pentru prescalare

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        count_val <= 16'h0000;
        prescaler_count <= 8'h00;
    end else if (count_reset) begin
        count_val <= 16'h0000;
        prescaler_count <= 8'h00; 
    end else if (en) begin
        // prescale = N => contorul incrementeaza după N+1 cicluri
        if (prescaler_count == prescale) begin
            prescaler_count <= 8'h00;
            
            if (upnotdown == 1'b1) begin
                if (count_val == period) begin
                    //perioada atinsa, se reseteaza la 0
                    count_val <= 16'h0000;
                end else begin
                    count_val <= count_val + 1;
                end
            end else begin
                if (count_val == 16'h0000) begin
                    //ajuns la 0, se reseteaza la period
                    count_val <= period;
                end else begin
                    count_val <= count_val - 1;
                end
            end
        end else begin
            prescaler_count <= prescaler_count + 1;
        end
    end
end

endmodule
