module aes_encrypt(
    input  logic clk,
    input  logic rst,
    input  logic start_enc,
    input  logic [7:0] plaintext[0:15],
    input  logic [7:0] keys[0:15],

    output logic [7:0] ciphertext[0:15],
    output logic finsih_enc,
    output logic shift_key_enc
);

    logic [3:0] round_ctr;
    logic [7:0] s_in[0:3];
    logic [7:0] s_out[0:3];

    logic [7:0] ctemp0[0:3];
    logic [7:0] ctemp1[0:3];
    logic [7:0] ctemp2[0:3];
    logic [7:0] ctemp3[0:3];

    logic [7:0] sub_bytes_out[0:15]; 
    logic [7:0] shift_row_out[0:15]; 
    logic [7:0] mix_column_out[0:15]; 
    logic [7:0] ciphertext_temp[0:15]; 
    


    enum{
        ROUND0, OTHER0, OTHER1, OTHER2, OTHER3
    }state_curr, state_next;


    always_ff @(posedge clk) begin
        if(rst)begin
            state_curr <= ROUND0;
        end
        else begin
            state_curr <= state_next;
        end
    end

    always_comb begin
        case(state_curr)
            ROUND0:begin
                if(start_enc) state_next = OTHER0;
                else state_next = ROUND0;
            end
            OTHER0:begin
                state_next = OTHER1;
            end
            OTHER1:begin
                state_next = OTHER2;
            end
            OTHER2:begin
                state_next = OTHER3;
            end
            OTHER3:begin
                if(round_ctr == 10) state_next = ROUND0;
                else state_next = OTHER0;
            end
            default:begin
                
            end
        endcase
    end

    always_ff @(posedge clk) begin
        case(state_next)
            ROUND0:begin
                round_ctr <= 4'h0;
                finsih_enc <= 1'b0;
                shift_key_enc <= 1'b0;
                for(int i=0; i< 16; i++)begin
                    ciphertext[i] = plaintext[i] ^ keys[i];     
                end
            end
            OTHER0:begin
                shift_key_enc <= start_enc;
                round_ctr  <= round_ctr + 1'b1;
                finsih_enc <= 1'b0;
                ctemp0     <= s_out;
            end
            OTHER1:begin
                shift_key_enc <= 1'b0;
                ctemp0     <= ctemp0;
                ctemp1     <= s_out;
            end
            OTHER2:begin
                ctemp1     <= ctemp1;
                ctemp2     <= s_out;
            end
            OTHER3:begin
                ctemp2     <= ctemp2;
                shift_key_enc <= 1'b1;
                ciphertext <= ciphertext_temp;
                if(round_ctr == 10)begin
                    finsih_enc <= 1'b1;
                end
            end
            default:begin
                
            end
        endcase
    end

    always_comb begin
        case(state_next)
            OTHER0:begin
                s_in[0] = ciphertext[0]; 
                s_in[1] = ciphertext[1]; 
                s_in[2] = ciphertext[2]; 
                s_in[3] = ciphertext[3]; 
            end
            OTHER1:begin
                s_in[0] = ciphertext[0+1*4]; 
                s_in[1] = ciphertext[1+1*4]; 
                s_in[2] = ciphertext[2+1*4]; 
                s_in[3] = ciphertext[3+1*4];
            end
            OTHER2:begin
                s_in[0] = ciphertext[0+2*4]; 
                s_in[1] = ciphertext[1+2*4]; 
                s_in[2] = ciphertext[2+2*4]; 
                s_in[3] = ciphertext[3+2*4];
            end
            OTHER3:begin
                s_in[0] = ciphertext[0+3*4]; 
                s_in[1] = ciphertext[1+3*4]; 
                s_in[2] = ciphertext[2+3*4]; 
                s_in[3] = ciphertext[3+3*4];
            end
            default:begin
                s_in[0] = ciphertext[0]; 
                s_in[1] = ciphertext[1]; 
                s_in[2] = ciphertext[2]; 
                s_in[3] = ciphertext[3];
            end
        endcase
    end

    always_comb begin
        sub_bytes_out[0] = ctemp0[0];
        sub_bytes_out[1] = ctemp0[1];
        sub_bytes_out[2] = ctemp0[2];
        sub_bytes_out[3] = ctemp0[3];
        sub_bytes_out[4] = ctemp1[0];
        sub_bytes_out[5] = ctemp1[1];
        sub_bytes_out[6] = ctemp1[2];
        sub_bytes_out[7] = ctemp1[3];
        sub_bytes_out[8]  = ctemp2[0];
        sub_bytes_out[9]  = ctemp2[1];
        sub_bytes_out[10] = ctemp2[2];
        sub_bytes_out[11] = ctemp2[3];
        sub_bytes_out[12] = ctemp3[0];
        sub_bytes_out[13] = ctemp3[1];
        sub_bytes_out[14] = ctemp3[2];
        sub_bytes_out[15] = ctemp3[3];
    end

    always_comb begin
        ctemp3 = s_out;
    end

    always_comb begin
        if(round_ctr == 10)begin
            for(int i=0; i< 16; i++)begin
                ciphertext_temp[i] = shift_row_out[i] ^ keys[i];  
            end
        end
        else begin
            for(int i=0; i< 16; i++)begin
                ciphertext_temp[i] = mix_column_out[i] ^ keys[i];       
            end
        end
    end


    aes_sbox u0_sbox(.s_in(s_in), .s_out(s_out));

    shift_row u1_shift_row(
        .enc_dec(1'b1),
        .data_in(sub_bytes_out),
        .data_out(shift_row_out));
    
    mix_column u2_mix_column(
        .enc_dec(1'b1),
        .data_in(shift_row_out),
        .data_out(mix_column_out)
);







endmodule