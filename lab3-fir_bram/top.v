/*
 *  Module `top`
 *
 *  Integracion multiplexor de señales, filtro y BRAM con FSM.
 *  i_sel[1:0] permite la seleccion de señal generada. Consiste
 *  en botones, por lo que se considera su vuelta a reposo (modificacion
 *  de estado con flanco ascendente).
 *
 *  Dependencias: modulo `signal_mux`
 *
 *  EAMTA 2021 - Digital Design
 *  Laboratorio 3: Integracion filtro FIR con memoria BRAM.
 *  Gonzalo G. Fernandez     12/03/2021
 *  File: top.v
 */

module top(
        i_clock,
        i_reset,
        i_enable,
        i_sel,
        o_log_ram_full,
        o_log_data_from_ram
    );

// Params
parameter NB_SEL        = 2;    // Cant. bits de seleccion señal generada
parameter NB_DATA       = 8;    // Cant. bits dato señal generada (hex 8 bits en archivo formato S(8, 6))
parameter NB_FILTER_OUT = 16;   // Cant. bits de salida del filtro FIR (formato S(16, 14))
parameter NB_ADDR       = 10;
parameter RAM_INIT_FILE = "D:\\digital_design_course\\eamta-digital-design\\lab3-fir_bram\\ram_init16_1024.txt";

// Ports
input                           i_clock;                // System clock
input                           i_reset;                // System reset (async)
input   [2:0]                   i_enable;               // Enable switches
input   [NB_SEL-1 : 0]          i_sel;                  // Selection buttons
output                          o_log_ram_full;         // RAM full flag
output  [NB_FILTER_OUT-1 : 0]   o_log_data_from_ram;    // 16 bit loggued data

// Vars
integer i;  // Loop var
reg             [NB_SEL-1 : 0]          state_sel;          // Estado de seleccion
reg             [NB_SEL-1 : 0]          prev_sel;           // Estado previo de seleccion
wire    signed  [NB_DATA-1 : 0]         w_signal;           // Salida multiplexor
wire    signed  [NB_FILTER_OUT-1 : 0]   w_filtered_signal;  // Salida filtro FIR
reg             [NB_ADDR-1 : 0]         count_read_addr;    // Direccion de lectura BRAM (valor contador)

/* LOGICA DE SELECCION SEÑAL GENERADA */
always @(posedge i_clock or posedge i_reset) begin
    // reset state
    if (i_reset) begin
        prev_sel <= {NB_SEL{1'b0}};
        state_sel <= {NB_SEL{1'b0}};    // Sel0 (signal 1)
    end
    else begin
        // logica de boton
        // registrar estado de todos los botones para comparacion en siguiente clock
        prev_sel <= i_sel;
        // deteccion de flanco de subida
        for (i=0; i<NB_SEL; i=i+1) begin
            if (i_sel[i] && prev_sel[i]==1'b0) begin
                state_sel[i] <= ~state_sel[i];
            end
        end
    end
end

/* LOGICA DE DIRECCION LECTURA DE BRAM */
always @(posedge i_clock) begin
    if(i_reset == 1'b1) begin
        count_read_addr <= {NB_ADDR{1'b0}};
    end
    else if (i_enable[2] == 1'b1) begin
        count_read_addr <= count_read_addr + {{NB_ADDR-1{1'b0}},{1'b1}};
    end
    else begin
        count_read_addr <= count_read_addr;
    end
end

// Multiplexor de señales generadas
signal_mux
u_signal_mux
    (
    .i_clock(i_clock),
    .i_reset(i_reset),
    .i_sel(state_sel),
    .i_en(i_enable[0]),
    .o_signal(w_signal)
    );
    
// Filtro FIR a salida de multiplexor
fir_filter #
    (
    .WW_INPUT(NB_DATA),
    .WW_OUTPUT(NB_FILTER_OUT)
    )
u_fir_filter
    (
    .i_clock(i_clock),
    .i_en(i_enable[0]),
    .i_reset(i_reset),
    .i_signal(w_signal),
    .o_signal(w_filtered_signal)
    );

// Bloque BRAM con FSM
ram_save #
    (
    .NB_ADDR(NB_ADDR),
    .NB_DATA(NB_FILTER_OUT),
    .INIT_FILE(RAM_INIT_FILE)
    )
u_ram_save
    (
    .out_data_from_ram(o_log_data_from_ram),    // Output Memory
    .out_full_from_ram(o_log_ram_full),         // Output Full 
    .in_log_ram_run(i_enable[1]),               // Run log in RAM
    .in_data(w_filtered_signal),                // Data
    .in_ram_read_addr(count_read_addr),         // Read Address
    .ctrl_valid(1'b1),             
    .clock(i_clock),                            //System Clock
    .cpu_reset(i_reset)                         //System Reset
    );

endmodule
