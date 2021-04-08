module convController(input clk, input reset,
                    // slave (CPU-facing)
                    output slave_waitrequest,
                    input [2:0] slave_address,
                    input slave_read, output [31:0] slave_readdata,
                    input slave_write, input [31:0] slave_writedata,
                    // master (SDRAM-facing)
                    input master_waitrequest,
                    output [31:0] master_address,
                    output master_read, input [31:0] master_readdata,
                    output master_write, output [31:0] master_writedata);

  reg [31:0] masterAddress, slaveReadData, masterWriteData;
  reg load0, load1, load2, load3, load4, load5, load6,
      dataValid, masterRead, masterWrite, slaveWaitRequest, filter, waiter;
  wire [31:0] word0, word1, word2, word3, word4, word5, word6, convOut;
  wire [63:0] outLayerSize;
  reg [3:0] count, countRow, countCol;
  reg [6:0] numRow, numCol, numLayer, numFilter;
  reg [15:0] numOps;
  reg [2:0] presentState, nextState;

  // State Definitions
  `define Wait 3'b000
  `define PreLoad 3'b001
  `define Filter 3'b010
  `define Calc 3'b011
  `define Read 3'b100
  `define Write 3'b101

  assign outLayerSize = (word6 - 2) * (word6 - 2);
  assign master_address = masterAddress * 3'b100;
  assign master_read = masterRead;
  assign master_write = masterWrite;
  assign master_writedata = masterWriteData;
  assign slave_waitrequest = slaveWaitRequest;
  assign slave_readdata = slaveReadData;

  convReg32 convReg0(clk, reset, load0, slave_writedata, word0); // start if written to
  convReg32 convReg1(clk, reset, load1, slave_writedata, word1); // input layers start address
  convReg32 convReg2(clk, reset, load2, slave_writedata, word2); // filter address
  convReg32 convReg3(clk, reset, load3, slave_writedata, word3); // output address
  convReg32 convReg4(clk, reset, load4, slave_writedata, word4); // # of layers
  convReg32 convReg5(clk, reset, load5, slave_writedata, word5); // # of filters
  convReg32 convReg6(clk, reset, load6, slave_writedata, word6); // row length
  convAccelerator convAcc(clk, reset, master_readdata, dataValid, filter, convOut);

  // Combinational logic
  always @(*) begin
    load0 = 1'b0; load1 = 1'b0; load2 = 1'b0; load3 = 1'b0; load4 = 1'b0;
    load5 = 1'b0; load6 = 1'b0;
    slaveReadData = 32'b0;
    if (slave_write) begin
      case (slave_address)
        3'b000: load0 = 1'b1;
        3'b001: load1 = 1'b1;
        3'b010: load2 = 1'b1;
        3'b011: load3 = 1'b1;
        3'b100: load4 = 1'b1;
        3'b101: load5 = 1'b1;
        3'b110: load6 = 1'b1;
      endcase
    end
    else if (slave_read) begin
      case (slave_address)
        3'b000: slaveReadData = word0;
        3'b001: slaveReadData = word1;
        3'b010: slaveReadData = word2;
        3'b011: slaveReadData = word3;
        3'b100: slaveReadData = word4;
        3'b101: slaveReadData = word5;
        3'b110: slaveReadData = word6;
      endcase
    end
  end

  // State Logic
  always @(*) begin
    slaveWaitRequest = 1'b1;
    masterRead = 1'b0;
    masterWrite = 1'b0;
    masterAddress = 32'b0;
    masterWriteData = 32'b0;
    dataValid = 1'b0;
    filter = 1'b0;
    case (presentState)
      `Wait: begin
        slaveWaitRequest = 1'b0;
        if (load0)
          nextState = `PreLoad;
        else
          nextState = `Wait;
      end
      `PreLoad: begin
        dataValid = 1'b1;
        filter = 1'b1;
        nextState = `Filter;
      end
      `Filter: begin
        dataValid = 1'b1;
        masterRead = 1'b1;
        masterAddress = word2 + count + numLayer * 9 + numFilter * word4 * 9;
        if (count + 1'b1 < 9) begin
          filter = 1'b1;
          nextState = `Filter;
        end
        else begin
          nextState = `Calc;
        end
      end
      `Calc: begin
        dataValid = 1'b1;
        masterRead = 1'b1;
        masterAddress = word1 + countCol + countRow * word6 +
                        numCol + numRow * word6 + numLayer * word6 * word6;
        if (count < 9) begin
          nextState = `Calc;
        end
        else begin
          nextState = `Read;
        end
      end
      `Read: begin
        masterRead = 1'b1;
        masterAddress = word3 + numOps + outLayerSize * numFilter;
        nextState = `Write;
      end
      `Write: begin
        masterWrite = 1'b1;
        masterAddress = word3 + numOps + outLayerSize * numFilter;
        if (numLayer == 1'b0)
          masterWriteData = convOut;
        else
          masterWriteData = convOut + master_readdata;
        if (numOps < (word6-2) * (word6-2))
          nextState = `Calc;
        else if (numLayer + 1'b1 >= word4 && numFilter + 1'b1 >= word5) begin
          nextState = `Wait;
          masterWriteData = masterWriteData[31] ? 32'b0 : masterWriteData;
        end
        else begin
          nextState = `Filter;
          dataValid = 1'b1;
          filter = 1'b1;
        end
      end
    endcase
  end

  // Sequential Logic
  always @(posedge clk, negedge reset) begin
    if (!reset) begin
      numRow = 7'b0; numCol = 7'b0; numLayer = 7'b0; numFilter = 7'b0;
      count = 4'b0; countRow = 4'b0; countCol = 4'b0; numOps = 16'b0; waiter = 1'b0;
      presentState = `Wait;
    end
    else begin
      if (nextState == `Filter && presentState == `Filter) begin
        count = count + 1'b1;
      end
      if (nextState == `Calc && presentState == `Filter) begin
        count = 4'b0;
      end
      if (nextState == `Calc && presentState == `Calc) begin
        count = count + 1'b1;
        countCol = countCol + 1'b1;
        if (countCol >= 3)  begin
          countCol = 4'b0;
          countRow = countRow + 1'b1;
        end
      end
      if (nextState == `Read && presentState == `Calc) begin
        countCol = 4'b0;
        countRow = 4'b0;
        count = 4'b0;
        numOps = numOps + 1'b1;
        numCol = numCol + 1'b1;
        // Check if we reached the end of a row
        if (numCol >= word6 - 2) begin
          numCol = 7'b0;
          numRow = numRow + 1'b1;
          // Check if we reached the end of a layer
          if (numRow >= word6 - 2) begin
            numRow = 7'b0;
          end
        end
      end
      if (nextState == `Filter && presentState == `Write) begin
        numOps = 16'b0;
        numLayer = numLayer + 1'b1;
        if (numLayer >= word4) begin
          numLayer = 7'b0;
          numFilter = numFilter + 1'b1;
        end
      end
      if (nextState == `Wait && presentState == `Write) begin
        numRow = 7'b0; numCol = 7'b0; numLayer = 7'b0; numFilter = 7'b0;
        count = 4'b0; countRow = 4'b0; countCol = 4'b0; numOps = 16'b0;
        presentState = `Wait;
      end
      if (!master_waitrequest || presentState == `Wait) begin
        if (waiter)
          presentState <= nextState;
        waiter = waiter + 1'b1;
      end
    end

  end

endmodule
