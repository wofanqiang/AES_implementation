//======================================================================
//
// enc_row_shift.v
// ----------
// The AES encrypt Row Shift operation. This implementation
// contains ROR-8, ROR-16 and ROR-24.
//
//======================================================================

module shift_row(
    input  logic enc_dec,
    input  logic [7:0] data_in[0:15],
    output logic [7:0] data_out[0:15]
);

    //----------------------------------------------------------------
  	// Changing to byte array and Changing from byte array.
    //  d0  d4  d8  dc              b00  b01  b02  b03
    //  d1  d5  d9  dd    <====>    b10  b11  b12  b13
    //  d2  d6  da  de              b20  b21  b22  b23
    //  d3  d7  db  df              b30  b31  b32  b33
  	//----------------------------------------------------------------
    logic [7:0] b_array[0:3][0:3];
    logic [7:0] b_array_new[0:3][0:3];

    always_comb begin
        for(int r = 0; r < 4; r++)begin
            for(int c = 0; c < 4; c++)
                b_array[r][c] = data_in[r + c*4];
        end

        for(int r = 0; r < 4; r++)begin
            for(int c = 0; c < 4; c++)
                data_out[r + c*4] = b_array_new[r][c];
        end
    end

    //----------------------------------------------------------------
  	// Rotate Right 0, 8, 16 and 24 bits.  
  	//----------------------------------------------------------------

    always_comb begin
        if(!enc_dec) begin
            b_array_new[0] = b_array[0];

            b_array_new[1][0] = b_array[1][3];
            b_array_new[1][1] = b_array[1][0];
            b_array_new[1][2] = b_array[1][1];
            b_array_new[1][3] = b_array[1][2];

            b_array_new[2][0] = b_array[2][2];
            b_array_new[2][1] = b_array[2][3];
            b_array_new[2][2] = b_array[2][0];
            b_array_new[2][3] = b_array[2][1];

            b_array_new[3][0] = b_array[3][1];
            b_array_new[3][1] = b_array[3][2];
            b_array_new[3][2] = b_array[3][3];
            b_array_new[3][3] = b_array[3][0];
        end
        else begin
            b_array_new[0] = b_array[0];

            b_array_new[1][0] = b_array[1][1];
            b_array_new[1][1] = b_array[1][2];
            b_array_new[1][2] = b_array[1][3];
            b_array_new[1][3] = b_array[1][0];

            b_array_new[2][0] = b_array[2][2];
            b_array_new[2][1] = b_array[2][3];
            b_array_new[2][2] = b_array[2][0];
            b_array_new[2][3] = b_array[2][1];

            b_array_new[3][0] = b_array[3][3];
            b_array_new[3][1] = b_array[3][0];
            b_array_new[3][2] = b_array[3][1];
            b_array_new[3][3] = b_array[3][2];
        end

    end

    

endmodule

