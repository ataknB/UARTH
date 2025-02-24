module TX #(
    parameter PACKET = 8

)(  
    input clk,
    input rst,

    input [PACKET-1:0]in,

    input tx_en,
    output reg rx_en,
    output reg out
);
    
    reg [7:0]mem;
    reg [4:0]counter;
    reg wire_tx_en;

    always @(posedge clk, negedge rst)
    begin
        if(!rst)
        begin
            mem <= 8'd0;
            rx_en <= 1'd0;
            out <= 1'd0;
            counter <= 5'd0;
            wire_tx_en <= 1'b0;
        end


        else 
        begin
            if(tx_en)
            begin 
                wire_tx_en <= 1'b1;
                mem <= in;
                
            end

            else
            begin
            end

            if(wire_tx_en)
            begin
                
                case(counter)
                    5'd0:
                    begin
                        out <= 1'b0;
                        wire_tx_en <= 1'b1;
                        rx_en <= 1'b1; 
                    end
                    5'd1, 5'd2 , 5'd3  , 5'd4  , 5'd5  , 5'd6 , 5'd7  , 5'd8 :
                    begin
                        out <= mem[counter-1];
                        wire_tx_en <= 1'b1;
                        rx_en <= 1'b1; 
                    end
                    default:
                    begin
                        out <=1'b1;
                        wire_tx_en <= 1'b0;
                        rx_en <= 1'b0; 
                        counter <= 5'd0;
                    end     
                endcase

                if(counter == 5'd9)
                begin
                    counter <= 5'd0;
                end    

                else
                begin
                    counter <= counter + 1'b1;
                end    
           end

           else 
           begin
            out <= 1'd1;
            //wire_tx_en <= 1'b0;
           end 
        end

    end
endmodule

module RX(
    input clk, rst,
    input in,
    input rx_en,

    output reg error,
    output reg[7:0]out
);

    reg [4:0]counter;
    reg [7:0]mem;
    reg wire_rx_en;

    always @(posedge clk, negedge rst)
    begin
        if(!rst)
        begin
            error <= 1'b0;
            counter <= 5'd0;
            out <= 8'd0;
            wire_rx_en <= 1'b0;
        end

        else
        begin
            
            if(rx_en)
            begin
                counter <= counter + 1;
                mem[counter-1] <= in;
                error <= 1'b0;
            end

            else
            begin
                if(in == 1'b0)
                begin
                    error <= 1'b1;
                    counter <= 5'd0;
                    mem <= 8'd0;
                end

                else
                begin
                    error <= 1'b0;
                    counter <= 5'd0;
                    mem <= 8'd0;
                end
            end

            if(counter == 5'd9)
            begin
                out <= mem;
            end
            else 
            begin
                
            end

        end
    end


endmodule


module UARTH(
    input clk,rst,
    input [7:0]in,
    input tx_en,
    output [7:0]out,
    output error
);

    wire tx_out;
    wire rx_en;

    TX TX(
        .in(in),
        .rst(rst),
        .clk(clk),
        .tx_en(tx_en),
        .rx_en(rx_en),
        .out(tx_out)
    );

    RX RX(
        .in(tx_out),
        .rst(rst),
        .clk(clk),
        .rx_en(rx_en),
        .error(error),
        .out(out)
    );
endmodule
