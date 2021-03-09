module SatTruncFP
  #(
    parameter	NB_XI  	= 20,
    parameter	NBF_XI	= 12,
    
    parameter	NB_XO	= 8,
    parameter	NBF_XO	= 6
    )
   (
    input [(NB_XI)-1:0]  i_data,
    output [(NB_XO)-1:0] o_data
    );


//=======================================================
//  PARAMETER declarations
//=======================================================
   localparam	NBI_XI	=	NB_XI	-	NBF_XI;
   localparam	NBI_XO	=	NB_XO	-	NBF_XO;
   
//=======================================================
//  REG/WIRE declarations
//=======================================================
   
   wire [NB_XO-1:0] 	 aux_Sat;
   
   wire [NBF_XO-1:0] 	 aux_trunc;
   
   wire 		 condicion;
   wire [NB_XO-1:0] 	 resultado1;
   wire [NB_XO-1:0] 	 resultado2;

//=======================================================
//  Structural coding
//=======================================================
	generate
	   if (NBF_XI >= NBF_XO)
	     begin
		assign	aux_trunc = i_data[(NBF_XI-1):(NBF_XI - NBF_XO)];
	     end
	   else
	     begin
		assign	aux_trunc = {i_data[NBF_XI-1:0],{(NBF_XO - NBF_XI){1'b0}}};
	     end
	   if (NBI_XI > NBI_XO)
	     begin
		assign	condicion		=	(i_data[(NB_XI-2)-:(NBI_XI-NBI_XO)] == {(NBI_XI-NBI_XO){i_data[NB_XI-1]}});
		assign	resultado1		=	{i_data[(NB_XI-1)],{(NB_XO-1){~i_data[(NB_XI-1)]}}};
		assign	resultado2		=	{i_data[(NB_XI-1)],i_data[NBF_XI +:NBI_XO-1],aux_trunc};
		assign	aux_Sat			=	condicion	?	resultado2	:	resultado1;
	     end
	   else
	     begin
		if (NBI_XO == NBI_XI)
                  assign  aux_Sat = {i_data[(NB_XI-1)-:NBI_XI],aux_trunc};
		else
		  assign  aux_Sat	= {{(NBI_XO - NBI_XI){i_data[NB_XI-1]}},i_data[(NB_XI-1)-:NBI_XI],aux_trunc};
	     end
	endgenerate
   assign	o_data=aux_Sat;
      
endmodule
