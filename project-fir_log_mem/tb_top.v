/*
 *  Module `tb_top`
 *
 *  Testbench del modulo top, integracion de todos los bloques.
 *
 *  EAMTA 2021 - Digital Design
 *  Trabajo final: Memoria de logueo con filtros FIR y operaciones aritmeticas.
 *  Gonzalo G. Fernandez     28/03/2021
 *  File: tb_top.v
 */

`timescale 1ns/100ps

module tb_top();

// Localparam
localparam NB_ENABLE    = 4;
localparam NB_SEL       = 4;
localparam NB_LOG_DATA  = 16;
localparam NB_ADDR      = 8;

// Vars
reg                         clock;  // Clock del sistema
reg                         reset;  // Señal de reset asincrono
reg     [NB_ENABLE-1 : 0]   enable; // Switch de enable
reg     [NB_SEL-1 : 0]      sel;    // Pulsadores de seleccion
wire                        log_ram_full0;
wire                        log_ram_full1;
wire    [NB_LOG_DATA-1 : 0] log_data_from_ram0;
wire    [NB_LOG_DATA-1 : 0] log_data_from_ram1;

// Variables adicionales para analisis completo
wire    [NB_LOG_DATA-1 : 0] w_data_ram1;
wire    [NB_LOG_DATA/2-1:0] w_data_ram0_lsb;
wire    [NB_LOG_DATA/2-1:0] w_data_ram0_msb;

assign w_data_ram1      = tb_top.u_top.w_data1;
assign w_data_ram0_lsb  = tb_top.u_top.w_filtered_signal0;
assign w_data_ram0_msb  = tb_top.u_top.w_filtered_signal1;

// Simulacion
initial begin
    // Condiciones iniciales
    reset   = 1'b0; 
    clock   = 1'b1;
    enable  = {NB_ENABLE{1'b0}};
    sel     = {NB_SEL{1'b0}};
    
    #50     reset       = 1'b1;     // abandonar estado de reset
    #50     enable[0]   = 1'b1;     // habilitar generacion y filtrado de señal
    #10000  $finish;
end

// Bucle de conmutacion entre operaciones aritmeticas
always begin
    #5000   enable[3] = ~enable[3];
end

// Bucle de seleccion de señales generadas (accion de pulsadores)
integer i;
always begin
    for (i=0; i<NB_SEL; i=i+1) begin
        #500    sel[i] = 1'b1;
        #10     sel[i] = 1'b0;
    end
end

// Bucle de escritura y lectura de memorias BRAM
always begin
    #50     enable[1] = 1'b1;   // habilitar escritura
            enable[2] = 1'b0;   // deshabilitar lectura
    // Esperar memoria llena (cualquiera de las dos ya que se escriben a la vez)
    wait(log_ram_full0 == 1'b1 || log_ram_full1 == 1'b1);
    //@(posedge log_ram_full0 or posedge log_ram_full1);
    #10     enable[1] = 1'b0;   // deshabilitar escritura
    enable[2] = 1'b1;   // comenzar lectura
    #2000;
end

// Generacion de onda de clock (100MHz)
always
    #5 clock = ~clock;

// instancia top
top #
    (
    .NB_ENABLE(NB_ENABLE),
    .NB_SEL(NB_SEL),
    .NB_LOG_DATA(NB_LOG_DATA),
    .NB_ADDR(NB_ADDR)
    )
u_top
    (
    .i_clock(clock),
    .i_reset(reset),
    .i_enable(enable),
    .i_sel(sel),
    .o_log_ram_full0(log_ram_full0),
    .o_log_ram_full1(log_ram_full1),
    .o_log_data_from_ram0(log_data_from_ram0),
    .o_log_data_from_ram1(log_data_from_ram1)
    );

endmodule
