/*
 *  Module `signal_generator`
 *
 *  Generacion de señal a partir de archivo con 1024 valores.
 *
 *  Modificaciones: Ruta de archivo vacia, por lo que es necesario
 *  modificar parametro MEM_INIT_FILE con el archivo a general 
 *  al instanciar el modulo. Eliminacion de parametro NB_SEL.
 *  Se añadio una entrada que permite habilitacion y
 *  deshabilitacion del modulo. En estado deshabilitado se conserva
 *  el ultimo valor generado.
 *
 *  EAMTA 2021 - Digital Design
 *  Laboratorio 3: Integracion filtro FIR con memoria BRAM.
 *  Gonzalo G. Fernandez     10/03/2021
 *  File: signal_generator.v
 */

module signal_generator(
        i_clock,
        i_reset,
        i_en, 
        o_signal
    );
    
// Parameters
parameter NB_DATA   = 8;
parameter NB_COUNT  = 10;
parameter MEM_INIT_FILE = "";

// Ports
input                           i_clock;
input                           i_reset;
input                           i_en;
output  signed  [NB_DATA-1 : 0] o_signal;

// Vars
reg [NB_COUNT-1 : 0]    counter;
reg [NB_DATA-1 : 0]     data[1023:0];

// Signal file read
initial begin
    if (MEM_INIT_FILE != "") begin
        $readmemh(MEM_INIT_FILE, data);
    end    
end

// Counter logic
always @(posedge i_clock or posedge i_reset) begin
    if (i_reset == 1'b1) begin
        counter <= {NB_COUNT{1'b0}};
    end
    else if (i_en == 1'b1) begin
        counter <= counter + {{NB_COUNT-1{1'b0}}, {1'b1}};
    end
    else begin
        counter <= counter;
    end
end

assign o_signal = data[counter];
    
endmodule
