/*
 *  Module `top_vio_ila`
 *
 *  Integracion modulo top con VIO e ILA para implementacion,
 *  control y adquisicion de datos en FPGA remota.
 *
 *  Dependencias: modulo `top` y IPs VIO e ILA.
 *
 *  EAMTA 2021 - Digital Design
 *  Laboratorio 3: Integracion filtro FIR con memoria BRAM.
 *  Gonzalo G. Fernandez     13/03/2021
 *  File: top_vio_ila.v
 */
module top_vio_ila(
        clock     // System clock
    );
    
// Ports
input   clock;

// Vars
wire            reset;              // Señal de reset asincrona
wire    [2:0]   enable;             // Entrada de habilitacion de modulos (switch)
wire    [1:0]   sel;                // Entrada de seleccion de señal (pulsadores)
wire            log_ram_full;       // Flag de BRAM llena
wire    [15:0]  log_data_from_ram;  // Dato leido de BRAM

// Instancia top
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

// Instancia VIO
vio
vio_0
    (
    .clk_0(clock),
    .probe_in0_0(log_data_from_ram),
    .probe_in1_0(log_ram_full),
    .probe_out0_0(reset),
    .probe_out1_0(enable),
    .probe_out2_0(sel)
    );

// Instancia ILA
ila_0
u_ila_0
    (
    .clk(clock),
    .probe0(log_data_from_ram),
    .probe1(log_ram_full)
    );

endmodule
