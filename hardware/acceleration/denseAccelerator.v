module denseAccelerator(input clk, input reset, input [31:0] dataIn,
                        input dataValid, input [31:0] length,
                        output [31:0] dataOut);

  // Define State Ids
  `define RESET 2'b00 // Default State
  `define ACT 2'b01 // The activation is read into a register
  `define WEIGHT 2'b10 // The weight is read and multiplied with the corresponding activation
  `define BIAS 2'b11 // The bias is added once the activations and weights have been multiplied

  wire [1:0] present_state;
  wire loadAct, loadWeight;
  wire signed [31:0] outWeight, outAct;
  reg signed [63:0] product;
  reg signed [31:0] shifted_product, sum;
  assign dataOut = sum;
  assign outWeight = dataIn;

  denseReg32 activation(clk, reset, loadAct, dataIn, outAct);
  SM sm(clk, reset, dataValid, length, loadAct, loadWeight, present_state);

  always @(posedge clk, negedge reset) begin
    if (!reset) begin
      product = 64'b0;
      shifted_product = 32'b0;
      sum = 32'b0;
    end
    else begin
      if (present_state == `RESET) begin
        product = 64'b0;
        shifted_product = 32'b0;
        sum = 32'b0;
      end
      else if (present_state == `WEIGHT) begin
        product = outAct * outWeight;
        shifted_product = product >>> 24;
        sum = sum + shifted_product;
      end
      else if (present_state == `BIAS)
        sum = sum + dataIn;
    end
  end

endmodule

module SM (input clk, input reset, input dataValid, input [31:0] length,
            output loadA, output loadW, output [1:0] state);

  // Define State Ids
  `define RESET 2'b00
  `define ACT 2'b01
  `define WEIGHT 2'b10
  `define BIAS 2'b11

  reg loadAct, loadWeight;
  reg [1:0] next_state, present_state;
  reg [31:0] count;

  assign state = present_state;
  assign loadA = loadAct;
  assign loadW = loadWeight;

  always @(posedge clk, negedge reset) begin
    if (!reset) begin
      present_state = `RESET;
      count = 32'b0001;
    end
    else begin
      if (next_state == `ACT && present_state == `WEIGHT)
        count = count + 1'b1;
      else if (next_state == `RESET)
        count = 32'b0001;
      present_state = next_state;
    end
  end

  always @(*) begin
    case(present_state)
      `RESET: begin
        loadAct = 1'b0;
        loadWeight = 1'b0;
        if (dataValid)
          next_state = `ACT;
        else
          next_state = `RESET;
      end
      `ACT: begin
        loadAct = 1'b1;
        loadWeight = 1'b0;
        if (dataValid)
          next_state = `WEIGHT;
        else
          next_state = `ACT;
      end
      `WEIGHT: begin
        loadAct = 1'b0;
        loadWeight = 1'b1;
        if (dataValid)
          if (count == length)
            next_state = `BIAS;
          else
            next_state = `ACT;
        else
          next_state = `WEIGHT;
      end
      `BIAS: begin
        loadAct = 1'b0;
        loadWeight = 1'b0;
        if (dataValid)
          next_state = `RESET;
        else
          next_state = `BIAS;
      end
      default: begin

      end
    endcase
  end

endmodule

// 32-bit register
module denseReg32(input clk, input reset, input load,
            input [31:0] in, output [31:0] out);

  reg [31:0] currVal;
  assign out = currVal;

  always @(posedge clk, negedge reset) begin
    if (reset == 1'b0)
      currVal <= 32'b00000000000000000000000000000000;
    else if (load == 1'b1)
      currVal <= in;
    else
      currVal <= out;
  end

endmodule

module vDFF(clk,D,Q);
  parameter n=1;
  input clk;
  input [n-1:0] D;
  output [n-1:0] Q;
  reg [n-1:0] Q;
  always @(posedge clk)
    Q <= D;
endmodule
