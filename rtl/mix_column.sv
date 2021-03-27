module mix_column(
    input  logic enc_dec,
    input  logic [7:0] data_in[0:15],
    output logic [7:0] data_out[0:15]
);

    //----------------------------------------------------------------
  	// Mixing the columns.
  	//----------------------------------------------------------------
    always_comb begin
        if(enc_dec)begin
            { data_out[0],  
              data_out[1], 
              data_out[2], 
              data_out[3]} 
            = enc_mc(
            { data_in[0], 
              data_in[1], 
              data_in[2], 
              data_in[3]});

            { data_out[0+1*4],  
              data_out[1+1*4], 
              data_out[2+1*4], 
              data_out[3+1*4]} 
            = enc_mc(
            { data_in[0+1*4], 
              data_in[1+1*4], 
              data_in[2+1*4], 
              data_in[3+1*4]});

            { data_out[0+2*4],  
              data_out[1+2*4], 
              data_out[2+2*4], 
              data_out[3+2*4]} 
            = enc_mc(
            { data_in[0+2*4], 
              data_in[1+2*4], 
              data_in[2+2*4], 
              data_in[3+2*4]});

            { data_out[0+3*4],  
              data_out[1+3*4], 
              data_out[2+3*4], 
              data_out[3+3*4]} 
            = enc_mc(
            { data_in[0+3*4], 
              data_in[1+3*4], 
              data_in[2+3*4], 
              data_in[3+3*4]});
        end
        else begin
            { data_out[0],  
              data_out[1], 
              data_out[2], 
              data_out[3]} 
            = dec_mc(
            {   data_in[0], 
                data_in[1], 
                data_in[2], 
                data_in[3]});

            { data_out[0+1*4],  
              data_out[1+1*4], 
              data_out[2+1*4], 
              data_out[3+1*4]} 
            = dec_mc(
            { data_in[0+1*4], 
              data_in[1+1*4], 
              data_in[2+1*4], 
              data_in[3+1*4]});

            { data_out[0+2*4],  
              data_out[1+2*4], 
              data_out[2+2*4], 
              data_out[3+2*4]} 
            = dec_mc(
            { data_in[0+2*4], 
              data_in[1+2*4], 
              data_in[2+2*4], 
              data_in[3+2*4]});

            { data_out[0+3*4],  
              data_out[1+3*4], 
              data_out[2+3*4], 
              data_out[3+3*4]} 
            = dec_mc(
            { data_in[0+3*4], 
              data_in[1+3*4], 
              data_in[2+3*4], 
              data_in[3+3*4]});
        end
        

    end 


    //----------------------------------------------------------------
  	// Mixing columns function for encrypt.
  	//----------------------------------------------------------------
    function [3:0][7:0] enc_mc(
        input [3:0][7:0] op
        ); 
        
        enc_mc[3] = gm2(op[3]) ^ gm3(op[2]) ^     op[1]  ^     op[0]; 
        enc_mc[2] =     op[3]  ^ gm2(op[2]) ^ gm3(op[1]) ^     op[0]; 
        enc_mc[1] =     op[3]  ^     op[2]  ^ gm2(op[1]) ^ gm3(op[0]); 
        enc_mc[0] = gm3(op[3]) ^     op[2]  ^     op[1]  ^ gm2(op[0]); 
        
    endfunction

     //----------------------------------------------------------------
  	// Mixing columns function for decrypt.
  	//----------------------------------------------------------------
    function [3:0][7:0] dec_mc(
        input [3:0][7:0] op
        ); 
        
        dec_mc[3] = gmE(op[3]) ^ gmB(op[2]) ^ gmD(op[1]) ^ gm9(op[0]); 
        dec_mc[2] = gm9(op[3]) ^ gmE(op[2]) ^ gmB(op[1]) ^ gmD(op[0]); 
        dec_mc[1] = gmD(op[3]) ^ gm9(op[2]) ^ gmE(op[1]) ^ gmB(op[0]); 
        dec_mc[0] = gmB(op[3]) ^ gmD(op[2]) ^ gm9(op[1]) ^ gmE(op[0]);
        
    endfunction

    //----------------------------------------------------------------
  	// Multiplication functions over GF(2^8).
  	//----------------------------------------------------------------

    function [7:0] gm2(
        input [7:0] op
    );
        gm2 = {op[6 : 0], 1'b0} ^ (8'h1b & {8{op[7]}});
        
    endfunction

    function [7:0] gm3(
        input [7:0] op
    );

        gm3 = gm2(op) ^ op;
        
    endfunction

    function [7:0] gm4(
        input [7:0] op
    );
        gm4 = gm2(gm2(op));
        
    endfunction

    function [7:0] gm8(
        input [7:0] op
    );
        gm8 = gm2(gm4(op));
        
    endfunction

    function [7:0] gm9(
        input [7:0] op
    );

        gm9 = gm8(op)^op;
        
    endfunction

    function [7:0] gmB(
        input [7:0] op
    );

        gmB = gm8(op) ^ gm2(op) ^ op;
        
    endfunction

    function [7:0] gmD(
        input [7:0] op
    );

        gmD = gm8(op) ^ gm4(op) ^ op;
        
    endfunction

    function [7:0] gmE(
        input [7:0] op
    );
    
        gmE = gm8(op) ^ gm4(op) ^ gm2(op);
        
    endfunction

endmodule