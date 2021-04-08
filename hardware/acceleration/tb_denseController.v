`timescale 1 ps / 1 ps

module tb_denseController();

  reg clk, reset, slave_read, slave_write, master_waitrequest;
  reg [2:0] slave_address;
  reg [31:0] slave_writedata;
  wire slave_waitrequest, master_read, master_write;
  wire [31:0] slave_readdata, master_address, master_writedata, master_readdata;
  reg [31:0] sdram[0:255];
  integer i;

  denseController DUT(clk, reset, slave_waitrequest, slave_address, slave_read,
              slave_readdata, slave_write, slave_writedata, master_waitrequest,
              master_address, master_read, master_readdata,
              master_write, master_writedata);

  assign master_readdata = sdram[master_address];

  initial begin
    // Weights
    sdram[1] = 32'b0000_0001_0000_0000_0000_0000_0000_0000;
    sdram[2] = 32'b0000_0010_0000_0000_0000_0000_0000_0000;
    sdram[3] = 32'b0000_0011_0000_0000_0000_0000_0000_0000;
    sdram[4] = 32'b0000_0100_0000_0000_0000_0000_0000_0000;
    sdram[5] = 32'b0000_0101_0000_0000_0000_0000_0000_0000;
    sdram[6] = 32'b0000_0110_0000_0000_0000_0000_0000_0000;
    sdram[7] = 32'b0000_0111_0000_0000_0000_0000_0000_0000;
    sdram[8] = 32'b0000_1000_0000_0000_0000_0000_0000_0000;
    sdram[9] = 32'b0000_1001_0000_0000_0000_0000_0000_0000;

    // Input Activations
    sdram[10] = 32'b0000_0000_1000_0000_0000_0000_0000_0000;
    sdram[11] = 32'b0000_0000_0100_0000_0000_0000_0000_0000;
    sdram[12] = 32'b0000_0000_0010_0000_0000_0000_0000_0000;

    // Bias Vector
    sdram[15] = 32'b1111_1111_0000_0000_0000_0000_0000_0000;
    sdram[16] = 32'b0000_0010_0000_0000_0000_0000_0000_0000;
    sdram[17] = 32'b1111_1101_0000_0000_0000_0000_0000_0000;

    // Test
    master_waitrequest = 1'b1;
    reset = 1'b0;
    #10;
    reset = 1'b1;
    #10;

    // word1 = 15
    clk = 1'b1;
    #10;
    slave_address = 3'b001;
    slave_writedata = 32'b0000_0000_0000_0000_0000_0000_0000_1111;
    slave_write = 1'b1;
    clk = 1'b0;
    #10;

    // word2 = 1
    clk = 1'b1;
    #10;
    slave_address = 3'b010;
    slave_writedata = 32'b0000_0000_0000_0000_0000_0000_0000_0001;
    clk = 1'b0;
    #10;

    // word3 = 10
    clk = 1'b1;
    #10;
    slave_address = 3'b011;
    slave_writedata = 32'b0000_0000_0000_0000_0000_0000_0000_1010;
    clk = 1'b0;
    #10;

    // word4 = 32
    clk = 1'b1;
    #10;
    slave_address = 3'b100;
    slave_writedata = 32'b0000_0000_0000_0000_0000_0000_0010_0000;
    clk = 1'b0;
    #10;

    // word5 = 3
    clk = 1'b1;
    #10;
    slave_address = 3'b101;
    slave_writedata = 32'b0000_0000_0000_0000_0000_0000_0000_0011;
    clk = 1'b0;
    #10;

    clk = 1'b1;
    #10;
    slave_address = 3'b000;
    slave_writedata = 32'b0;
    clk = 1'b0;
    #10;

    clk = 1'b1;
    #10;
    slave_write = 1'b0;
    clk = 1'b0;
    #10;

    clk = 1'b1;
    #10;
    master_waitrequest = 1'b0;
    clk = 1'b0;
    #10;

    for (i = 0; i < 70; i = i + 1) begin
      clk = 1'b1;
      #10;
      if (master_write)
        sdram[master_address] = master_writedata;
      clk = 1'b0;
      #10;
    end

    // Test 2
    // Weights
    sdram[100] = 32'b0000_0000_1000_0000_0000_0000_0000_0000;
    sdram[101] = 32'b0000_0001_0000_0000_0000_0000_0000_0000;
    sdram[102] = 32'b0000_0000_1000_0000_0000_0000_0000_0000;
    sdram[103] = 32'b0000_0001_0000_0000_0000_0000_0000_0000;
    sdram[104] = 32'b0000_0000_1000_0000_0000_0000_0000_0000;
    sdram[105] = 32'b0000_0001_0000_0000_0000_0000_0000_0000;
    sdram[106] = 32'b0000_0000_1000_0000_0000_0000_0000_0000;
    sdram[107] = 32'b0000_0001_0000_0000_0000_0000_0000_0000;
    sdram[108] = 32'b0000_0000_1000_0000_0000_0000_0000_0000;

    // Bias Vector
    sdram[15] = 32'b1111_0111_0000_0000_0000_0000_0000_0000;
    sdram[16] = 32'b0000_0001_0000_0000_0000_0000_0000_0000;
    sdram[17] = 32'b0000_0000_0000_0000_0000_0000_0000_0000;

    // word1 = 15
    clk = 1'b1;
    #10;
    slave_address = 3'b001;
    slave_writedata = 32'b0000_0000_0000_0000_0000_0000_0000_1111;
    slave_write = 1'b1;
    clk = 1'b0;
    #10;

    // word2 = 100
    clk = 1'b1;
    #10;
    slave_address = 3'b010;
    slave_writedata = 32'b0000_0000_0000_0000_0000_0000_0110_0100;
    clk = 1'b0;
    #10;

    // word3 = 32
    clk = 1'b1;
    #10;
    slave_address = 3'b011;
    slave_writedata = 32'b0000_0000_0000_0000_0000_0000_0010_0000;
    clk = 1'b0;
    #10;

    // word4 = 200
    clk = 1'b1;
    #10;
    slave_address = 3'b100;
    slave_writedata = 32'b0000_0000_0000_0000_0000_0000_1100_1000;
    clk = 1'b0;
    #10;

    clk = 1'b1;
    #10;
    slave_address = 3'b000;
    slave_writedata = 32'b0;
    clk = 1'b0;
    #10;

    clk = 1'b1;
    #10;
    slave_write = 1'b0;
    clk = 1'b0;
    #10;

    for (i = 0; i < 70; i = i + 1) begin
      clk = 1'b1;
      #10;
      if (master_write)
        sdram[master_address] = master_writedata;
      clk = 1'b0;
      #10;
    end
  end

endmodule
