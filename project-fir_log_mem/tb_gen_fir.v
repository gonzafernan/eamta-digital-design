/*
 *  Module `tb_gen_fir`
 *
 *  Testbench del multiplexor de señales generadas.
 *  Integracion con filtro FIR para señal seleccionada.
 *
 *  EAMTA 2021 - Digital Design
 *  Trabajo final.
 *  Gonzalo G. Fernandez     25/03/2021
 *  File: tb_gen_fir.v
 */

`timescale 1ns/100ps

module tb_gen_fir();

// Parameters
parameter NB_DATA       = 8;
parameter NB_SEL        = 2;

// Vars
reg                                     clock;              // Señal de clock
reg                                     reset;              // Señal de reset
reg             [NB_SEL-1 : 0]          sel;                // Seleccion de señal
reg                                     enable;             // Habilitacion de modulos
wire    signed  [NB_DATA-1 : 0]         w_signal;           // Salida de modulo gen_fir

// Señales generadas
wire    signed  [NB_DATA-1 : 0]  w_signal_1;
wire    signed  [NB_DATA-1 : 0]  w_signal_2;
wire    signed  [NB_DATA-1 : 0]  w_signal_3;
wire    signed  [NB_DATA-1 : 0]  w_signal_4;
wire    signed  [NB_DATA-1 : 0]  w_mux_signal;

assign w_signal_1   = tb_gen_fir.u_gen_fir.u_signal_mux.w_signal_1;
assign w_signal_2   = tb_gen_fir.u_gen_fir.u_signal_mux.w_signal_2;
assign w_signal_3   = tb_gen_fir.u_gen_fir.u_signal_mux.w_signal_3;
assign w_signal_4   = tb_gen_fir.u_gen_fir.u_signal_mux.w_signal_4;
assign w_mux_signal = tb_gen_fir.u_gen_fir.w_mux_signal;

// Simulacion
initial begin
    // Condiciones iniciales
    reset   = 1'b0;
    sel     = 2'b00;
    enable  = 1'b1;
    clock   = 1'b1; 
    
    #100    reset   = 1'b1;   // Abandonar condicion de reset
    
    // Test de seleccion de señal
    #1000   sel     = 2'b01;
    #1000   sel     = 2'b10;
    #1000   sel     = 2'b11;
    
    // Test de habilitacion/deshabilitacion
    #1000   enable  = 1'b0;
    #500    enable  = 1'b1;
    
    #500 $finish;
end

// Generacion de onda de clock (100MHz)
always
    #5 clock = ~clock;

gen_fir #
    (
    .NB_SEL(NB_SEL),
    .NB_DATA_GEN(NB_DATA),
    .NB_DATA_OUT(NB_DATA)
    )
u_gen_fir
    (
    .i_clock(clock),
    .i_reset(~reset),
    .i_enable(enable),
    .i_sel(sel),
    .o_signal(w_signal)
    );

endmodule
