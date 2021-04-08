module maxController(input clk, input reset,
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
  reg load0, load1, load2, load3, load4, dataValid, masterRead, masterWrite, slaveWaitRequest, waiter;
  wire [31:0] word0, word1, word2, word3, word4;
  reg [7:0] numRows, numCols, numLayer, numOps;
  reg [2:0] presentState, nextState;
  wire [63:0] opsPerLayer;

  assign opsPerLayer = (word4 >>> 1) * (word4 >>> 1);
  assign master_address = masterAddress * 3'b100; // Each entry is 32 bits which is 4 bytes
  assign master_read = masterRead;
  assign master_write = masterWrite;
  assign slave_waitrequest = slaveWaitRequest;
  assign slave_readdata = slaveReadData;

  `define Wait 3'b000 // Default State
  `define Go0 3'b001 // Read the first value
  `define Go1 3'b010 // Read the second value
  `define Go2 3'b011 // Read the third value
  `define Go3 3'b100 // Read the fourth value and write the max to memory
  `define PreGo 3'b101 // Prepare the read

  maxReg32 maxReg0(clk, reset, load0, slave_writedata, word0); // start if written to
  maxReg32 maxReg1(clk, reset, load1, slave_writedata, word1); // address to read from
  maxReg32 maxReg2(clk, reset, load2, slave_writedata, word2); // address to write to
  maxReg32 maxReg3(clk, reset, load3, slave_writedata, word3); // # of layers
  maxReg32 maxReg4(clk, reset, load4, slave_writedata, word4); // row length
  maxAccelerator maxAcc(clk, reset, master_readdata, dataValid, master_writedata);

  // Combinational logic
  always @(*) begin
    load0 = 1'b0; load1 = 1'b0; load2 = 1'b0; load3 = 1'b0; load4 = 1'b0;
    slaveReadData = 32'b0;
    // Handle Writes
    if (slave_write) begin
      case (slave_address)
        3'b000: load0 = 1'b1;
        3'b001: load1 = 1'b1;
        3'b010: load2 = 1'b1;
        3'b011: load3 = 1'b1;
        3'b100: load4 = 1'b1;
        default:;
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
          nextState = `PreGo;
        else
          nextState = `Wait;
      end
      `Go0: begin
        masterAddress = word1 + (numCols + 1'b1) + numRows * word4 + numLayer * word4 * word4;
        masterRead = 1'b1;
        nextState = `Go1;
        if (waiter)
          dataValid = 1'b1;
      end
      `Go1: begin
        masterAddress = word1 + numCols + (numRows + 1'b1) * word4 + numLayer * word4 * word4;
        masterRead = 1'b1;
        nextState = `Go2;
        if (waiter)
          dataValid = 1'b1;
      end
      `Go2: begin
        masterAddress = word1 + (numCols + 1'b1) + (numRows + 1'b1) * word4 + numLayer * word4 * word4;
        masterRead = 1'b1;
        nextState = `Go3;
        if (waiter)
          dataValid = 1'b1;
      end
      `Go3: begin
        masterAddress = word2 + numOps;
        masterWrite = 1'b1;
        if (numOps >= opsPerLayer * word3)
          nextState = `Wait;
        else
          nextState = `PreGo;
      end
      `PreGo: begin
        masterAddress = word1 + numCols + numRows * word4 + numLayer * word4 * word4;
        masterRead = 1'b1;
        nextState = `Go0;
        if (waiter)
          dataValid = 1'b1;
      end
      default: nextState = `Wait;
    endcase
  end

  // Sequential Logic
  always @(posedge clk, negedge reset) begin
    if (!reset) begin
      // Reset Values
      waiter = 1'b0;
      numRows = 8'b0;
      numCols = 8'b0;
      numLayer = 8'b0;
      numOps = 8'b0;
      presentState = `Wait;
    end
    else begin
      // If we are starting a new cycle increment the position values
      if (nextState == `PreGo && presentState != `Wait) begin
        numCols = numCols + 2'b10;
        numOps = numOps + 1'b1;
        if (numCols >= word4) begin
          numRows = numRows + 2'b10;
          numCols = 8'b0;
          if (numRows >= word4) begin
            numLayer = numLayer + 1'b1;
            numRows = 8'b0;
          end
        end
      end
      // Reset values if returning to default state
      if (nextState == `Wait) begin
        numRows = 8'b0;
        numCols = 8'b0;
        numLayer = 8'b0;
        numOps = 8'b0;
      end
      if (!master_waitrequest || presentState == `Wait) begin
        if (waiter)
          presentState <= nextState;
        waiter = waiter + 1'b1;
      end
    end
  end

endmodule

// 32-bit register
module maxReg32(input clk, input reset, input load,
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
