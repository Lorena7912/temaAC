module spi_bridge (
    // peripheral clock signals
    input clk,
    input rst_n,
    // SPI master facing signals
    input sclk,
    input cs_n,
    input mosi,
    output reg miso,
    // internal facing 
    output reg byte_sync,
    output reg[7:0] data_in,
    input[7:0] data_out
);

// Stări pentru sincronizarea SCLK (pentru a detecta fronturile SCLK in CLK domain)
reg sclk_sync_r1, sclk_sync_r2; 
// Contor pentru biți (8 biți de transmisie/recepție)
reg[2:0] bit_count; 
// Registru de schimb (shift register)
reg[7:0] data_in_reg, data_out_reg; 

// Sincronizarea SCLK (de la un clock asincron la cel local)
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sclk_sync_r1 <= 1'b0;
        sclk_sync_r2 <= 1'b0;
    end else begin
        sclk_sync_r1 <= sclk;
        sclk_sync_r2 <= sclk_sync_r1;
    end
end

wire sclk_posedge = sclk_sync_r2 == 1'b0 && sclk_sync_r1 == 1'b1; // Front crescator
wire sclk_negedge = sclk_sync_r2 == 1'b1 && sclk_sync_r1 == 1'b0; // Front descrescator

// Logica principală (SPI FSM/Control)
always @(posedge clk or negedge rst_n) begin
    if (!rst_n || cs_n) begin // Reset sau CS negata (inactiv)
        bit_count <= 3'h0;
        byte_sync <= 1'b0;
        miso <= 1'b0; 
        data_in_reg <= 8'h00;
        data_out_reg <= 8'h00;
    end else begin
        byte_sync <= 1'b0; // Pulse sync
        
        // Logica de citire (MOSI) se face pe frontul descrescător al SCLK (CPOL=0, CPHA=0)
        if (sclk_negedge) begin
            // Shift-in (MOSI -> data_in_reg) - Presupunem LSB first, dar MOSI se adaugă la MSB
            data_in_reg <= {mosi, data_in_reg[7:1]};
        end
        
        // Logica de scriere (MISO) si contorizare (pe frontul crescător SCLK)
        if (sclk_posedge) begin
            // Shift-out (data_out_reg -> MISO)
            miso <= data_out_reg[7]; // MSB out
            data_out_reg <= {data_out_reg[6:0], 1'b0};
            
            // Incrementarea contorului de biți
            bit_count <= bit_count + 1;
            
            if (bit_count == 3'h7) begin // Ultimul bit transmis (8 biti total)
                bit_count <= 3'h0;
                byte_sync <= 1'b1;     // Generare semnal de sincronizare byte
                data_in <= data_in_reg; // Incarca byte-ul primit in output
                data_out_reg <= data_out; // Incarca urmatorul byte de transmis pe MISO
            end
        end
    end
end

endmodule
