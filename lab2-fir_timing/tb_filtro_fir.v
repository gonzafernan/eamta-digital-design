/*
 *  Module `tb_filtro_fir`
 *
 *  Testbench para verificacion del correcto funcionamiento del filtro FIR.
 *  La generacion de señal se basa en una onda senoidal compuesta por dos 
 *  frecuencias f1=17kHz y f2=1,5kHz. La frecuencia de corte del filtro es 
 *  de 6kHz.
 *
 *  EAMTA 2021 - Digital Design
 *  Laboratorio 2: Filtro FIR y analisis de reportes de timing.
 *  Gonzalo G. Fernandez     09/03/2021
 *  File: tb_filtro_fir.v
 */

`define NB_DATA     8
`define NB_COUNT    10 

`timescale 1ns/100ps

module tb_filtro_fir();
   
   parameter NB_DATA        = `NB_DATA      ;
   parameter NB_COUNT       = `NB_COUNT     ;
   parameter MEM_INIT_FILE  = "D:\\digital_design_course\\eamta-digital-design\\lab2-fir_timing\\mem.hex";
   
   wire [NB_DATA-1 : 0]     w_signal            ;   // Noisy signal
   wire [NB_DATA-1 : 0]     w_filtered_signal   ;   // Filtered signal
   reg                      i_en                ;   // Filter enable
   reg                      i_reset             ;
   reg                      clock               ;

   initial begin
      // Condiciones iniciales
      clock             = 1'b0  ;
      i_reset           = 1'b1  ;
      i_en              = 1'b0  ;
       
      #100 i_reset      = 1'b0   ;       // abandonar el estado de reset
      #10000 i_en       = 1'b1   ;       // habilitacion del filtro

      #10000 $finish;
   end

   always #5 clock = ~clock;    // clock signal

signal_generator
    #(
    .MEM_INIT_FILE  (MEM_INIT_FILE),
    .NB_COUNT       (NB_COUNT)
    )
    u_signal_generator
    (
    .i_clock    (clock)     ,
    .i_reset    (i_reset)   ,
    .o_signal   (w_signal)
    );

filtro_fir
    u_filtro_fir
    (
    .clk    (clock)             ,
    .i_srst (i_reset)           ,
    .i_en   (i_en)              ,
    .i_data (w_signal)          ,
    .o_data (w_filtered_signal)
    );

endmodule // tb_filtro_fir
