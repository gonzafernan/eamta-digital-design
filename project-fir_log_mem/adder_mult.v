/*
 *  Module `adder_mult`
 *
 *  Operacion aritmetica (multiplicacion o adicion) entre dos datos de entrada.
 *  Si la señal de enable se encuentra en 0 los datos se suman, si se encuentra 
 *  en 1 se multiplican.
 *
 *  El modulo se plantea de tal forma de poder recibir datos de entrada con 
 *  igual o distinto formato de punto fijo (siempre signado). Por lo tanto,
 *  la mayor dificultad en su implementacion es la alineacion generica de la
 *  coma, con la correspondiente expansion de signo y completado con 0, 
 *  necesario para efectuar correctamente la suma.
 *
 *  Es importante tener en cuenta el formato de punto fijo del resultado, ya
 *  que dependera de los datos de entrada. En general, el resultado de la
 *  multiplicacion tendra una cantidad de bits fraccionales igual a la suma de
 *  los bits fraccionales de entrada, y el resultado de la suma tendra una
 *  cantidad de bits fraccionales igual a la del dato de entrada con mayor cantidad
 *  de bits fraccionales. 
 *
 *  Tambien se debe tener en cuenta que al pasar como parametro la cantidad de bits 
 *  de salida (NB_DATA_OUT) sean por lo menos suficientes para  contener el resultado 
 *  de la multiplicacion, es decir, la suma de los bits de entrada. Luego el resultado 
 *  de la suma, con una cantidad de bits igual (o un bit mas) a la del dato de entrada
 *  con mayor cantidad de bits, se alineara con los bits menos significativos del 
 *  puerto de salida. 
 *
 *  EAMTA 2021 - Digital Design
 *  Trabajo final: Memoria de logueo con filtros FIR y operaciones aritmeticas.
 *  Gonzalo G. Fernandez     27/03/2021
 *  File: adder_mult.v
 */

module adder_mult(
        i_clock,
        i_reset,
        i_enable,
        i_data0,
        i_data1,
        o_data
    );

// Parameters
parameter NB_DATA0      = 8;    // Cant. de bits de dato 0
parameter NBF_DATA0     = 6;    // Cant. de bits fraccionales de dato 0
parameter NB_DATA1      = 8;    // Cant. de bits de dato 1
parameter NBF_DATA1     = 6;    // Cant. de bits fraccionales de dato 0
parameter NB_DATA_OUT   = 16;   // Cant. de bits de resultado

// Localparam
localparam NBI_DATA0    = NB_DATA0 - NBF_DATA0; // Cant. de bits enteros de dato 0
localparam NBI_DATA1    = NB_DATA1 - NBF_DATA1; // Cant. de bits enteros de dato 1

// Ports
input                                   i_clock;    // Clock del sistema
input                                   i_reset;    // Reset asincrono
input                                   i_enable;   // Multiplicacion o adicion
input       signed  [NB_DATA0-1 : 0]    i_data0;    // Dato o sumar o multiplicar
input       signed  [NB_DATA1-1 : 0]    i_data1;    // Dato a sumar o multiplicar
output  reg signed  [NB_DATA_OUT-1 : 0] o_data;     // Resultado de operacion aritmetica
    
// Vars
// Estructura de dato segun formato punto fijo para suma
                // condicion bits enteros y bits fraccionales mayores en data 0
wire signed [(  (NBI_DATA1 <= NBI_DATA0 && NBF_DATA1 <= NBF_DATA0) ? NB_DATA0-1 :
                // condicion bits enteros de data 0 y bits fraccionales de data 1
                (NBI_DATA1 <= NBI_DATA0 && NBF_DATA0 <= NBF_DATA1) ? NBI_DATA0+NBF_DATA1-1 :
                // condicion bits enteros de data 1 y bits fraccionales de data 0
                (NBI_DATA0 <= NBI_DATA1 && NBF_DATA1 <= NBF_DATA0) ? NBI_DATA1+NBF_DATA0-1 :
                // condicion bits enteros y bits fraccionales mayores en data 1
                NB_DATA1-1 ) 
            : 0] w_data0;
                
                // condiciones idem. w_data0
wire signed [(  (NBI_DATA1 <= NBI_DATA0 && NBF_DATA1 <= NBF_DATA0) ? NB_DATA0-1 :
                (NBI_DATA1 <= NBI_DATA0 && NBF_DATA0 <= NBF_DATA1) ? NBI_DATA0+NBF_DATA1-1 :
                (NBI_DATA0 <= NBI_DATA1 && NBF_DATA1 <= NBF_DATA0) ? NBI_DATA1+NBF_DATA0-1 :
                NB_DATA1-1 ) : 0] w_data1;
 
                    // condicion bits enteros y bits fraccionales mayores en data 0
                    // asignacion igual a entrada
