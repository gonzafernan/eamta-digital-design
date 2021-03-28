/*
 *  Module `tb_ram_save`
 *
 *  Testbench de BRAM y FSM.
 *  Integración de BRAM con FSM. La informacion se recibe de un contador.
 *
 *  EAMTA 2021 - Digital Design
 *  Trabajo final. Idem. Laboratorio 3.
 *  Gonzalo G. Fernandez     12/03/2021
 *  File: tb_ram_save.v
 */

`timescale 1ns/100ps

module tb_ram_save();

// Params
parameter NB_DATA       = 16;
parameter NB_ADDR       = 10;
parameter RAM_INIT_FILE = "D:\\digital_design_course\\eamta-digital-design\\lab3-fir_bram\\ram_init16_1024.txt";

// Vars
reg                     clock;              // Señal de clock
reg                     reset;              // Señal de reset
reg                     log_out_ram_run;    // Habilitar lectura de datos
reg                     log_in_ram_run;     // Habilitar escritura de datos
reg     [NB_ADDR-1 : 0] count_read_addr;
reg     [NB_DATA-1 : 0] counter_data;
wire    [NB_DATA-1 : 0] log_data_from_ram;
wire                    log_ram_full;       // BRAM full

// Simulacion
initial begin
    // Condiciones iniciales
    reset           = 1'b0;
    log_in_ram_run  = 1'b0;
    log_out_ram_run = 1'b0;
    clock           = 1'b1;
    
    #100    reset   = 1'b1;   // Abandonar condicion de reset
    
    // Test de escritura
    #100    log_in_ram_run  = 1'b1;     
    while (log_ram_full == 1'b0) begin  // Escribir hasta llenar BRAM
        #10;
    end
    #100    log_in_ram_run  = 1'b0;
    
    // Test de lectura
    #100    log_out_ram_run = 1'b1;
    #20000  log_out_ram_run = 1'b0;
    
    #500    $finish;
end

// Generacion de onda de clock (100MHz)
always
    #5 clock = ~clock;

/* LOGICA DE CONTADOR COMO INFORMACION A ESCRIBIR*/
always @(posedge clock) begin
    if (reset == 1'b0) begin
        counter_data <= {NB_DATA{1'b0}};
    end
    else begin
        counter_data <= counter_data + {{NB_DATA-1{1'b0}},{1'b1}};
    end
end

/* LOGICA DE DIRECCION LECTURA DE BRAM */
always @(posedge clock) begin
    if(reset == 1'b0) begin
        count_read_addr <= {NB_ADDR{1'b0}};
    end
    else if (log_out_ram_run == 1'b1) begin
        count_read_addr <= count_read_addr + {{NB_ADDR-1{1'b0}},{1'b1}};
    end
    else begin
        count_read_addr <= count_read_addr;
    end
end

// Bloque BRAM con FSM
ram_save #
    (
    .NB_ADDR(NB_ADDR),
    .NB_DATA(NB_DATA),
    .INIT_FILE(RAM_INIT_FILE)
    )
u_ram_save
    (
    .out_data_from_ram(log_data_from_ram),      // Output Memory
    .out_full_from_ram(log_ram_full),           // Output Full 
    .in_log_ram_run(log_in_ram_run),            // Run log in RAM
    .in_data(counter_data),                     // Data
    .in_ram_read_addr(count_read_addr),         // Read Address
    .ctrl_valid(1'b1),             
    .clock(clock),                              //System Clock
    .cpu_reset(~reset)                          //System Reset
    );

endmodule
