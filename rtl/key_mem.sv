module key_mem(
    input  logic clk,
    input  logic rst,
    input  logic init_key,
    input  logic shift_enc,
    input  logic shift_dec,
    input  logic [7:0] key[0:15],
    output logic [7:0] key_new[0:10][0:15],
    output logic ready_key
);

    enum {  IDLE, GEN_KEY 
    } state_curr, state_next;

    logic [3:0] round_ctr;
    logic [7:0] k[0:15];
    logic [7:0] k_new[0:15];
    logic [7:0] k_new_reg[0:15];

    always_ff @(posedge clk) begin
        if(rst) begin
            state_curr <= IDLE;
        end
        else begin
            state_curr <= state_next;
        end
    end

    always_comb begin
        case(state_curr)
            IDLE: begin
                if(init_key) state_next = GEN_KEY;
                else state_next = IDLE;
            end
            GEN_KEY: begin
                if(round_ctr == 10) state_next = IDLE; 
                else state_next = GEN_KEY; 
            end
            default:begin
                
            end
        endcase
    end

    always_ff @(posedge clk) begin
        case(state_next)
            IDLE: begin
                round_ctr <= 0;
                //k         <= key;
                //ready_key <= 1'b0;
                if(shift_enc)begin
                    for(int i=0; i< 11; i++)begin
                        if(i == 10)begin
                            key_new[10] <= key_new[0];
                        end
                        else begin
                            key_new[i] <= key_new[i+1];
                        end
                        
                    end
                end
                else if(shift_dec)begin
                    for(int i=0; i < 11; i++)begin
                        if(i == 0)begin
                            key_new[0] <= key_new[10];
                        end
                        else begin
                            key_new[i] <= key_new[i-1];
                        end                        
                    end
                end
                else begin  
                    key_new   <= key_new;
                end
            end
            GEN_KEY: begin
                round_ctr <= round_ctr + 1'b1;
                //k         <= (round_ctr == 0)? key: key_new[round_ctr-1];
                key_new[0]<= key;
                key_new[round_ctr+1]<= k_new;
                k_new_reg <= k_new;
                //ready_key <= (round_ctr == 9)? 1'b1 : 1'b0;
            end
            default:begin
                
            end
        endcase
    end

    assign k = (round_ctr == 0)? key: k_new_reg;
    assign ready_key = (round_ctr == 10)? 1'b1 : 1'b0;

    ex_key u0_ex_k(
        .round_ctr(round_ctr+1'b1),
        .key(k),
        .key_new(k_new)
    );

endmodule




module ex_key(
    input  logic [3:0] round_ctr,
    input  logic [7:0] key[0:15],

    output logic [7:0] key_new[0:15]
);

    //----------------------------------------------------------------
  	// Changing to words array and changing from words array.
  	//----------------------------------------------------------------

    logic [0:3][7:0] key_words[0:3];
    logic [0:3][7:0] key_words_new[0:3];
    always_comb begin
        for(int i=0; i<4; i++)begin
            for(int j=0; j<4; j++)begin
                key_words[i][j] = key[i*4 + j];
                key_new[i*4 + j] = key_words_new[i][j];
            end
        end
    end

    //----------------------------------------------------------------
  	// Generating the new keys.
  	//----------------------------------------------------------------
    logic [0:3][7:0] key_word_temp;

    gfw u0_gfw(.w(key_words[3]), .round(round_ctr), .w_new(key_word_temp));

    always_comb begin
        if(round_ctr == 0)begin
            key_words_new[0] = key_words[0];
            key_words_new[1] = key_words[1];
            key_words_new[2] = key_words[2];
            key_words_new[3] = key_words[3];
        end
        else begin
            key_words_new[0] = key_word_temp    ^ key_words[0];
            key_words_new[1] = key_words_new[0] ^ key_words[1];
            key_words_new[2] = key_words_new[1] ^ key_words[2];
            key_words_new[3] = key_words_new[2] ^ key_words[3];
        end
    end


endmodule




module gfw(
    input  logic [0:3][7:0] w,
    input  logic [3:0] round,
    output logic [0:3][7:0] w_new
);
        
    logic [7:0] w_temp[0:3];
    logic [7:0] s_temp[0:3];
    //----------------------------------------------------------------
  	// Rotate Left 8 bits.
  	//----------------------------------------------------------------
    always_comb begin
        w_temp[0] = w[1];
        w_temp[1] = w[2];
        w_temp[2] = w[3];
        w_temp[3] = w[0];
    end
    
    //----------------------------------------------------------------
  	// Mapping the s-box.
  	//----------------------------------------------------------------
    aes_sbox u0_sbox(.s_in(w_temp), .s_out(s_temp));
    //----------------------------------------------------------------
  	// RC ROM.
  	//----------------------------------------------------------------
    logic [7:0] rc_rom;

    always_comb begin
        case(round)
            4'd1: rc_rom = 8'h01;
            4'd2: rc_rom = 8'h02;
            4'd3: rc_rom = 8'h04;
            4'd4: rc_rom = 8'h08;
            4'd5: rc_rom = 8'h10;
            4'd6: rc_rom = 8'h20;
            4'd7: rc_rom = 8'h40;
            4'd8: rc_rom = 8'h80;
            4'd9: rc_rom = 8'h1B;
            4'd10: rc_rom = 8'h36;
            default: rc_rom =  0;
        endcase
    end
    //----------------------------------------------------------------
  	// Outputs.
  	//----------------------------------------------------------------

    always_comb begin
        w_new[0] = rc_rom ^ s_temp[0];
        w_new[1] = s_temp[1];
        w_new[2] = s_temp[2];
        w_new[3] = s_temp[3];
    end
    
endmodule