assign w_data0 =    (NBI_DATA1 <= NBI_DATA0 && NBF_DATA1 <= NBF_DATA0) ? i_data0 :
                    // condicion bits enteros de data 0 y bits fraccionales de data 1
                    // completar con 0 detras
                    (NBI_DATA1 <= NBI_DATA0 && NBF_DATA0 <= NBF_DATA1) ? {i_data0, {NBF_DATA1-NBF_DATA0{1'b0}}} :
                    // condicion bits enteros de data 1 y bits fraccionales de data 0
                    // expansion de signo
                    (NBI_DATA0 <= NBI_DATA1 && NBF_DATA1 <= NBF_DATA0) ? {{NBI_DATA1-NBI_DATA0{i_data0[NB_DATA0-1]}}, i_data0} :
                    // condicion bits enteros y bits fraccionales mayores en data 1
                    // expansion de signo y completar con 0 detras
                    {{NBI_DATA1-NBI_DATA0{i_data0[NB_DATA0-1]}}, i_data0, {NBF_DATA1-NBF_DATA0{1'b0}}}; 
  
                    // condiciones idem. w_data0         
                    // expansion de signo y completar con 0 detras         
assign w_data1 =    (NBI_DATA1 <= NBI_DATA0 && NBF_DATA1 <= NBF_DATA0) ? {{NBI_DATA0-NBI_DATA1{i_data1[NB_DATA1-1]}},i_data1,{NBF_DATA0-NBF_DATA1{1'b0}}} :
                    // expansion de signo
                    (NBI_DATA1 <= NBI_DATA0 && NBF_DATA0 <= NBF_DATA1) ? {{NBI_DATA0-NBI_DATA1{i_data1[NB_DATA1-1]}}, i_data1} :
                    // completar con 0 detras
                    (NBI_DATA0 <= NBI_DATA1 && NBF_DATA1 <= NBF_DATA0) ? {i_data1, {NBF_DATA0-NBF_DATA1{1'b0}}} :
                    // asignacion igual a entrada
                    i_data1; 
 
/*  
//  Se planteo la alineacion para suma con punto fijo con generate, 
//  pero el problema era el scope de las variables al declararlas.

generate
    // cant. de bits enteros
    if (NBI_DATA1 <= NBI_DATA0) begin
        // cant. de bits fraccional
        if (NBF_DATA1 <= NBF_DATA0) begin           // dato 0 con nbi y nbf mayor
            wire signed [NB_DATA0-1 : 0]  w_data0;
            wire signed [NB_DATA0-1 : 0]  w_data1;
            assign w_data0 = i_data0;
            // Expansion de signo de data 1, y se completa con 0 detras
            assign w_data1 = {{NBI_DATA0-NBI_DATA1{i_data1[NB_DATA1-1]}},i_data1,{NBF_DATA0-NBF_DATA1{1'b0}}};
        end
        else begin                                  // nbi de dato 0 y nbf de dato 1
            wire signed [NBI_DATA0+NBF_DATA1-1 : 0]  w_data0;
            wire signed [NBI_DATA0+NBF_DATA1-1 : 0]  w_data1;
            // Completar con 0 detras
            assign w_data0 = {i_data0, {NBF_DATA1-NBF_DATA0{1'b0}}};
            // Expansion de signo
            assign w_data1 = {{NBI_DATA0-NBI_DATA1{i_data1[NB_DATA1-1]}}, i_data1};
        end
    end
    // cant. de bits enteros
    else begin
        // cant. de bits fraccional
        if (NBF_DATA1 <= NBF_DATA0) begin           // nbi de dato 1 y nbf de dato 0
            wire signed [NBI_DATA1+NBF_DATA0-1 : 0]  w_data0;
            wire signed [NBI_DATA1+NBF_DATA0-1 : 0]  w_data1;
            // Expansion de signo
            assign w_data0 = {{NBI_DATA1-NBI_DATA0{i_data0[NB_DATA0-1]}}, i_data0};
            // Completar con 0 detras
            assign w_data1 = {i_data1, {NBF_DATA0-NBF_DATA1{1'b0}}};
        end
        else begin                                  // dato 1 con nbi y nbf mayor
            wire signed [NB_DATA1-1 : 0]  w_data0;
            wire signed [NB_DATA1-1 : 0]  w_data1;
            // Expansion de signo y completar con 0 detras
            assign w_data0 = {{NBI_DATA1-NBI_DATA0{i_data0[NB_DATA0-1]}}, i_data0, {NBF_DATA1-NBF_DATA0{1'b0}}};
            assign w_data1 = i_data1;
        end
    end
endgenerate
*/

// Operaciones aritemeticas: Suma y multiplicacion
always @(posedge i_clock or posedge i_reset) begin
    if (i_reset == 1'b1) begin
        o_data <= {NB_DATA_OUT{1'b0}};    // estado reset salida 0
    end
    else begin
        // multiplexor de operacion aritmetica
        if (i_enable == 1'b0) begin
            o_data <= w_data0 + w_data1;
        end
        else begin
            o_data <= i_data0 * i_data1;
        end
    end
end

endmodule
