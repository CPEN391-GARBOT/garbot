`timescale 1 ps / 1 ps

module tb_convController();

  reg clk, reset, slave_read, slave_write, master_waitrequest;
  reg [2:0] slave_address;
  reg [31:0] slave_writedata;
  wire slave_waitrequest, master_read, master_write;
  wire [31:0] slave_readdata, master_address, master_writedata, master_readdata;
  reg [31:0] sdram[0:511];
  integer i;

  convController DUT(clk, reset, slave_waitrequest, slave_address, slave_read,
              slave_readdata, slave_write, slave_writedata, master_waitrequest,
              master_address, master_read, master_readdata,
              master_write, master_writedata);

  assign master_readdata = sdram[master_address / 4];

  initial begin
    // Input Layers
    for (i = 1; i < 109; i = i + 1) begin
      //sdram[i] = i * 32'b0000_0000_0000_0010_0000_0000_0000_0000;
      sdram[i] = 32'b0000_0001_0000_0000_0000_0000_0000_0000;
    end

    // Filter 1
    for (i = 1; i < 28; i = i + 1) begin
      sdram[i + 127] = (28 - i) * 32'b0000_0000_0100_0000_0000_0000_0000_0000;
    end

    // Filter 2
    for (i = 0; i < 27; i = i + 1) begin
      sdram[i + 155] = i * 32'b0000_0000_0100_0000_0000_0000_0000_0000;
    end

    // Test
    master_waitrequest = 1'b0;
    reset = 1'b0;
    #10;
    reset = 1'b1;
    #10;

    // word1 = 1
    clk = 1'b1;
    #10;
    slave_address = 3'b001;
    slave_writedata = 32'b0000_0000_0000_0000_0000_0000_0000_0001;
    slave_write = 1'b1;
    clk = 1'b0;
    #10;

    // word2 = 128
    clk = 1'b1;
    #10;
    slave_address = 3'b010;
    slave_writedata = 32'b0000_0000_0000_0000_0000_0000_1000_0000;
    clk = 1'b0;
    #10;

    // word3 = 256
    clk = 1'b1;
    #10;
    slave_address = 3'b011;
    slave_writedata = 32'b0000_0000_0000_0000_0000_0001_0000_0000;
    clk = 1'b0;
    #10;

    // word4 = 3
    clk = 1'b1;
    #10;
    slave_address = 3'b100;
    slave_writedata = 32'b0000_0000_0000_0000_0000_0000_0000_0011;
    clk = 1'b0;
    #10;

    // word5 = 2
    clk = 1'b1;
    #10;
    slave_address = 3'b101;
    slave_writedata = 32'b0000_0000_0000_0000_0000_0000_0000_0010;
    clk = 1'b0;
    #10;

    // word6 = 6
    clk = 1'b1;
    #10;
    slave_address = 3'b110;
    slave_writedata = 32'b0000_0000_0000_0000_0000_0000_0000_0110;
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

    for (i = 0; i < 1400; i = i + 1) begin
      clk = 1'b1;
      #10;
      if (master_write)
        sdram[master_address / 4] = master_writedata;
      clk = 1'b0;
      #10;
    end

  end
endmodule
