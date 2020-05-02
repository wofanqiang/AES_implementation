//======================================================================
//
// aes.v
// --------
// Top level wrapper for the AES block cipher core.
//
//
//======================================================================

module aes(
	input  logic         clk,
	input  logic         rst,
	input  logic         init,
	input  logic         next,
	input  logic         enc_dec,
	input  logic         mode,
	input  logic [127:0] key,
	input  logic [127:0] block_in,
	output logic [127:0] block_out,
	output logic         valid
);

    parameter IV = 128'h1;

    //----------------------------------------------------------------
  	// Key generation module ports.
  	//----------------------------------------------------------------	
    logic init_key;
    logic [7:0] key_bytes[0:15];
    logic [7:0] key_new[0:10][0:15];
    logic ready_key;
    logic shift_key_enc;
    logic shift_key_dec;
    //----------------------------------------------------------------
  	// Encrypt module ports.
  	//----------------------------------------------------------------	
    logic start_enc;
    logic [7:0] enc_block_in[0:15];
    logic [7:0] enc_block_out[0:15];
    logic finsih_enc;

    //----------------------------------------------------------------
  	// decrypt module ports.
  	//----------------------------------------------------------------	
    logic start_dec;
    logic [7:0] dec_block_in[0:15];
    logic [7:0] dec_block_out[0:15];
    logic finsih_dec;
    

    //----------------------------------------------------------------
  	// Preparing Data.
  	//----------------------------------------------------------------	
    logic [127:0] block_in_prev;
    logic [127:0] block_out_prev;
    logic [127:0] enc_out_bits;
    logic [127:0] dec_out_bits;
    logic [127:0] dec_out_temp;
    logic [127:0] enc_in_temp;
    
    //----------------------------------------------------------------
  	// mode = 1, init = 1: CBC模式，第一块数据.
    // mode = 1, next = 1: CBC模式，连续数据.
    // mode = 0 : EBC模式。
  	//----------------------------------------------------------------	
    always_comb begin
        if(mode & next)begin
            enc_in_temp  = block_out_prev ^ block_in;
            dec_out_temp = block_in_prev ^ dec_out_bits;
        end
        else if(mode & init) begin
            enc_in_temp  = IV ^ block_in;
            dec_out_temp = IV ^ dec_out_bits;
        end
        else begin
            enc_in_temp  = block_in;
            dec_out_temp = dec_out_bits;
        end
    end

    //----------------------------------------------------------------
  	// Byte to bit and bit to Btye。
  	//----------------------------------------------------------------
    always_comb begin
        for(int i = 0; i < 16; i= i+1) begin
            enc_block_in[i] = enc_in_temp[127-8*i -:8];
            dec_block_in[i] = block_in[127-8*i -:8];
            key_bytes[i] = key[127-8*i -:8];
            enc_out_bits[127-8*i -:8] = enc_block_out[i];
            dec_out_bits[127-8*i -:8] = dec_block_out[i];
        end
    end

    always_comb begin
        block_out = (enc_dec) ? enc_out_bits : dec_out_temp;
        valid     = finsih_enc | finsih_dec;
    end
    
    
    //----------------------------------------------------------------
  	// FSM.
  	//----------------------------------------------------------------
	enum{
        IDLE_CORE, KEY_INIT, KEY_READY, BLOCK_INIT, BLOCK_READY
    }state_curr, state_next;

	always@(posedge clk)begin
		if(rst)begin
			state_curr <= IDLE_CORE;
		end
		else begin
			state_curr <= state_next;
		end
	end

	always@(*)begin
		case(state_curr)
			IDLE_CORE:begin
				if(init) state_next = KEY_INIT;
				else if(next) state_next = BLOCK_INIT;
				else state_next = IDLE_CORE;
			end
			KEY_INIT:begin
				state_next = KEY_READY;
			end
			KEY_READY:	begin
				if(ready_key) state_next = BLOCK_INIT;
				else state_next = KEY_READY;
			end
			BLOCK_INIT:	begin
				state_next = BLOCK_READY;
			end
			BLOCK_READY:begin
				if(valid) state_next = IDLE_CORE;
				else state_next = BLOCK_READY;
			end
			default:begin
				state_next = IDLE_CORE;
			end
		endcase
	end

	always@(posedge clk)begin
		case(state_next)
			IDLE_CORE:begin
				init_key  <= 1'b0;
                start_enc <= 1'b0;
                start_dec <= 1'b0;
                block_in_prev <= (finsih_dec) ? block_in : block_in_prev;
                block_out_prev <= (finsih_enc) ? enc_out_bits : block_out_prev;
			end
			KEY_INIT:begin
				init_key  <= 1'b1;
                start_enc <= 1'b0;
                start_dec <= 1'b0;
                block_in_prev  <= 128'h0;
                block_out_prev <= 128'h0;
			end
			KEY_READY:	begin
				init_key  <= 1'b0;
                start_enc <= 1'b0;
                start_dec <= 1'b0;
			end
			BLOCK_INIT:	begin
                init_key  <= 1'b0;
				start_enc <= enc_dec & ( init | next );
                start_dec <= (!enc_dec) & ( init | next );
                block_in_prev <= block_in_prev;
                block_out_prev <= block_out_prev;
			end
			BLOCK_READY:begin
				init_key  <= 1'b0;
				start_enc <= 1'b0;
                start_dec <= 1'b0;
			end
			default:begin
				
			end
		endcase

	end

    //----------------------------------------------------------------
    // Module instantiation.
    //----------------------------------------------------------------
    key_mem u0_key_mem(
        .clk(clk),
        .rst(rst),
        .init_key(init_key),
        .shift_enc(shift_key_enc),
        .shift_dec(shift_key_dec),
        .key(key_bytes),
        .key_new(key_new),
        .ready_key(ready_key)
    );

    aes_encrypt u1_enc(
        .clk(clk),
        .rst(rst),
        .start_enc(start_enc),
        .plaintext(enc_block_in),
        .keys(key_new[0]),
        .ciphertext(enc_block_out),
        .finsih_enc(finsih_enc),
        .shift_key_enc(shift_key_enc)
    );

    aes_decrypt u2_dec(
        .clk(clk),
        .rst(rst),
        .start_dec(start_dec),
        .ciphertext(dec_block_in),
        .keys(key_new[10]),

        .plaintext(dec_block_out),
        .finsih_dec(finsih_dec),
        .shift_key_dec(shift_key_dec)
    );



endmodule // aes

//======================================================================
// EOF aes.v
//======================================================================





