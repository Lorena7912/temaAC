module regs (
    // peripheral clock signals
    input clk,
    input rst_n,
    // decoder facing signals
    input read,
    input write,
    input[5:0] addr,
    output reg[7:0] data_read, 
    input[7:0] data_write,
    // counter programming signals
    input[15:0] counter_val,
    output[15:0] period,
    output en,
    output count_reset,
    output upnotdown,
    output[7:0] prescale,
    // PWM signal programming values
    output pwm_en,
    output[7:0] functions,
    output[15:0] compare1,
    output[15:0] compare2
);


reg[15:0] period_r;
reg en_r;
reg[15:0] compare1_r;
reg[15:0] compare2_r;
reg count_reset_pulse_r;
reg[7:0] prescale_r;
reg upnotdown_r;
reg pwm_en_r;
reg[1:0] functions_r;

assign period = period_r;
assign en = en_r;
assign compare1 = compare1_r;
assign compare2 = compare2_r;
assign count_reset = count_reset_pulse_r; 
assign prescale = prescale_r;
assign upnotdown = upnotdown_r;
assign pwm_en = pwm_en_r;
assign functions = {6'h00, functions_r};

always @(*) begin
    data_read = 8'h00;
    if (read) begin
        case (addr)
            6'h00: data_read = period_r[7:0];      
            6'h01: data_read = period_r[15:8];     
            6'h02: data_read = {7'h00, en_r};      
            6'h03: data_read = compare1_r[7:0];    
            6'h04: data_read = compare1_r[15:8];   
            6'h05: data_read = compare2_r[7:0];    
            6'h06: data_read = compare2_r[15:8];   
            // 6'h07: COUNTER_RESET (write only)
            6'h08: data_read = counter_val[7:0];
            6'h09: data_read = counter_val[15:8];
            6'h0A: data_read = prescale_r;         
            6'h0B: data_read = {7'h00, upnotdown_r};
            6'h0C: data_read = {7'h00, pwm_en_r};  
            6'h0D: data_read = {6'h00, functions_r[1:0]}; 
            default: data_read = 8'h00;
        endcase
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        // Reset
        period_r <= 16'h0000;
        en_r <= 1'b0;
        compare1_r <= 16'h0000;
        compare2_r <= 16'h0000;
        count_reset_pulse_r <= 1'b0; 
        prescale_r <= 8'h00;
        upnotdown_r <= 1'b0;
        pwm_en_r <= 1'b0;
        functions_r <= 2'b00;
    end else begin
        
        if (write && addr == 6'h07) begin
            count_reset_pulse_r <= 1'b1;
        end else if (count_reset_pulse_r == 1'b1) begin
            count_reset_pulse_r <= 1'b0; 
        end
        
        if (write) begin
            case (addr)
                6'h00: period_r[7:0] <= data_write;        
                6'h01: period_r[15:8] <= data_write;       
                6'h02: en_r <= data_write[0];              
                6'h03: compare1_r[7:0] <= data_write;      
                6'h04: compare1_r[15:8] <= data_write;     
                6'h05: compare2_r[7:0] <= data_write;      
                6'h06: compare2_r[15:8] <= data_write;     
                6'h0A: prescale_r <= data_write;           
                6'h0B: upnotdown_r <= data_write[0];       
                6'h0C: pwm_en_r <= data_write[0];          
                6'h0D: functions_r[1:0] <= data_write[1:0]; 
                default: ; 
            endcase
        end
    end
end

endmodule
