/*
 *  Module `tb_adder_mult`
 *
 *  Testbench del modulo de operacion aritmetica (multiplicacion o adicion).
 *
 *  Para la evaluacion del correcto funcionamiento del modulo se simulo
 *  para distintos formatos de punto fijo de entrada.
 *
 *  EAMTA 2021 - Digital Design
 *  Trabajo final: Memoria de logueo con filtros FIR y operaciones aritmeticas.
 *  Gonzalo G. Fernandez     27/03/2021
 *  File: tb_adder_mult.v
 */

`timescale 1ns/100ps

module tb_adder_mult();

// Localparam
localparam NB_DATA_OUT  = 16;   // Cant. de bits de resultado
localparam NB_DATA0     = 8;    // Cant. de bits dato 0
localparam NBF_DATA0    = 6;    // Cant. de bits fraccionales dato 0
localparam NB_DATA1     = 8;    // Cant. de bits dato 1
localparam NBF_DATA1    = 6;    // Cant. de bits fraccionales dato 1

// Vars
reg                             clock;          // Señal de clock
reg                             reset;          // Señal de reset
reg                             enable;         // Seleccion de adicion o multiplicacion
reg signed  [NB_DATA0-1 : 0]    counter_data0;
reg signed  [NB_DATA1-1 : 0]    counter_data1;
wire        [NB_DATA_OUT-1 : 0] w_data;         // Resultado de operacion aritmetica

// Simulacion
initial begin
    // Condiciones iniciales
    reset   = 1'b0;
    clock   = 1'b1;
    enable  = 1'b0;         // seleccion suma
    
    #50 reset   = 1'b1;     // abandonar estado de reset
    #200 enable  = 1'b1;    // seleccion multiplicacion
    
    #200 $finish;
end

// Generacion de onda de clock (100MHz)
always
    #5 clock = ~clock;


/* LOGICA DE CONTADORES COMO DATOS DE ENTRADA */
always @(posedge clock) begin
    if (reset == 1'b0) begin
        counter_data0 <= {NB_DATA0{1'b0}};
        counter_data1 <= {NB_DATA1{1'b0}};
    end
    else begin
        counter_data0 <= counter_data0 + {{NB_DATA0-2{1'b0}},{1'b1}, {1'b0}};
        counter_data1 <= counter_data1 - {{NB_DATA1-1{1'b0}},{1'b1}};
    end
end

// Intancia de modulo de adicion o multiplicacion
adder_mult #
    (
    .NB_DATA0(NB_DATA0),
    .NBF_DATA0(NBF_DATA0),
    .NB_DATA1(NB_DATA1),
    .NBF_DATA1(NBF_DATA1),
    .NB_DATA_OUT(NB_DATA_OUT)
    )
u_adder_mult
    (
    .i_clock(clock),
    .i_reset(~reset),
    .i_enable(enable),
    .i_data0(counter_data0),
    .i_data1(counter_data1),
    .o_data(w_data)
    );

endmodule
