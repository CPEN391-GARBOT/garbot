module tb_maxAccelerator();
  reg clk, reset, dataValid;
  reg [31:0] dataIn;
  wire [31:0] dataOut;
  reg err = 0;

  maxAccelerator DUT(clk, reset, dataIn, dataValid, dataOut);

  initial begin
    reset = 1'b0;
    #10;
    reset = 1'b1;
    clk = 1;

    // Test 1: 0.5, 3.5, 2.5, 1.5
    dataIn = 32'b1000_0000_0000_0000_0000_0000; // 0.5
    dataValid = 1'b1;
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b0011_1000_0000_0000_0000_0000_0000; // 3.5
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b0010_1000_0000_0000_0000_0000_0000; // 2.5
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b0001_1000_0000_0000_0000_0000_0000; // 1.5
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataValid = 1'b0;
    #10;
    clk = !clk;
    #10;
    clk = !clk;

    if (dataOut == 32'b0011_1000_0000_0000_0000_0000_0000) // Max should be 3.5
			$display("Test 1 Passed");
		else begin
			$display("Test 1 Failed");
			err = 1'b1;
		end

    // Test 2: 4, 3, 2, 1
    dataIn = 32'b0100_0000_0000_0000_0000_0000_0000; // 4
    dataValid = 1'b1;
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b0011_0000_0000_0000_0000_0000_0000; // 3
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b0010_0000_0000_0000_0000_0000_0000; // 2
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b0001_0000_0000_0000_0000_0000_0000; // 1
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataValid = 1'b0;
    #10;
    clk = !clk;
    #10;
    clk = !clk;

    if (dataOut == 32'b0100_0000_0000_0000_0000_0000_0000) // Max should be 4
			$display("Test 2 Passed");
		else begin
			$display("Test 2 Failed");
			err = 1'b1;
		end

    // Test 3: -2, -3, 0, -1
    dataIn = 32'b1111_1110_0000_0000_0000_0000_0000_0000; // -2
    dataValid = 1'b1;
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b1111_1101_0000_0000_0000_0000_0000_0000; // -3
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b0; // 0
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b1111_1111_0000_0000_0000_0000_0000_0000; // -1
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataValid = 1'b0;
    #10;
    clk = !clk;
    #10;
    clk = !clk;

    if (dataOut == 32'b0) // Max should be 0
			$display("Test 3 Passed");
		else begin
			$display("Test 3 Failed");
			err = 1'b1;
		end

    // Test 3: -2, -3, -4, -1
    dataIn = 32'b1111_1110_0000_0000_0000_0000_0000_0000; // -2
    dataValid = 1'b1;
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b1111_1101_0000_0000_0000_0000_0000_0000; // -3
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b1111_1100_0000_0000_0000_0000_0000_0000; // -4
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b1111_1111_0000_0000_0000_0000_0000_0000; // -1
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataValid = 1'b0;
    #10;
    clk = !clk;
    #10;
    clk = !clk;

    if (dataOut == 32'b1111_1111_0000_0000_0000_0000_0000_0000) // Max should be -1
			$display("Test 4 Passed");
		else begin
			$display("Test 4 Failed");
			err = 1'b1;
		end

  end // end initial
endmodule
