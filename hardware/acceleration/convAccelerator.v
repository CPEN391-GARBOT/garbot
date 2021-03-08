module convAccelerator(input clk, input reset, input [31:0] dataIn,
                        input dataValid, input filter, output [31:0] dataOut);

  reg [4:0] count;
  reg [63:0] product;
  reg [31:0] shifted_product;
  reg [31:0] sum;
  assign dataOut = sum;

  reg loadAct1, loadAct2, loadAct3, loadAct4, loadAct5, loadAct6, loadAct7,
      loadAct8, loadAct9, loadFil1, loadFil2, loadFil3, loadFil4, loadFil5,
      loadFil6, loadFil7, loadFil8, loadFil9;
  wire [31:0] outAct1, outAct2, outAct3, outAct4, outAct5, outAct6, outAct7,
      outAct8, outAct9, outFil1, outFil2, outFil3, outFil4, outFil5, outFil6,
      outFil7, outFil8, outFil9;

  // Registers to store current activations that are being manipulated
  reg32 regAct1(clk, reset, loadAct1, dataIn, outAct1);
  reg32 regAct2(clk, reset, loadAct2, dataIn, outAct2);
  reg32 regAct3(clk, reset, loadAct3, dataIn, outAct3);
  reg32 regAct4(clk, reset, loadAct4, dataIn, outAct4);
  reg32 regAct5(clk, reset, loadAct5, dataIn, outAct5);
  reg32 regAct6(clk, reset, loadAct6, dataIn, outAct6);
  reg32 regAct7(clk, reset, loadAct7, dataIn, outAct7);
  reg32 regAct8(clk, reset, loadAct8, dataIn, outAct8);
  reg32 regAct9(clk, reset, loadAct9, dataIn, outAct9);

  // Registers to store filter values (3x3 means 9 registers)
  reg32 regFil1(clk, reset, loadFil1, dataIn, outFil1);
  reg32 regFil2(clk, reset, loadFil2, dataIn, outFil2);
  reg32 regFil3(clk, reset, loadFil3, dataIn, outFil3);
  reg32 regFil4(clk, reset, loadFil4, dataIn, outFil4);
  reg32 regFil5(clk, reset, loadFil5, dataIn, outFil5);
  reg32 regFil6(clk, reset, loadFil6, dataIn, outFil6);
  reg32 regFil7(clk, reset, loadFil7, dataIn, outFil7);
  reg32 regFil8(clk, reset, loadFil8, dataIn, outFil8);
  reg32 regFil9(clk, reset, loadFil9, dataIn, outFil9);

  always @(posedge clk, negedge reset) begin
    if (!reset) begin
      // Reset all values to 0
      loadAct1 = 1'b0; loadAct2 = 1'b0; loadAct3 = 1'b0; loadAct4 = 1'b0;
      loadAct5 = 1'b0; loadAct6 = 1'b0; loadAct7 = 1'b0; loadAct8 = 1'b0;
      loadAct9 = 1'b0; loadFil1 = 1'b0; loadFil2 = 1'b0; loadFil3 = 1'b0;
      loadFil4 = 1'b0; loadFil5 = 1'b0; loadFil6 = 1'b0; loadFil7 = 1'b0;
      loadFil8 = 1'b0; loadFil9 = 1'b0;
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
            loadFil1 = 1'b1;
            count <= count + 1'b1;
          end
        end
        4'b0001: begin
          loadFil1 = 1'b0;
          if (dataValid) begin
            loadFil2 = 1'b1;
            count <= count + 1'b1;
          end
        end
        4'b0010: begin
          loadFil2 = 1'b0;
          if (dataValid) begin
            loadFil3 = 1'b1;
            count <= count + 1'b1;
          end
        end
        4'b0011: begin
          loadFil3 = 1'b0;
          if (dataValid) begin
            loadFil4 = 1'b1;
            count <= count + 1'b1;
          end
        end
        4'b0100: begin
          loadFil4 = 1'b0;
          if (dataValid) begin
            loadFil5 = 1'b1;
            count <= count + 1'b1;
          end
        end
        4'b0101: begin
          loadFil5 = 1'b0;
          if (dataValid) begin
            loadFil6 = 1'b1;
            count <= count + 1'b1;
          end
        end
        4'b0110: begin
          loadFil6 = 1'b0;
          if (dataValid) begin
            loadFil7 = 1'b1;
            count <= count + 1'b1;
          end
        end
        4'b0111: begin
          loadFil7 = 1'b0;
          if (dataValid) begin
            loadFil8 = 1'b1;
            count <= count + 1'b1;
          end
        end
        4'b1000: begin
          loadFil8 = 1'b0;
          if (dataValid) begin
            loadFil9 = 1'b1;
            count <= count + 1'b1;
          end
        end
        default: begin
          loadFil9 = 1'b0;
          count <= 4'b0000;
        end
      endcase
    end
    else begin
      // Each clock cycle a new value is calculated and added to the sum
      case(count)
        4'b0000: begin
          if (dataValid) begin
            sum = 32'b0;
            loadAct1 = 1'b1;
            count <= count + 1'b1;
          end
        end
        4'b0001: begin
          loadAct1 = 1'b0;
          if (dataValid) begin
            loadAct2 = 1'b1;
            count <= count + 1'b1;
          end
        end
        4'b0010: begin
          loadAct2 = 1'b0;
          if (dataValid) begin
            loadAct3 = 1'b1;
            product = outAct1 * outFil1;
            shifted_product = product >>> 24;
            sum = sum + shifted_product;
            count <= count + 1'b1;
          end
        end
        4'b0011: begin
          loadAct3 = 1'b0;
          if (dataValid) begin
            loadAct4 = 1'b1;
            product = outAct2 * outFil2;
            shifted_product = product >>> 24;
            sum = sum + shifted_product;
            count <= count + 1'b1;
          end
        end
        4'b0100: begin
          loadAct4 = 1'b0;
          if (dataValid) begin
            loadAct5 = 1'b1;
            product = outAct3 * outFil3;
            shifted_product = product >>> 24;
            sum = sum + shifted_product;
            count <= count + 1'b1;
          end
        end
        4'b0101: begin
          loadAct5 = 1'b0;
          if (dataValid) begin
            loadAct6 = 1'b1;
            product = outAct4 * outFil4;
            shifted_product = product >>> 24;
            sum = sum + shifted_product;
            count <= count + 1'b1;
          end
        end
        4'b0110: begin
          loadAct6 = 1'b0;
          if (dataValid) begin
            loadAct7 = 1'b1;
            product = outAct5 * outFil5;
            shifted_product = product >>> 24;
            sum = sum + shifted_product;
            count <= count + 1'b1;
          end
        end
        4'b0111: begin
          loadAct7 = 1'b0;
          if (dataValid) begin
            loadAct8 = 1'b1;
            product = outAct6 * outFil6;
            shifted_product = product >>> 24;
            sum = sum + shifted_product;
            count <= count + 1'b1;
          end
        end
        4'b1000: begin
          loadAct8 = 1'b0;
          if (dataValid) begin
            loadAct9 = 1'b1;
            product = outAct7 * outFil7;
            shifted_product = product >>> 24;
            sum = sum + shifted_product;
            count <= count + 1'b1;
          end
        end
        4'b1001: begin
          loadAct9 = 1'b0;
          product = outAct8 * outFil8;
          shifted_product = product >>> 24;
          sum = sum + shifted_product;
          count <= count + 1'b1;
        end
        4'b1010: begin
          product = outAct9 * outFil9;
          shifted_product = product >>> 24;
          sum = sum + shifted_product;
          count <= count + 1'b1;
        end
        default: begin
          if (dataValid) begin
            count = 4'b0;
          end
        end
      endcase
    end
  end

endmodule: convAccelerator

// 32-bit register
module reg32(input clk, input reset, input load,
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

endmodule: reg32
