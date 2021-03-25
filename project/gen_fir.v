/*
 *  Module `gen_fir`
 *
 *  Integracion multiplexor de señales con filtro FIR.
 *  i_enable permite la habilitacion o deshabilitacion del modulo.
 *  i_sel permite la seleccion de señal generada (logica de estado
 *  alto o bajo, no de flanco).
 *
 *  Dependencias: modulos `signal_mux` y `fir_filter`.
 *
 *  EAMTA 2021 - Digital Design
 *  Trabajo Final.
 *  Gonzalo G. Fernandez     24/03/2021
 *  File: gen_fir.v
 */

module gen_fir(
    i_clock,
    i_reset,
    i_enable,
    i_sel,
    o_signal
    );
    
// Params
parameter   NB_SEL      = 2;    // Cant. de bits de seleccion
parameter   NB_DATA_GEN = 8;    // Cant. de bits data señal generada
parameter   NB_DATA_OUT = 8;    // Cant. de bits señal de salida (filtrada)
    
// Ports
input                       i_clock;    // System clock
input                       i_reset;    // System reset (async)
input                       i_enable;   // Module enable signal
input   [NB_SEL-1 : 0]      i_sel;      // Signal selection input
output  [NB_DATA_OUT-1 : 0] o_signal;   // Filtered signal (module output)

// Vars
wire    [NB_DATA_GEN-1 : 0] w_mux_signal;   // Salida multiplexor (entrada filtro)

// Multiplexor de señales generadas
signal_mux #
    (
    .NB_DATA(NB_DATA_GEN),
    .NB_SEL(NB_SEL)
    )
u_signal_mux
    (
    .i_clock(i_clock),
    .i_reset(i_reset),
    .i_sel(i_sel),
    .i_en(i_enable),
    .o_signal(w_mux_signal)
    );

// Filtro FIR de señal generada, salida mux
fir_filter #
    (
    .WW_INPUT(NB_DATA_GEN),
    .WW_OUTPUT(NB_DATA_OUT)
    )
u_fir_filter
    (
    .i_clock(i_clock),
    .i_en(i_enable),
    .i_reset(i_reset),
    .i_signal(w_mux_signal),
    .o_signal(o_signal)
    );

endmodule
