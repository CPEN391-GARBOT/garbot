module tb_denseAccelerator();
  reg clk, reset, dataValid;
  reg [31:0] dataIn, length;
  wire [31:0] dataOut;
  reg err = 0;

  denseAccelerator DUT(clk, reset, dataIn, dataValid, length, dataOut);

  initial begin
    reset = 1'b0;
    #10;
    reset = 1'b1;
    clk = 1;

    dataValid = 1'b1;
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b0001_0000_0000_0000_0000_0000_0000; // weight1 = 1
    length = 32'b0011;
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b0001_0000_0000_0000_0000_0000_0000; // activation1 = 1
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b0010_0000_0000_0000_0000_0000_0000; // weight2 = 2
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b0010_0000_0000_0000_0000_0000_0000; // activation2 = 2
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b0011_0000_0000_0000_0000_0000_0000; // weight3 = 3
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b0011_0000_0000_0000_0000_0000_0000; // activation3 = 3
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b1_1110_0000_0000_0000_0000_0000_0000; // bias = 30
    #10;
    clk = !clk;
    #10;
    clk = !clk;

  end // initiial
endmodule
