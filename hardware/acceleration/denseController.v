module denseController(input clk, input reset,
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

  reg [31:0] masterAddress, slaveReadData;
  reg load0, load1, load2, load3, load4, load5, dataValid, masterRead,
      masterWrite, slaveWaitRequest, waiter;
  wire [31:0] word0, word1, word2, word3, word4, word5, denseOut;
  reg [11:0] numCols, numRows;
  reg [2:0] presentState, nextState;

  // State Definitions
  `define Wait 3'b000 // Default State
  `define PreLoad 3'b001 // Preload the first activation
  `define Act 3'b010 // Read the activation and prepare to read the weight
  `define Weight 3'b011 // Read the weight and multiply it with the activation
  `define Bias 3'b100 // Add the bias once the activations and weights have been multiplied
  `define Write 3'b101 // Write the result to SDRAM

  assign master_address = masterAddress * 3'b100; // Each entry is 32 bits which is 4 bytes
  assign master_read = masterRead;
  assign master_write = masterWrite;
  assign slave_waitrequest = slaveWaitRequest;
  assign slave_readdata = slaveReadData;
  assign master_writedata = denseOut[31] ? 32'b0 : denseOut; // ReLU Function

  denseReg32 denseReg0(clk, reset, load0, slave_writedata, word0); // start if written to
  denseReg32 denseReg1(clk, reset, load1, slave_writedata, word1); // bias vector address
  denseReg32 denseReg2(clk, reset, load2, slave_writedata, word2); // weight matrix address
  denseReg32 denseReg3(clk, reset, load3, slave_writedata, word3); // input activations address
  denseReg32 denseReg4(clk, reset, load4, slave_writedata, word4); // output activations address
  denseReg32 denseReg5(clk, reset, load5, slave_writedata, word5); // input activations length
  denseAccelerator denseAcc(clk, reset, master_readdata, dataValid, word5, denseOut);

  // Combinational logic
  always @(*) begin
    load0 = 1'b0; load1 = 1'b0; load2 = 1'b0; load3 = 1'b0; load4 = 1'b0; load5 = 1'b0;
    slaveReadData = 32'b0;
    // Handle writes
    if (slave_write) begin
      case (slave_address)
        3'b000: load0 = 1'b1;
        3'b001: load1 = 1'b1;
        3'b010: load2 = 1'b1;
        3'b011: load3 = 1'b1;
        3'b100: load4 = 1'b1;
        3'b101: load5 = 1'b1;
        default: ;
      endcase
    end
    // Handle Reads
    else if (slave_read) begin
      case (slave_address)
        3'b000: slaveReadData = word0;
        3'b001: slaveReadData = word1;
        3'b010: slaveReadData = word2;
        3'b011: slaveReadData = word3;
        3'b100: slaveReadData = word4;
        3'b101: slaveReadData = word5;
        default: slaveReadData = 32'b0;
      endcase
    end
  end

  // State Logic
  always @(*) begin
    slaveWaitRequest = 1'b1;
    masterRead = 1'b0;
    masterWrite = 1'b0;
    masterAddress = 32'b0;
    dataValid = 1'b0;
    case (presentState)
      `Wait: begin
        slaveWaitRequest = 1'b0;
        if (load0)
          nextState = `PreLoad;
        else
          nextState = `Wait;
      end
      `PreLoad: begin
        if (waiter)
          dataValid = 1'b1;
        nextState = `Act;
      end
      `Act: begin
        masterRead = 1'b1;
        if (waiter)
          dataValid = 1'b1;
        if (numCols < word5) begin
          masterAddress = word2 + numCols + numRows * word5;
          nextState = `Weight;
        end
        else begin
          masterAddress = word1 + numRows;
          nextState = `Bias;
        end
      end
      `Weight: begin
        masterAddress = word3 + numCols;
        masterRead = 1'b1;
        if (waiter)
          dataValid = 1'b1;
        nextState = `Act;
      end
      `Bias: begin
        masterAddress = word4 + numRows;
        masterWrite = 1'b1;
        if (numRows + 1'b1 < word5) begin
          if (waiter)
            dataValid = 1'b1;
          nextState = `Write;
        end
        else begin
          dataValid = 1'b0;
          nextState = `Wait;
        end
      end
      `Write: begin
        masterAddress = word2 + numCols + numRows * word5;
        masterRead = 1'b1;
        if (waiter)
          dataValid = 1'b1;
        nextState = `Weight;
      end
      default: nextState = `Wait;
    endcase
    if (master_waitrequest)
      dataValid = 1'b0;
  end

  // Sequential Logic
  always @(posedge clk, negedge reset) begin
    if (!reset) begin
      waiter = 1'b0;
      numRows = 12'b0;
      numCols = 12'b0;
      presentState = `Wait;
    end
    else begin
      // If the next state is write it means we reached the end of a row of weights
      if (nextState == `Write) begin
        numRows = numRows + 1'b1;
        numCols = 12'b0;
      end
      // Increment which weight is being read
      if (nextState == `Act && presentState == `Weight)
        numCols = numCols + 1'b1;
      // Reset values when returning to default state
      if (nextState == `Wait) begin
        numRows = 12'b0;
        numCols = 12'b0;
      end
      if (!master_waitrequest || presentState == `Wait)
        if (waiter)
          presentState <= nextState;
        waiter = waiter + 1'b1;
    end
  end

endmodule
