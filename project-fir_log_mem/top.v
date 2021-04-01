/*
 *  Module `top`
 *
 *  Integracion de dos  generadores y multiplexores de señales con su correspondiente 
 *  filtro FIR, y una BRAM con FSM para el logueo de la concatenacion de señales filtradas 
 *  {dato1[7:0], dato0[7:0]} (16 bits). Ademas se incorpora un bloque de operaciones
 *  aritmeticas que permite la adicion o multiplicacion de la salida de los filtros. 
 *  El resultado de la operacion se memoriza en una BRAM con FSM de 16 bits.
 *  
 *  i_sel[3:0] consiste en entradas de pulsadores,  por lo que se considera su vuelta a 
 *  reposo (modificacion de estado con flanco ascendente). Dicha logica se encuentra en el
 *  modulo `button_logic`. i_sel[1:0] permite la seleccion de señal generada por el primer
 *  modulo `gen_fir`, e i_sel[3:2] permite la seleccion de señal generada por el segundo
 *  modulo `gen_fir`. 
 *  i_enable[3:0] consiste en entrada de switch.
 *  - i_enable[0] permite la habilitacion y deshabilitacion de los modulos `gen_fir` y el 
 *      modulo de operaciones aritmeticas.
 *  - i_enable[1] permite comenzar la escritura en ambos bloques `ram_save` (no se controlan
 *      de forma independiente).
 *  - i_enable[2] habilita o deshabilita el contador de direccion de lectura de ambas BRAM,
 *      con lo que permite la lectura de las memorias.
 *  - i_enable[3] permite la seleccion de la operacion aritmetica a realizar, ya sea 
 *      adicion (0) o multiplicacion (1).
 *
 *  Como en el laboratorio 3, se tienen las mismas salidas asociadas a las memorias: 
 *  *o_log_ram_full* flag que indica que se escribio la memoria completa, y 
 *  *o_log_data_from_ram* que es el dato leido de la memoria
 *
 *  Dependencias: modulo `button_logic`, `gen_fir`, `ram_save` y `adder_mult`.
 *
 *  EAMTA 2021 - Digital Design
 *  Trabajo final: Memoria de logueo con filtros FIR y operaciones aritmeticas.
 *  Gonzalo G. Fernandez     28/03/2021
 *  File: top.v
 */

module top(
    i_clock,
    i_reset,
    i_enable,
    i_sel,
    o_log_ram_full0,
    o_log_ram_full1,
    o_log_data_from_ram0,
    o_log_data_from_ram1
    );

// Params
parameter   NB_SEL      = 4;
parameter   NB_ENABLE   = 4;
parameter   NB_DATA     = 8;
parameter   NBF_DATA    = 6;
parameter   NB_LOG_DATA = 16;
parameter   NB_ADDR     = 10;
parameter RAM_INIT_FILE = "D:\\digital_design_course\\eamta-digital-design\\ram_init16_1024.txt";

// Ports
input                       i_clock;                // System clock
input                       i_reset;                // System reset (async)
input   [NB_ENABLE-1 : 0]   i_enable;               // Enable switch
input   [NB_SEL-1 : 0]      i_sel;                  // Selection buttons
output                      o_log_ram_full0;        // RAM 0 full flag
output                      o_log_ram_full1;        // RAM 1 full flag
output  [NB_LOG_DATA-1 : 0] o_log_data_from_ram0;   // 16 bit loggued data from RAM 0
output  [NB_LOG_DATA-1 : 0] o_log_data_from_ram1;   // 16 bit loggued data from RAM 1

// Vars
reg     [NB_ADDR-1 : 0]     count_read_addr;
wire    [NB_SEL-1 : 0]      w_sel_state;            // Estado pulsadores de seleccion
wire    [NB_DATA-1 : 0]     w_filtered_signal0;     // Señal filtrada 0
wire    [NB_DATA-1 : 0]     w_filtered_signal1;     // Señal filtrada 1
wire    [NB_LOG_DATA-1 : 0] w_data0;                // Data to write in RAM 0
wire    [NB_LOG_DATA-1 : 0] w_data1;                // Data to write in RAM 1

