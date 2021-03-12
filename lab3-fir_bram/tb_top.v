/*
 *  Module `tb_top`
 *
 *  Testbench integracion de generacion de señales, filtro FIR
 *  y bloque BRAM mas FSM.
 *
 *  EAMTA 2021 - Digital Design
 *  Laboratorio 3: Integracion filtro FIR con memoria BRAM.
 *  Gonzalo G. Fernandez     12/03/2021
 *  File: tb_top.v
 */

`timescale 1ns/100ps

module tb_top();

// Vars
reg             clock;              // System clock
reg             reset;              // Reset asincronco
reg     [2:0]   enable;             // Señales de habilitacion
reg     [1:0]   sel;                // Seleccion de señal
wire            log_ram_full;       // BRAM full
wire    [15:0]  log_data_from_ram;  // Informacion leida de BRAM

integer i;

// Simulacion
initial begin
    // Condiciones iniciales
    reset       = 1'b0;     // estado bajo RESET simulando hardware
    clock       = 1'b1;
    sel         = 2'b00;    // señal 1
    enable      = 3'b000;   // ningun modulo habilitado
    
    #100    reset = 1'b1;   // abandonar estado de reset
    
    // habilitar la generacion y filtrado de señal (señal 1)
    #100    enable[0] = 1'b1;
    
    #100;
    // ciclo escritura lectura de las 4 señales
    for (i=0; i<4; i=i+1) begin
        // seleccionar señal (toggle de botones para pasar por todos los estados)
        sel[0] = ~sel[0];
        sel[1] = (i%2 == 0) ? ~sel[1] : sel[1];
        #50 sel = 2'b00;    // al ser botones vuelven a su posicion inicial
        
        // realizar una escritura de BRAM completa con señal 1
        #100    enable[1] = 1'b1;
        while (log_ram_full == 1'b0) begin
            #10;
        end
        enable[1] = 1'b0;   // deshabilitar escritura
        
        // realizar lectura de la muestra (señal 1)
        #100    enable[2] = 1'b1;   
        // finalizar lectura de la muestra (señal 1)
        #10000  enable[2] = 1'b0;   
    end 
    
    #1000   $finish;
end

// Generacion de onda de clock (100MHz)
always
    #5 clock = ~clock;

// Instancia de top
top
u_top   
    (
    .i_clock(clock),
    .i_reset(~reset),
    .i_enable(enable),
    .i_sel(sel),
    .o_log_ram_full(log_ram_full),
    .o_log_data_from_ram(log_data_from_ram)
    );

endmodule
