/*
 *  Module `tb_signal_mux`
 *
 *  Testbench del multiplexor de señales generadas.
 *  Integración con filtro FIR para señal seleccionada.
 *
 *  EAMTA 2021 - Digital Design
 *  Laboratorio 3: Integracion filtro FIR con memoria BRAM.
 *  Gonzalo G. Fernandez     10/03/2021
 *  File: tb_signal_mux.v
 */

`timescale 1ns/100ps

module tb_signal_mux();

// Parameters
parameter NB_DATA   = 8;
parameter NB_SEL    = 2;

// Vars
reg                             clock;              // Señal de clock
reg                             reset;              // Señal de reset
reg             [NB_SEL-1 : 0]  sel;                // Seleccion de señal
wire    signed  [NB_DATA-1 : 0] w_signal;           // Salida de multiplexor
wire    signed  [NB_DATA-1 : 0] w_filtered_signal;  // Salida de filtro FIR

// Señales generadas
wire    signed  [NB_DATA-1 : 0]  w_signal_1;
wire    signed  [NB_DATA-1 : 0]  w_signal_2;
wire    signed  [NB_DATA-1 : 0]  w_signal_3;
wire    signed  [NB_DATA-1 : 0]  w_signal_4;

assign w_signal_1 = tb_signal_mux.u_signal_mux.w_signal_1;
assign w_signal_2 = tb_signal_mux.u_signal_mux.w_signal_2;
assign w_signal_3 = tb_signal_mux.u_signal_mux.w_signal_3;
assign w_signal_4 = tb_signal_mux.u_signal_mux.w_signal_4;

// Simulacion
initial begin
    // Condiciones iniciales
    reset   = 1'b0;
    sel     = 2'b00;
    clock   = 1'b1; 
    
    #100    reset   = 1'b1;   // Abandonar condicion de reset
    
    // Test de seleccion de señal
    #1000   sel     = 2'b01;
    #1000   sel     = 2'b10;
    #1000   sel     = 2'b11;
    
    #1000 $finish;
end

// Generacion de onda de clock (100MHz)
always
    #5 clock = ~clock;

// Multiplexor de señales generadas
signal_mux #
    (
    .NB_DATA(NB_DATA),
    .NB_SEL(NB_SEL)
    )
u_signal_mux
    (
    .i_clock(clock),
    .i_reset(~reset),
    .i_sel(sel),
    .o_signal(w_signal)
    );

// Filtro FIR de salida multiplexor
fir_filter
u_fir_filter
    (
    .i_clock(clock),
    .i_en(1'b1),
    .i_reset(~reset),
    .i_signal(w_signal),
    .o_signal(w_filtered_signal)
    );

endmodule
