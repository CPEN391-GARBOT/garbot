module maxAccelerator(input clk, input reset, input [31:0] dataIn,
                      input dataValid, output [31:0] dataOut);

  reg [1:0] count;
  reg [31:0] max;
  assign dataOut = max;

  always @(posedge clk, negedge reset) begin
    if (!reset) begin
      max = 32'b0;
      count = 2'b0;
    end
    else if (dataValid) begin
      if (count == 2'b0)
        max <= dataIn; // if its the first value it is the max
      else if ((dataIn[31] == max[31]) && dataIn > max)
        max <= dataIn; // if both values are same sign
      else if (!dataIn[31] && max[31])
        max <= dataIn; // if max is negative and new value is positive
      count <= count + 1'b1;
    end
  end

endmodule 
