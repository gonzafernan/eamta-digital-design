module filtro_fir
  #(
    parameter WW_INPUT  = 8,
    parameter WW_OUTPUT = 8
    ) 
   (
    input 			  clk,
    input 			  i_en,
    input 			  i_srst,
    // Input Stream
    input signed [ WW_INPUT-1:0]  i_data,
    // Output Stream
    output signed [WW_OUTPUT-1:0] o_data
    );

  // Local Params
  localparam WW_COEFF = 8;

  // Internal Signals
   reg  signed [WW_INPUT           -1:0] register [14:1];
   wire signed [         WW_COEFF  -1:0] coeff    [14:0];
   wire signed [WW_INPUT+WW_COEFF  -1:0] prod     [14:0];
   wire signed [WW_INPUT+WW_COEFF+1-1:0] sum      [8:1]; 
   wire signed [WW_INPUT+WW_COEFF+2-1:0] sum1     [4:1]; 
   wire signed [WW_INPUT+WW_COEFF+3-1:0] sum2     [2:1]; 
   wire signed [WW_INPUT+WW_COEFF+4-1:0] sum3; 
   reg signed [WW_INPUT+WW_COEFF   -1:0] prod_d   [14:0];
   reg signed [WW_INPUT+WW_COEFF+4 -1:0] sum3_d;
   reg signed [WW_INPUT+WW_COEFF+1 -1:0] sum_d    [8:1];


  // Coeffs c = [-1 1/2 -1/4 1/8]
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
  always @(posedge clk) begin
    if (i_srst == 1'b1) begin
      register[ 1] <= {WW_INPUT{1'b0}};
      register[ 2] <= {WW_INPUT{1'b0}};
      register[ 3] <= {WW_INPUT{1'b0}};
      register[ 4] <= {WW_INPUT{1'b0}};
      register[ 5] <= {WW_INPUT{1'b0}};
      register[ 6] <= {WW_INPUT{1'b0}};
      register[ 7] <= {WW_INPUT{1'b0}};
      register[ 8] <= {WW_INPUT{1'b0}};
      register[ 9] <= {WW_INPUT{1'b0}};
      register[10] <= {WW_INPUT{1'b0}};
      register[11] <= {WW_INPUT{1'b0}};
      register[12] <= {WW_INPUT{1'b0}};
      register[13] <= {WW_INPUT{1'b0}};
      register[14] <= {WW_INPUT{1'b0}};
    end else begin
      if (i_en == 1'b1) begin
        register[ 1] <= i_data;
        register[ 2] <= register[ 1];
        register[ 3] <= register[ 2];
        register[ 4] <= register[ 3];
        register[ 5] <= register[ 4];
        register[ 6] <= register[ 5];
        register[ 7] <= register[ 6];
        register[ 8] <= register[ 7];
        register[ 9] <= register[ 8];
        register[10] <= register[ 9];
        register[11] <= register[10];
        register[12] <= register[11];
        register[13] <= register[12];
	    register[14] <= register[13];

      end
    end
  end

  // Products
  assign prod[ 0] = coeff[ 0] * i_data;
  assign prod[ 1] = coeff[ 1] * register[ 1];
  assign prod[ 2] = coeff[ 2] * register[ 2];
  assign prod[ 3] = coeff[ 3] * register[ 3];
  assign prod[ 4] = coeff[ 4] * register[ 4];
  assign prod[ 5] = coeff[ 5] * register[ 5];
  assign prod[ 6] = coeff[ 6] * register[ 6];
  assign prod[ 7] = coeff[ 7] * register[ 7];
  assign prod[ 8] = coeff[ 8] * register[ 8];
  assign prod[ 9] = coeff[ 9] * register[ 9];
  assign prod[10] = coeff[10] * register[10];
  assign prod[11] = coeff[11] * register[11];
  assign prod[12] = coeff[12] * register[12];
  assign prod[13] = coeff[13] * register[13];
  assign prod[14] = coeff[14] * register[14];

  always@(posedge clk) begin
    prod_d[ 0] <= prod[ 0];
    prod_d[ 1] <= prod[ 1];
    prod_d[ 2] <= prod[ 2];
    prod_d[ 3] <= prod[ 3];
    prod_d[ 4] <= prod[ 4];
    prod_d[ 5] <= prod[ 5];
    prod_d[ 6] <= prod[ 6];
    prod_d[ 7] <= prod[ 7];
    prod_d[ 8] <= prod[ 8];
    prod_d[ 9] <= prod[ 9];
    prod_d[10] <= prod[10];
    prod_d[11] <= prod[11];
    prod_d[12] <= prod[12];
    prod_d[13] <= prod[13];
    prod_d[14] <= prod[14];
  end
  

  // Adders
  assign sum[ 1] = prod_d[ 0] + prod_d[ 1];//16.12 + 16.12 = 17.12
  assign sum[ 2] = prod_d[ 2] + prod_d[ 3];
  
  assign sum[ 3] = prod_d[ 4] + prod_d[ 5];
  assign sum[ 4] = prod_d[ 6] + prod_d[ 7];

  assign sum[ 5] = prod_d[08] + prod_d[ 9];
  assign sum[ 6] = prod_d[10] + prod_d[11];

  assign sum[ 7] = prod_d[12] + prod_d[13];
  assign sum[ 8] = {prod_d[14][WW_INPUT+WW_COEFF-1],prod_d[14]};

  always@(posedge clk) begin
    sum_d[1] <= sum[1];
    sum_d[2] <= sum[2];
    sum_d[3] <= sum[3];
    sum_d[4] <= sum[4];
    sum_d[5] <= sum[5];
    sum_d[6] <= sum[6];
    sum_d[7] <= sum[7];
    sum_d[8] <= sum[8];
  end

  assign sum1[ 1] = sum_d[ 1] + sum_d[ 2];//17.12 + 17.12 = 18.12
  assign sum1[ 2] = sum_d[ 3] + sum_d[ 4];
  assign sum1[ 3] = sum_d[ 5] + sum_d[ 6];
  assign sum1[ 4] = sum_d[ 7] + sum_d[ 8];

  assign sum2[ 1] = sum1[ 1] + sum1[ 2];//18.12 + 18.12 = 19.12
  assign sum2[ 2] = sum1[ 3] + sum1[ 4];

  assign sum3 = sum2[ 1] + sum2[ 2];//19.12 + 19.12 = 20.12

  always@(posedge clk)
    sum3_d <= sum3;
      
  SatTruncFP
	inst_SatTruncFP_dataB
	(
	  .i_data(	sum3_d	),
	  .o_data(	o_data	)
	);
	

endmodule
