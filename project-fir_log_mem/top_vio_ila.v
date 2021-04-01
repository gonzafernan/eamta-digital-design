/*
 *  Module `top`
 *
 *  Integracion de diseño top con IPs VIO e ILA para facilitar control de diseño
 *  al utilizar hardware de manera remota.
 *
 *  Dependencias: modulo `top` e IPs VIO e ILA.
 *
 *  EAMTA 2021 - Digital Design
 *  Trabajo final: Memoria de logueo con filtros FIR y operaciones aritmeticas.
 *  Gonzalo G. Fernandez     01/04/2021
 *  File: top_vio_ila.v
 */

module top_vio_ila(
        clock
    );

// Ports    
input   clock;

// Vars
wire            reset;
wire    [3:0]   enable;
wire    [3:0]   sel;
wire            log_ram_full0;
wire            log_ram_full1;
wire    [15:0]  log_data_from_ram0;
wire    [15:0]  log_data_from_ram1;

// Instancia VIO
vio
u_vio
    (
    .clk_0(clock),
    .probe_in0_0(log_ram_full0),
    .probe_in1_0(log_ram_full1),
    .probe_in2_0(log_data_from_ram0),
    .probe_in3_0(log_data_from_ram1),
    .probe_out0_0(reset),
    .probe_out1_0(enable),
    .probe_out2_0(sel)
    );

// Instancia ILA
ila_0
u_ila_0
    (
    .clk(clock),
    .probe0(log_ram_full0),
    .probe1(log_ram_full1),
    .probe2(log_data_from_ram0),
    .probe3(log_data_from_ram1)
    );

// Instancia top
top
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
