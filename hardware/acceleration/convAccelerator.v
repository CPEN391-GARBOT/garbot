module convAccelerator(input clk, input reset, input [31:0] dataIn,
                        input dataValid, input filter, output [31:0] dataOut);

  reg [3:0] count;
  reg signed [63:0] product;
  reg signed [31:0] shifted_product;
  reg signed [31:0] sum;
  wire signed [31:0] dataInSigned;
  assign dataOut = sum;
  assign dataInSigned = dataIn;

  reg loadFil1, loadFil2, loadFil3, loadFil4, loadFil5,
      loadFil6, loadFil7, loadFil8, loadFil9;
  wire signed [31:0] outFil1, outFil2, outFil3, outFil4, outFil5, outFil6,
      outFil7, outFil8, outFil9;

  // Registers to store filter values (3x3 means 9 registers)
  convReg32 regFil1(clk, reset, loadFil1, dataInSigned, outFil1);
  convReg32 regFil2(clk, reset, loadFil2, dataInSigned, outFil2);
  convReg32 regFil3(clk, reset, loadFil3, dataInSigned, outFil3);
  convReg32 regFil4(clk, reset, loadFil4, dataInSigned, outFil4);
  convReg32 regFil5(clk, reset, loadFil5, dataInSigned, outFil5);
  convReg32 regFil6(clk, reset, loadFil6, dataInSigned, outFil6);
  convReg32 regFil7(clk, reset, loadFil7, dataInSigned, outFil7);
  convReg32 regFil8(clk, reset, loadFil8, dataInSigned, outFil8);
  convReg32 regFil9(clk, reset, loadFil9, dataInSigned, outFil9);

  // Combinational Logic
  always @(*) begin
    loadFil1 = 1'b0; loadFil2 = 1'b0; loadFil3 = 1'b0;
    loadFil4 = 1'b0; loadFil5 = 1'b0; loadFil6 = 1'b0;
    loadFil7 = 1'b0; loadFil8 = 1'b0; loadFil9 = 1'b0;
    if (filter) begin
      case (count)
        4'b0001: loadFil1 = 1'b1;
        4'b0010: loadFil2 = 1'b1;
        4'b0011: loadFil3 = 1'b1;
        4'b0100: loadFil4 = 1'b1;
        4'b0101: loadFil5 = 1'b1;
        4'b0110: loadFil6 = 1'b1;
        4'b0111: loadFil7 = 1'b1;
        4'b1000: loadFil8 = 1'b1;
        4'b1001: loadFil9 = 1'b1;
        default: ;
      endcase
    end
  end

  // Sequential Logic
  always @(posedge clk, negedge reset) begin
    if (!reset) begin
      // Reset all values to 0
      count = 4'b0;
      product = 64'b0;
      shifted_product = 32'b0;
      sum = 32'b0;
    end
    else if (filter) begin
      // Fill in the filter values
      case(count)
        4'b0000: begin
          if (dataValid) begin
            count <= count + 1'b1;
          end
        end
        4'b0001: begin
          if (dataValid) begin
            count <= count + 1'b1;
          end
        end
        4'b0010: begin
          if (dataValid) begin
            count <= count + 1'b1;
          end
        end
        4'b0011: begin
          if (dataValid) begin
            count <= count + 1'b1;
          end
        end
        4'b0100: begin
          if (dataValid) begin
            count <= count + 1'b1;
          end
        end
        4'b0101: begin
          if (dataValid) begin
            count <= count + 1'b1;
          end
        end
        4'b0110: begin
          if (dataValid) begin
            count <= count + 1'b1;
          end
        end
        4'b0111: begin
          if (dataValid) begin
            count <= count + 1'b1;
          end
        end
        4'b1000: begin
          if (dataValid) begin
            count <= count + 1'b1;
          end
        end
        default: begin
          count <= 4'b0000;
        end
      endcase
    end
    else begin
      case (count)
        // If dataValid == 1'b1 then perform the current multiplication and add it to the sum
        4'b0000: begin
          if (dataValid) begin
            product = dataInSigned * outFil1;
            shifted_product = product >>> 24;
            sum = shifted_product;
            count <= count + 1'b1;
          end
        end
        4'b0001: begin
          if (dataValid) begin
            product = dataInSigned * outFil2;
            shifted_product = product >>> 24;
            sum = sum + shifted_product;
            count <= count + 1'b1;
          end
        end
        4'b0010: begin
          if (dataValid) begin
            product = dataInSigned * outFil3;
            shifted_product = product >>> 24;
            sum = sum + shifted_product;
            count <= count + 1'b1;
          end
        end
        4'b0011: begin
          if (dataValid) begin
            product = dataInSigned * outFil4;
            shifted_product = product >>> 24;
            sum = sum + shifted_product;
            count <= count + 1'b1;
          end
        end
        4'b0100: begin
          if (dataValid) begin
            product = dataInSigned * outFil5;
            shifted_product = product >>> 24;
            sum = sum + shifted_product;
            count <= count + 1'b1;
          end
        end
        4'b0101: begin
          if (dataValid) begin
            product = dataInSigned * outFil6;
            shifted_product = product >>> 24;
            sum = sum + shifted_product;
            count <= count + 1'b1;
          end
        end
        4'b0110: begin
          if (dataValid) begin
            product = dataInSigned * outFil7;
            shifted_product = product >>> 24;
            sum = sum + shifted_product;
            count <= count + 1'b1;
          end
        end
        4'b0111: begin
          if (dataValid) begin
            product = dataInSigned * outFil8;
            shifted_product = product >>> 24;
            sum = sum + shifted_product;
            count <= count + 1'b1;
          end
        end
        4'b1000: begin
          if (dataValid) begin
            product = dataInSigned * outFil9;
            shifted_product = product >>> 24;
            sum = sum + shifted_product;
            count <= count + 1'b1;
          end
        end
        default: begin
          count = 4'b0;
        end
      endcase
    end
  end

endmodule

// 32-bit register
module convReg32(input clk, input reset, input load,
            input [31:0] in, output [31:0] out);

  reg [31:0] currVal;
  assign out = currVal;

  always @(posedge clk, negedge reset) begin
    if (reset == 1'b0)
      currVal <= 32'b0;
    else if (load == 1'b1)
      currVal <= in;
    else
      currVal <= out;
  end

endmodule
