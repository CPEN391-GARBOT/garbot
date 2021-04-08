module tb_convAccelerator();
  reg clk, reset, dataValid, filter;
  reg [31:0] dataIn;
  wire [31:0] dataOut;
  reg err = 0;

  convAccelerator DUT(clk, reset, dataIn, dataValid, filter, dataOut);

  initial begin
    reset = 1'b0;
    #10;
    reset = 1'b1;
    clk = 1;

    // Test 1
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
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b1010_0000_0000_0000_0000_0000; // 0.625
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b1110_0000_0000_0000_0000_0000; // 0.875
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b1001_0000_0000_0000_0000_0000; // 0.5625
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b1101_0000_0000_0000_0000_0000; // 0.8125
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b1011_0000_0000_0000_0000_0000; // 0.6875
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b1111_0000_0000_0000_0000_0000; // 0.9375
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b1000_1000_0000_0000_0000_0000; // 0.53125
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    
    filter = 1'b0;
    dataIn = 32'b0001_1000_0000_0000_0000_0000_0000; // 1.5
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b0010_1000_0000_0000_0000_0000_0000; // 2.5
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b0011_1000_0000_0000_0000_0000_0000; // 3.5
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b0100_1000_0000_0000_0000_0000_0000; // 4.5
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b0101_1000_0000_0000_0000_0000_0000; // 5.5
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b0110_1000_0000_0000_0000_0000_0000; // 6.5
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b0111_1000_0000_0000_0000_0000_0000; // 7.5
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b1000_1000_0000_0000_0000_0000_0000; // 8.5
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b1001_1000_0000_0000_0000_0000_0000; // 9.5
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataValid = 1'b0;

    if (dataOut == 32'b0010_0011_0100_1100_0000_0000_0000_0000) // Output = 35.296875
			$display("Test 1 Passed");
		else begin
			$display("Test 1 Failed");
			err = 1'b1;
		end

    // Reset count to 0
    #10;
    clk = !clk;
    #10;
    clk = !clk;

    // Test 2
    dataValid = 1'b1;
    dataIn = 32'b1111_1111_0000_0000_0000_0000_0000_0000; // -1
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b1111_1111_1000_0000_0000_0000_0000_0000; // -0.5
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b1111_1111_0100_0000_0000_0000_0000_0000; // -0.75
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b1111_1111_0010_0000_0000_0000_0000_0000; // -0.875
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b1111_1111_0001_0000_0000_0000_0000_0000; // -0.9375
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b1111_1111_1100_0000_0000_0000_0000_0000; // -0.25
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b1111_1111_1110_0000_0000_0000_0000_0000; // -0.125
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b1111_1111_1111_0000_0000_0000_0000_0000; // -0.0625
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b1111_1111_0000_1000_0000_0000_0000_0000; // -0.96875
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    if (dataOut == 32'b1111_1100_1000_0000_0100_0000_0000_0000) // Output = -3.499023438 (-58703872)
			$display("Test 2 Passed");
		else begin
			$display("Test 2 Failed");
			err = 1'b1;
		end

    // Test 3: Switch filter values
    filter = 1'b1;
    dataValid = 1'b1;
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b1111_1111_0000_0000_0000_0000_0000_0000; // -1
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b0000_0010_0000_0000_0000_0000_0000_0000; // 2
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b1111_1101_0000_0000_0000_0000_0000_0000; // -3
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b0000_0100_0000_0000_0000_0000_0000_0000; // 4
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b1111_1011_0000_0000_0000_0000_0000_0000; // -5
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b0000_0110_0000_0000_0000_0000_0000_0000; // 6
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b1111_1001_0000_0000_0000_0000_0000_0000; // -7
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b0000_1000_0000_0000_0000_0000_0000_0000; // 8
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b1111_0111_0000_0000_0000_0000_0000_0000; // -9
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    filter = 1'b0;
    dataIn = 32'b1111_1111_1000_0000_0000_0000_0000_0000; // -0.5
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b1111_1111_1000_0000_0000_0000_0000_0000; // -0.5
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b1111_1111_1000_0000_0000_0000_0000_0000; // -0.5
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b1111_1111_1000_0000_0000_0000_0000_0000; // -0.5
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b0000_0000_1000_0000_0000_0000_0000_0000; // 0.5
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b0000_0000_1000_0000_0000_0000_0000_0000; // 0.5
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b0000_0000_1000_0000_0000_0000_0000_0000; // 0.5
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b0000_0000_1000_0000_0000_0000_0000_0000; // 0.5
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    dataIn = 32'b0000_0000_1000_0000_0000_0000_0000_0000; // 0.5
    #10;
    clk = !clk;
    #10;
    clk = !clk;
    if (dataOut == 32'b1111_1011_1000_0000_0000_0000_0000_0000) // Output = -4.5 (-75497472)
			$display("Test 3 Passed");
		else begin
			$display("Test 3 Failed");
			err = 1'b1;
		end

  end

endmodule