// Logica de pulsadores de seleccion
button_logic #
    (
    .N_BUTTON(NB_SEL)
    )
u_sel_logic
    (
    .i_clock(i_clock),
    .i_reset(~i_reset),
    .i_signal(i_sel),
    .o_state(w_sel_state)
    );

// Bloque generacion y filtrado 0
gen_fir #
    (
    .NB_SEL(NB_SEL/2),
    .NB_DATA_GEN(NB_DATA),
    .NB_DATA_OUT(NB_DATA)
    )
gen_fir0
    (
    .i_clock(i_clock),
    .i_reset(~i_reset),
    .i_enable(i_enable[0]),
    .i_sel(w_sel_state[1:0]),
    .o_signal(w_filtered_signal0)
    );

// Bloque generacion y filtrado 1
gen_fir #
    (
    .NB_SEL(NB_SEL/2),
    .NB_DATA_GEN(NB_DATA),
    .NB_DATA_OUT(NB_DATA)
    )
gen_fir1
    (
    .i_clock(i_clock),
    .i_reset(~i_reset),
    .i_enable(i_enable[0]),
    .i_sel(w_sel_state[3:2]),
    .o_signal(w_filtered_signal1)
    );

/* LOGICA DE DIRECCION LECTURA DE BRAM 0 */
always @(posedge i_clock or negedge i_reset) begin
    if(i_reset == 1'b0) begin   // recordar que top se respeta hardware para señal reset
        count_read_addr <= {NB_ADDR{1'b0}};
    end
    else if (i_enable[2] == 1'b1) begin
        count_read_addr <= count_read_addr + {{NB_ADDR-1{1'b0}},{1'b1}};
    end
    else begin
        count_read_addr <= count_read_addr;
    end
end

// Bloque BRAM con FSM 0
ram_save #
    (
    .NB_ADDR(NB_ADDR),
    .NB_DATA(NB_LOG_DATA),
    .INIT_FILE(RAM_INIT_FILE)
    )
ram_save0
    (
    .out_data_from_ram(o_log_data_from_ram0),   // Output Memory
    .out_full_from_ram(o_log_ram_full0),        // Output Full 
    .in_log_ram_run(i_enable[1]),               // Run log in RAM
    .in_data(w_data0),                          // Data
    .in_ram_read_addr(count_read_addr),         // Read Address
    .ctrl_valid(1'b1),             
    .clock(i_clock),                            //System Clock
    .cpu_reset(~i_reset)                         //System Reset
    );

// Bloque de operaciones aritmeticas entre señales filtradas
adder_mult #
    (
    .NB_DATA0(NB_DATA),
    .NBF_DATA0(NBF_DATA),
    .NB_DATA1(NB_DATA),
    .NBF_DATA1(NBF_DATA),
    .NB_DATA_OUT(NB_LOG_DATA)
    )
u_adder_mult
    (
    .i_clock(i_clock),
    .i_reset(~i_reset),
    .i_enable(i_enable[3]),
    .i_data0(w_filtered_signal0),
    .i_data1(w_filtered_signal1),
    .o_data(w_data1)
    );

// Bloque BRAM con FSM 1
ram_save #
    (
    .NB_ADDR(NB_ADDR),
    .NB_DATA(NB_LOG_DATA),
    .INIT_FILE(RAM_INIT_FILE)
    )
ram_save1
    (
    .out_data_from_ram(o_log_data_from_ram1),   // Output Memory
    .out_full_from_ram(o_log_ram_full1),        // Output Full 
    .in_log_ram_run(i_enable[1]),               // Run log in RAM
    .in_data(w_data1),                          // Data
    .in_ram_read_addr(count_read_addr),         // Read Address
    .ctrl_valid(1'b1),             
    .clock(i_clock),                            //System Clock
    .cpu_reset(~i_reset)                         //System Reset
    );

// Asignacion de data entrada
assign w_data0[NB_LOG_DATA/2-1:0]           = w_filtered_signal0;   // mitad menos significatica señal 0
assign w_data0[NB_LOG_DATA-1:NB_LOG_DATA/2] = w_filtered_signal1;   // mitad mas significativa señal 1

endmodule
