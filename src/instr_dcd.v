module instr_dcd (
    // peripheral clock signals
    input clk,
    input rst_n,
    // towards SPI slave interface signals
    input byte_sync,
    input[7:0] data_in,
    output reg[7:0] data_out,
    // register access signals
    output reg read,
    output reg write,
    output reg[5:0] addr,
    input[7:0] data_read,
    output reg[7:0] data_write
);

//stari FSM: faza 1 (instructiune) si faza 2 (date)
localparam S_INSTR = 2'b00;
localparam S_DATA = 2'b01;

reg[1:0] state, next_state; 
reg current_op_write; //retine (R/W)

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= S_INSTR;
    end else begin
        state <= next_state;
    end
end

always @(*) begin
    next_state = state;
    read = 1'b0;
    write = 1'b0;
    data_out = data_read; //data_out pentru MISO

    case (state)
        S_INSTR: begin
            if (byte_sync) begin //primul byte primit
                current_op_write = data_in[7]; //bit 7: 1=write, 0=read
                addr = data_in[5:0];           //bitii 5:0: adresa

                if (current_op_write) begin
                    next_state = S_DATA;
                end else begin
                    read = 1'b1;
                    //data_out e setat la data_read
                    next_state = S_INSTR;
                end
            end
        end
        
        S_DATA: begin
            if (byte_sync) begin //al doilea byte primit
                write = 1'b1;
                data_write = data_in;
                read = 1'b0;
                next_state = S_INSTR;
            end
        end
    endcase
end

endmodule
