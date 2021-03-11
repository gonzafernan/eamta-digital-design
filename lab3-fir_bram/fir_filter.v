/*
 *  Module `fir_filter`
 *
 *  Filtro FIR.
 *
 *  Modificaciones: Cambio en nombres de puertos. Incorporacion
 *  de bucles iterativos para simplificar codigo.
 *
 *  EAMTA 2021 - Digital Design
 *  Laboratorio 3: Integracion filtro FIR con memoria BRAM.
 *  Gonzalo G. Fernandez     10/03/2021
 *  File: fir_filter.v
 */

module fir_filter(
        i_clock,
        i_en,
        i_reset,
        i_signal,
        o_signal
    );

// Parameters
parameter WW_INPUT   = 8;
parameter WW_OUTPUT  = 8;

// Ports
input                               i_clock;
input                               i_en;
input                               i_reset;
input   signed [WW_INPUT-1 : 0]     i_signal;
output  signed [WW_OUTPUT-1 : 0]    o_signal;

// Local parameters
localparam WW_COEFF = 8;

// Vars
integer i;      // iter loop var
genvar  igen;   // gen loop var 

// Internal Signals
reg     signed [WW_INPUT-1 : 0]             register    [14:1];
wire    signed [WW_COEFF-1 : 0]             coeff       [14:0];
wire    signed [WW_INPUT+WW_COEFF-1 : 0]    prod        [14:0];
wire    signed [WW_INPUT+WW_COEFF+1-1 : 0]  sum         [8:1]; 
wire    signed [WW_INPUT+WW_COEFF+2-1 : 0]  sum1        [4:1]; 
wire    signed [WW_INPUT+WW_COEFF+3-1 : 0]  sum2        [2:1]; 
wire    signed [WW_INPUT+WW_COEFF+4-1 : 0]  sum3; 
reg     signed [WW_INPUT+WW_COEFF-1 : 0]    prod_d      [14:0];
reg     signed [WW_INPUT+WW_COEFF+4-1 : 0]  sum3_d;
reg     signed [WW_INPUT+WW_COEFF+1-1 : 0]  sum_d       [8:1];

// Filter coeffs fcut=6kHz
assign coeff[ 0] = 8'hFF;
assign coeff[ 1] = 8'hFF;
assign coeff[ 2] = 8'hFF;
assign coeff[ 3] = 8'h00;
assign coeff[ 4] = 8'h03;
assign coeff[ 5] = 8'h08;
assign coeff[ 6] = 8'h0D;
assign coeff[ 7] = 8'h10;
assign coeff[ 8] = 8'h0D;
assign coeff[ 9] = 8'h08;
assign coeff[10] = 8'h03;
assign coeff[11] = 8'h00;
assign coeff[12] = 8'hFF;
assign coeff[13] = 8'hFF;
assign coeff[14] = 8'hFF;

// Shift Register
always @(posedge i_clock) begin
    if (i_reset == 1'b1) begin
        for (i=1; i<=14; i=i+1) begin
            register[i] <= {WW_INPUT{1'b0}}; // registros en 0 si reset
        end
    end 
    else begin
        if (i_en == 1'b1) begin
            register[ 1] <= i_signal;
            for (i=2; i<=14; i=i+1) begin
                register[i] <= register[i-1];
            end
        end
    end
end

// Products
generate
    assign prod[ 0] = coeff[ 0] * i_signal;
    for (igen=1; igen<=14; igen=igen+1) begin
        assign prod[igen] = coeff[igen] * register[igen];
    end
endgenerate

always @(posedge i_clock) begin
    for (i=0; i<=14; i=i+1) begin
        prod_d[i] <= prod[i];
    end
end

// Adders
assign sum[ 1] = prod_d[ 0] + prod_d[ 1];   //16.12 + 16.12 = 17.12
assign sum[ 2] = prod_d[ 2] + prod_d[ 3];

assign sum[ 3] = prod_d[ 4] + prod_d[ 5];
assign sum[ 4] = prod_d[ 6] + prod_d[ 7];

assign sum[ 5] = prod_d[08] + prod_d[ 9];
assign sum[ 6] = prod_d[10] + prod_d[11];

assign sum[ 7] = prod_d[12] + prod_d[13];
assign sum[ 8] = {prod_d[14][WW_INPUT+WW_COEFF-1],prod_d[14]};

always @(posedge i_clock) begin
    for (i=1; i<=8; i=i+1) begin
        sum_d[i] <= sum[i];
    end
end

assign sum1[ 1] = sum_d[ 1] + sum_d[ 2];    //17.12 + 17.12 = 18.12
assign sum1[ 2] = sum_d[ 3] + sum_d[ 4];
assign sum1[ 3] = sum_d[ 5] + sum_d[ 6];
assign sum1[ 4] = sum_d[ 7] + sum_d[ 8];

assign sum2[ 1] = sum1[ 1] + sum1[ 2];      //18.12 + 18.12 = 19.12
assign sum2[ 2] = sum1[ 3] + sum1[ 4];

assign sum3 = sum2[ 1] + sum2[ 2];          //19.12 + 19.12 = 20.12

always @(posedge i_clock)
    sum3_d <= sum3;

SatTruncFP #
    (
    .NB_XI(WW_INPUT+WW_COEFF+4),
    .NBF_XI((WW_INPUT-2)*2),
    .NB_XO(WW_OUTPUT),
    .NBF_XO(WW_OUTPUT-2)
    )
inst_SatTruncFP_dataB
    (
    .i_data(sum3_d),
    .o_data(o_signal)
    );

endmodule
