`timescale 1ns / 1ps
 
module tb;
parameter ADDR_LEN = 14, MEM_DEPTH = 16384;

reg clk;
reg rst;
reg [7:0] testCount = 1;
reg [7:0] errorCount = 0;
wire [ADDR_LEN-1:0] addr_toRAM;
wire [31:0] data_toRAM, data_fromRAM;
wire [ADDR_LEN-1:0] pCounter;

initial begin
  clk = 1;
  forever
    #5 clk = ~clk;
end

initial begin
  rst = 1;
  repeat (10) @(posedge clk);
  rst <= #1 0;
  repeat (500) begin
    @(posedge clk);
    if (testCount-1 == 32) begin
      pCounterCheck(32,"BZJi");
      $display("Total Errors %d ", errorCount); 
      if (errorCount == 0) begin
        $display("Simulation Successfuly Completed!");
      end else begin
        $display("Simulation FAILED!!");
      end
      $finish;
    end
  end
  $display("Simulation finished due to Time Limit\nTested Count %d/33\nTotal Errors %d", testCount, errorCount);
  $display("Simulation FAILED!!");
  $finish;  
end

task memCheck;
input [31:0] memLocation, expectedValue;
input [47:0] instCode; 
begin
  if(blram.memory[memLocation] != expectedValue) begin
    $display("Error Found on test code %d, Instruction code %s, %d ns, RAM Addr %d,  expected %d, received %d", testCount -1, instCode, $time, memLocation, expectedValue, blram.memory[memLocation]);
    errorCount = errorCount + 1;
  end
end
endtask

task pCounterCheck;
input [31:0] pCounterExpected, instCode; 
begin
  if(pCounter != pCounterExpected) begin
    $display("Error Found on test code %d, Instruction code %s, %d ns expected %d, received %d", testCount -1, instCode, $time, pCounterExpected, pCounter);
    errorCount = errorCount + 1;
  end
end
endtask

always@(pCounter) begin
  if(!rst)begin
    case(testCount-1)
		0: memCheck(101, 2, "CP");
		1: memCheck(103, 5, "CPi");
		2: memCheck(104, 8, "SRL");
		3: memCheck(106, 40, "SRL");
		4: memCheck(108, 1, "SRLi");
		5: memCheck(109, 144, "SRLi");
		6: memCheck(110, 32'd4294967295, "NAND");
		7: memCheck(110, 0, "NAND");
		8: memCheck(112, 32'd4294967293, "NAND");
		9: memCheck(112, 2, "NAND");
		10: memCheck(114, 32'd4294967295, "NANDi");
		11: memCheck(114, 0, "NAND");
		12: memCheck(115, 32'd4294967293, "NANDi");
		13: memCheck(115, 2, "NAND");
		14: memCheck(116, 1, "LT");
		15: memCheck(117, 0, "LT");
		16: memCheck(118, 0, "LT");
		17: memCheck(120, 1, "LTi");
		18: memCheck(121, 0, "LTi");
		19: memCheck(122, 0, "LTi");
		20: memCheck(123, 0, "ADD");
		21: memCheck(124, 0, "ADDi");
		22: memCheck(125, 63, "MUL");
		23: memCheck(127, 27, "MULi");
		24: pCounterCheck(26, "BZJ");
		26: pCounterCheck(27, "BZJ");
		27: memCheck(133,3,"CPi");
		28: pCounterCheck(30,"BZJi");
		30: memCheck(136, 5, "CPI"); 
		31: memCheck(140, 5, " CPIi");
		32: memCheck(139, 140, "CPIi");
		33: begin
			pCounterCheck(32,"BZJi");
			$finish;
		end
		default: begin
			$display("Unexpected CHECK!! Test code %d, %d ns, opcode %d, operand A %d, operand B %d", testCount, $time, SimpleCPU.opcode, SimpleCPU.operand1, SimpleCPU.operand2);
		end
    endcase
    testCount = pCounter + 1;
  end
end

SimpleCPU SimpleCPU(
  .clk(clk),
  .rst(rst),
  .wrEn(wrEn),
  .data_fromRAM(data_fromRAM),
  .addr_toRAM(addr_toRAM),
  .data_toRAM(data_toRAM),
  .pCounter(pCounter)
);

blram #(ADDR_LEN, MEM_DEPTH) blram(
  .clk(clk),
  .rst(rst),
  .i_we(wrEn),
  .i_addr(addr_toRAM),
  .i_ram_data_in(data_toRAM),
  .o_ram_data_out(data_fromRAM)
);

endmodule
