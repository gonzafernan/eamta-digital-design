/*
 *  Module `signal_mux`
 *
 *  Generador y selector de señales.
 *
 *  Se generan las siguientes 4 señales con sus correspondientes archivos .hex:
 *  - Señal 1: f1=1,5kHz y f2=17kHz (mem17khz.hex)
 *  - Señal 2: f1=1,5kHz y f2=8,5kHz (mem17khz.hex)
 *  - Señal 3: f1=1,5kHz y f2=5,66kHz (mem17khz.hex)
 *  - Señal 4: f1=1,5kHz y f2=4,25kHz (mem17khz.hex)
 *  Luego dichas señales son entrada de un multiplexor que permite la seleccion
 *  de una de ellas segun i_sel[1:0].
 *  i_en permite la habilitacion y deshabilitacion de la generacion de señales.
 *  Estando deshabilitado la señal conserva el ultimo valor, y aun se puede 
 *  realizar cambios en la seleccion de señal.
 *
 *  Dependencias: modulo `signal_generator`
 *
 *  EAMTA 2021 - Digital Design
 *  Laboratorio 3: Integracion filtro FIR con memoria BRAM.
 *  Gonzalo G. Fernandez     10/03/2021
 *  File: signal_mux.v
 */

module signal_mux(
        i_clock,
        i_reset,
        i_sel,
        i_en,
        o_signal
    );

// Parameters
parameter NB_DATA   = 8;
parameter NB_COUNT  = 10;
parameter NB_SEL    = 2;

// Signals files
parameter MEM_SIG1_FILE = "D:\\digital_design_course\\eamta-digital-design\\signals\\mem17khz.hex";
parameter MEM_SIG2_FILE = "D:\\digital_design_course\\eamta-digital-design\\signals\\mem8p5khz.hex";
parameter MEM_SIG3_FILE = "D:\\digital_design_course\\eamta-digital-design\\signals\\mem5p666khz.hex";
parameter MEM_SIG4_FILE = "D:\\digital_design_course\\eamta-digital-design\\signals\\mem4p25khz.hex";

// Ports
input                               i_clock;
input                               i_reset;
input           [NB_SEL-1 : 0]      i_sel;
input                               i_en;
output  signed  [NB_DATA-1 : 0]     o_signal;

// Vars
reg     signed  [NB_DATA-1 : 0]     w_signal;   // mux output signal
wire    signed  [NB_DATA-1 : 0]     w_signal_1;
wire    signed  [NB_DATA-1 : 0]     w_signal_2;
wire    signed  [NB_DATA-1 : 0]     w_signal_3;
wire    signed  [NB_DATA-1 : 0]     w_signal_4;

// Signal 1 generation
signal_generator #
    (
    .NB_DATA(NB_DATA),
    .NB_COUNT(NB_COUNT),
    .MEM_INIT_FILE(MEM_SIG1_FILE)
    )
u_signal_gen_1
    (
    .i_clock(i_clock),
    .i_reset(i_reset),
    .i_en(i_en), 
    .o_signal(w_signal_1)
    );

// Signal 2 generation
signal_generator #
    (
    .NB_DATA(NB_DATA),
    .NB_COUNT(NB_COUNT),
    .MEM_INIT_FILE(MEM_SIG2_FILE)
    )
u_signal_gen_2
    (
    .i_clock(i_clock),
    .i_reset(i_reset),
    .i_en(i_en),  
    .o_signal(w_signal_2)
    );

// Signal 3 generation
signal_generator #
    (
    .NB_DATA(NB_DATA),
    .NB_COUNT(NB_COUNT),
    .MEM_INIT_FILE(MEM_SIG3_FILE)
    )
u_signal_gen_3
    (
    .i_clock(i_clock),
    .i_reset(i_reset),
    .i_en(i_en),  
    .o_signal(w_signal_3)
    );

// Signal 4 generation
signal_generator #
    (
    .NB_DATA(NB_DATA),
    .NB_COUNT(NB_COUNT),
    .MEM_INIT_FILE(MEM_SIG4_FILE)
    )
u_signal_gen_4
    (
    .i_clock(i_clock),
    .i_reset(i_reset),
    .i_en(i_en),  
    .o_signal(w_signal_4)
    );

// Multiplexer 4-to-1 (Language templates/Vivado)
always @(posedge i_clock) begin
    case (i_sel)
        2'b00: w_signal <= w_signal_1;
        2'b01: w_signal <= w_signal_2;
        2'b10: w_signal <= w_signal_3;
        2'b11: w_signal <= w_signal_4;
    endcase
end

assign o_signal = w_signal;

endmodule
