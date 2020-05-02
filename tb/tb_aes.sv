module tb_aes;       

// aes Parameters
parameter PERIOD = 10    ;
parameter IV  = 128'h1;

// aes Inputs
logic         clk                    = 0 ;
logic         rst                    = 1 ;
logic         init                   = 0 ;
logic         next                   = 0 ;
logic         enc_dec                = 0 ;
logic         mode                   = 0 ;
logic [127:0] key                    = 0 ;
logic [127:0] block_in               = 0 ;

logic [127:0] block_in_temp               = 0 ;

logic [127:0]  c1 = 0;
logic [127:0]  c2 = 0;
logic [127:0]  d1 = 0;
logic [127:0]  d2 = 0;

logic [127:0] p1 = {$random, $random, $random, $random};
logic [127:0] p2 = {$random, $random, $random, $random};

// aes Outputs
logic [127:0] block_out              ;
logic         valid                  ;
logic aes_mode = 1'b1;
logic finish_test = 0;

initial
begin
    forever #(PERIOD/2)  clk=~clk;
end

initial
begin
    #(PERIOD*2) rst  =  0;
    aes_mode = 1'b1;
    @(posedge clk)begin
        $display("CBC mode!\n");
    end

    @(posedge clk) begin    
        block_in = p1;
        key      = 128'h000102030405060708090a0b0c0d0e0f;
    end
    @(posedge clk)begin
        init = 1'b1;
        next = 1'b0;
        enc_dec = 1'b1;
        mode = aes_mode;
    end

    wait(valid);
    @(posedge clk)begin
        block_in = p2;
        c1 = block_out;
        init = 1'b0;
        next = 1'b0;
        enc_dec = 1'b0;
        mode = aes_mode;
    end

    #(PERIOD*2);
    @(posedge clk)begin
        init = 1'b0;
        next = 1'b1;
        enc_dec = 1'b1;
        mode = aes_mode;
    end
    wait(valid);
    @(posedge clk)begin
        c2 = block_out;
        enc_dec = 1'b0;
        init = 1'b0;
        next = 1'b0;
        mode = aes_mode;
    end

    #(PERIOD*2);
    @(posedge clk)begin
        block_in = c1;
    end
    @(posedge clk)begin
        init = 1'b1;
        next = 1'b0;
        enc_dec = 1'b0;
        mode = aes_mode;
    end
    wait(valid);
    @(posedge clk)begin
        d1 = block_out;
        init = 1'b0;
        next = 1'b0;
        enc_dec = 1'b0;
        mode = aes_mode;
    end

    #(PERIOD*2);
    @(posedge clk)begin
        block_in = c2;
    end
    @(posedge clk)begin
        init = 1'b0;
        next = 1'b1;
        enc_dec = 1'b0;
        mode = aes_mode;
    end
    wait(valid);
    @(posedge clk)begin
        d2 = block_out;
        init = 1'b0;
        next = 1'b0;
        enc_dec = 1'b0;
        mode = aes_mode;
        finish_test <= 1;
    end
    @(posedge clk)begin
        finish_test <= 0;
    end


    #(PERIOD *5);
    aes_mode = 0;
    @(posedge clk)begin
        $display("\n\nEBC mode!\n");
    end
    @(posedge clk) begin    
        block_in = p1;
        key      = 128'h000102030405060708090a0b0c0d0e0f;
    end
    @(posedge clk)begin
        init = 1'b1;
        next = 1'b0;
        enc_dec = 1'b1;
        mode = aes_mode;
    end

    wait(valid);
    @(posedge clk)begin
        block_in = p2;
        c1 = block_out;
        init = 1'b0;
        next = 1'b0;
        enc_dec = 1'b0;
        mode = aes_mode;
    end

    #(PERIOD*2);
    @(posedge clk)begin
        init = 1'b0;
        next = 1'b1;
        enc_dec = 1'b1;
        mode = aes_mode;
    end
    wait(valid);
    @(posedge clk)begin
        c2 = block_out;
        enc_dec = 1'b0;
        init = 1'b0;
        next = 1'b0;
        mode = aes_mode;
    end

    #(PERIOD*2);
    @(posedge clk)begin
        block_in = c1;
    end
    @(posedge clk)begin
        init = 1'b1;
        next = 1'b0;
        enc_dec = 1'b0;
        mode = aes_mode;
    end
    wait(valid);
    @(posedge clk)begin
        d1 = block_out;
        init = 1'b0;
        next = 1'b0;
        enc_dec = 1'b0;
        mode = aes_mode;
    end

    #(PERIOD*2);
    @(posedge clk)begin
        block_in = c2;
    end
    @(posedge clk)begin
        init = 1'b0;
        next = 1'b1;
        enc_dec = 1'b0;
        mode = aes_mode;
    end
    wait(valid);
    @(posedge clk)begin
        d2 = block_out;
        init = 1'b0;
        next = 1'b0;
        enc_dec = 1'b0;
        mode = aes_mode;
        finish_test <= 1;
    end
    @(posedge clk)begin
        finish_test <= 0;
    end



    #(PERIOD*10);
    $stop();
end

always_ff @(posedge clk)begin
    if(finish_test)begin
        if(d1 == p1 & d2 == p2)begin
            $display("Correct!\np:%h%h\nd:%h%h",p1, p2, d1, d2);
        end
        else begin
            $display("Wrong!\np:%h%h\nd:%h%h",p1, p2, d1, d2);
        end
    end
end


aes #(
    .IV (10))
 u_aes (.*);


endmodule