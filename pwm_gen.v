module pwm_gen (
    // peripheral clock signals
    input clk,
    input rst_n,
    // PWM signal register configuration
    input pwm_en,
    input[15:0] period,
    input[7:0] functions,
    input[15:0] compare1,
    input[15:0] compare2,
    input[15:0] count_val,
    // top facing signals
    output reg pwm_out
);

// functions[0]: 0=nealiniat 1=aliniat
wire functions_align_type = functions[0]; 
// functions[1]: 0=nealiniat 1=aliniat
wire functions_mode = functions[1];      

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        pwm_out <= 1'b0;
    end else if (pwm_en == 1'b0) begin
        //semnalul ramane in starea in care se afla
    end else begin
        
        //modul nealiniat: foloseste doar compare1
        if (functions_mode == 1'b0) begin 
            
            if (functions_align_type == 1'b0) begin
                //nealiniat: pwm=1 la start, trece la 0 la compare1
                if (count_val >= compare1)
                    pwm_out <= 1'b0;
                else
                    pwm_out <= 1'b1;
            end else begin
                //aliniat: pwm=0 la start, trece la 1 la compare1
                if (count_val >= compare1)
                    pwm_out <= 1'b1;
                else
                    pwm_out <= 1'b0;
            end
        end
        
        else begin 
            //semnal activ intre compare1 si compare2
            if (count_val >= compare1 && count_val < compare2) begin
                pwm_out <= 1'b1; 
            end else begin
                pwm_out <= 1'b0;
            end
        end
    end
end

endmodule