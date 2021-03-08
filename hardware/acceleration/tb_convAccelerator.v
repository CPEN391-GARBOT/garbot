module tb_convAccelerator();
  reg clk, reset, dataValid, filter;
  reg [31:0] dataIn;
  wire [31:0] dataOut;

  convAccelerator DUT(clk, reset, dataIn, dataValid, filter, dataOut);

  initial begin
    reset = 1'b0;
    #10;
    reset = 1'b1;
    clk = 1;
    dataIn = 32'b1000_0000_0000_0000_0000_0000; // 0.5
    dataValid = 1'b1;
    filter = 1'b1;
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b1100_0000_0000_0000_0000_0000; // 0.75
    dataValid = 1'b1;
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b1010_0000_0000_0000_0000_0000; // 0.625
    dataValid = 1'b1;
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b1110_0000_0000_0000_0000_0000; // 0.875
    dataValid = 1'b1;
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b1001_0000_0000_0000_0000_0000; // 0.5625
    dataValid = 1'b1;
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b1101_0000_0000_0000_0000_0000; // 0.8125
    dataValid = 1'b1;
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b1011_0000_0000_0000_0000_0000; // 0.6875
    dataValid = 1'b1;
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b1111_0000_0000_0000_0000_0000; // 0.9375
    dataValid = 1'b1;
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b1000_1000_0000_0000_0000_0000; // 0.53125
    dataValid = 1'b1;
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    filter = 1'b0;
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b0001_1000_0000_0000_0000_0000_0000; // 1.5
    dataValid = 1'b1;
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b0010_1000_0000_0000_0000_0000_0000; // 2.5
    dataValid = 1'b1;
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b0011_1000_0000_0000_0000_0000_0000; // 3.5
    dataValid = 1'b1;
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b0100_1000_0000_0000_0000_0000_0000; // 4.5
    dataValid = 1'b1;
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b0101_1000_0000_0000_0000_0000_0000; // 5.5
    dataValid = 1'b1;
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b0110_1000_0000_0000_0000_0000_0000; // 6.5
    dataValid = 1'b1;
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b0111_1000_0000_0000_0000_0000_0000; // 7.5
    dataValid = 1'b1;
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b1000_1000_0000_0000_0000_0000_0000; // 8.5
    dataValid = 1'b1;
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b1001_1000_0000_0000_0000_0000_0000; // 9.5
    dataValid = 1'b0;
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    #10;
    clk = !clk;
  end

endmodule
