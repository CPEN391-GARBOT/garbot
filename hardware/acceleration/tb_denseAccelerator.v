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

    // Test 1 [1 2 3][1 2 3] + 30 = 44
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
    if (dataOut == 32'b0010_1100_0000_0000_0000_0000_0000_0000) // Output = 44
			$display("Test 1 Passed");
		else begin
			$display("Test 1 Failed");
			err = 1'b1;
		end

    // Test 1 [4 5 6][1 2 3] + 30 = 62
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b0100_0000_0000_0000_0000_0000_0000; // weight1 = 4
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
    dataIn = 32'b0101_0000_0000_0000_0000_0000_0000; // weight2 = 5
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b0010_0000_0000_0000_0000_0000_0000; // activation2 = 2
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b0110_0000_0000_0000_0000_0000_0000; // weight3 = 6
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
    if (dataOut == 32'b11_1110_0000_0000_0000_0000_0000_0000) // Output = 62
			$display("Test 2 Passed");
		else begin
			$display("Test 2 Failed");
			err = 1'b1;
		end

    // Test 3 [7 8 9][1 2 3] + 30 = 80
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b0111_0000_0000_0000_0000_0000_0000; // weight1 = 7
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
    dataIn = 32'b1000_0000_0000_0000_0000_0000_0000; // weight2 = 8
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b0010_0000_0000_0000_0000_0000_0000; // activation2 = 2
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b1001_0000_0000_0000_0000_0000_0000; // weight3 = 9
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
    if (dataOut == 32'b0101_0000_0000_0000_0000_0000_0000_0000) // Output = 80
			$display("Test 3 Passed");
		else begin
			$display("Test 3 Failed");
			err = 1'b1;
		end

    // Test 4 [-1 2 -3][1 -2 -3] + 30 = 34
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b1111_1111_0000_0000_0000_0000_0000_0000; // weight1 = -1
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
    dataIn = 32'b1111_1110_0000_0000_0000_0000_0000_0000; // activation2 = -2
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b1111_1101_0000_0000_0000_0000_0000_0000; // weight3 = -3
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b1111_1101_0000_0000_0000_0000_0000_0000; // activation3 = -3
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b1_1110_0000_0000_0000_0000_0000_0000; // bias = 30
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    if (dataOut == 32'b10_0010_0000_0000_0000_0000_0000_0000) // Output = 34
			$display("Test 4 Passed");
		else begin
			$display("Test 4 Failed");
			err = 1'b1;
		end

    // Test 5 [-1 2 -3][1 -2 -3] + (-30) = -26
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b1111_1111_0000_0000_0000_0000_0000_0000; // weight1 = -1
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
    dataIn = 32'b1111_1110_0000_0000_0000_0000_0000_0000; // activation2 = -2
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b1111_1101_0000_0000_0000_0000_0000_0000; // weight3 = -3
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b1111_1101_0000_0000_0000_0000_0000_0000; // activation3 = -3
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b1110_0010_0000_0000_0000_0000_0000_0000; // bias = -30
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    if (dataOut == 32'b1110_0110_0000_0000_0000_0000_0000_0000) // Output = -26
			$display("Test 5 Passed");
		else begin
			$display("Test 5 Failed");
			err = 1'b1;
		end

    // Test 6 [-1.5 2.25 -3.125][1.875 -2.375 -3.625] + (-30) = -26.828125
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b1111_1110_1000_0000_0000_0000_0000_0000; // weight1 = -1.5
    length = 32'b0011;
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b0001_1110_0000_0000_0000_0000_0000; // activation1 = 1.875
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b0010_0100_0000_0000_0000_0000_0000; // weight2 = 2.25
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b1111_1101_0110_0000_0000_0000_0000_0000; // activation2 = -2.625
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b1111_1100_0010_0000_0000_0000_0000_0000; // weight3 = -3.875
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b1111_1100_1010_0000_0000_0000_0000_0000; // activation3 = -3.375
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b1110_0010_0000_0000_0000_0000_0000_0000; // bias = -30
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    if (dataOut == 32'b1110_0110_0101_1100_0000_0000_0000_0000) // Output = -25.640625
			$display("Test 6 Passed");
		else begin
			$display("Test 6 Failed");
			err = 1'b1;
		end

  end // initiial
endmodule
