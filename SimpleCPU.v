`timescale 1ns / 1ps
module SimpleCPU(clk, rst, data_fromRAM, wrEn, addr_toRAM, data_toRAM, pCounter);
 
parameter ADDR_LEN = 14;

input clk, rst;
input wire [31:0] data_fromRAM;
output reg wrEn;
output reg [ADDR_LEN-1:0] addr_toRAM;
output reg [31:0] data_toRAM;
output reg [ADDR_LEN-1:0] pCounter;

// internal signals
reg [ADDR_LEN-1:0] pCounterNext;
reg [ 3:0] opcode, opcodeNext;
reg [13:0] operand1, operand2, operand1Next, operand2Next;
reg [31:0] num1, num2, num1Next, num2Next;
reg [ 2:0] state, stateNext;


always @(posedge clk)begin
	state    <= #1 stateNext;
	pCounter <= #1 pCounterNext;
	opcode   <= #1 opcodeNext;
	operand1 <= #1 operand1Next;
	operand2 <= #1 operand2Next;
	num1     <= #1 num1Next;
	num2     <= #1 num2Next;
end

always @*begin
	stateNext    = state;
	pCounterNext = pCounter;
	opcodeNext   = opcode;
	operand1Next = operand1;
	operand2Next = operand2;
	num1Next     = num1;
	num2Next     = num2;
	addr_toRAM   = 0;
	wrEn         = 0;
	data_toRAM   = 0;
if(rst)
	begin
	stateNext    = 0;
	pCounterNext = 0;
	opcodeNext   = 0;
	operand1Next = 0;
	operand2Next = 0;
	num1Next     = 0;
	num2Next     = 0;
	addr_toRAM   = 0;
	wrEn         = 0;
	data_toRAM   = 0;
	end
else 
	case(state)                       
		0: begin // "addr_toRAM = 0" => read first memory location 
			pCounterNext = pCounter;
			opcodeNext   = opcode;
			operand1Next = 0;
			operand2Next = 0;
			addr_toRAM   = pCounter;
			num1Next     = 0;
			num2Next     = 0;
			wrEn         = 0;
			data_toRAM   = 0;
			stateNext    = 1;
		end 
		1:begin // take opcode and request *A
			pCounterNext = pCounter;
			opcodeNext   = data_fromRAM[31:28];
			operand1Next = data_fromRAM[27:14];
			operand2Next = data_fromRAM[13: 0];
			addr_toRAM   = data_fromRAM[27:14];
			num1Next     = 0;
			num2Next     = 0;
			wrEn         = 0;
			data_toRAM   = 0;
			case(opcodeNext)
				4'b0000: stateNext = 2; // ADD
				4'b0001: stateNext = 4; // ADDi 
				4'b0010: stateNext = 2; // NAND
				4'b0011: stateNext = 4; // NANDi
				4'b0100: stateNext = 2; // SRL 
				4'b0101: stateNext = 4; // SRLi
				4'b0110: stateNext = 2; // LT
				4'b0111: stateNext = 4; // LTi
				4'b1000: stateNext = 2; // CP 
				4'b1001: stateNext = 4; // CPi 
				4'b1010: stateNext = 5; // CPI
				4'b1011: stateNext = 5; // CPIi
				4'b1100: stateNext = 2; // BZJ
				4'b1101: stateNext = 4; // BZJi
				4'b1110: stateNext = 2; // MUL
				4'b1111: stateNext = 4; // MULi
			endcase
		end
		2: begin // request *B and take *A
			pCounterNext = pCounter;
			opcodeNext   = opcode;
			operand1Next = operand1;
			operand2Next = operand2;
			addr_toRAM   = operand2;
			num1Next     = data_fromRAM;
			num2Next     = 0;
			wrEn         = 0;
			data_toRAM   = 0;
			stateNext    = 3;
		end
		3: begin // take *B 
			pCounterNext = pCounter + 1;
			opcodeNext   = opcode;
			operand1Next = operand1;
			operand2Next = operand2;
			num1Next     = num1;
			num2Next     = data_fromRAM;
			addr_toRAM   = operand1;
			wrEn         = 1;
			if(data_fromRAM == 0) begin
				pCounterNext = num1;
				data_toRAM   = 0;
				addr_toRAM   = 0;
				wrEn         = 0;
			end
			case(opcode)
				4'b0000: data_toRAM = num1 + data_fromRAM;
				4'b0010: data_toRAM = ~(num1 & data_fromRAM);
				4'b0100: data_toRAM = (data_fromRAM < 32) ? ((num1) >> (data_fromRAM)) : ((num1) << ((data_fromRAM) - 32));
				4'b0110: data_toRAM = num1 < data_fromRAM;
				4'b1000: data_toRAM = data_fromRAM; 
				4'b1110: data_toRAM = num1 * data_fromRAM;
			endcase
			stateNext = 0;
		end
		4: begin 
			pCounterNext = pCounter + 1;
			opcodeNext   = opcode;
			operand1Next = operand1;
			operand2Next = operand2;
			addr_toRAM   = operand1;
			num1Next     = data_fromRAM;
			num2Next     = operand2;
			wrEn         = 1;
			if(opcode == 4'b1101) begin
				pCounterNext = data_fromRAM + operand2;
				data_toRAM   = 32'hFFFF_FFFF;
				wrEn         = 0;
			end
			case(opcode)
				4'b0001: data_toRAM = data_fromRAM + operand2;
				4'b0011: data_toRAM = ~(data_fromRAM & operand2);
				4'b0101: data_toRAM = (operand2 < 32) ? ((data_fromRAM) >> (operand2)) : ((data_fromRAM) << ((operand2)-32));
				4'b0111: data_toRAM = data_fromRAM < operand2;
				4'b1001: data_toRAM = operand2; 
				4'b1111: data_toRAM = data_fromRAM * operand2;
			endcase
			stateNext = 0;
		end
		5: begin
			pCounterNext = pCounter;
			opcodeNext   = opcode;
			operand1Next = operand1;
			operand2Next = operand2;
			addr_toRAM   = operand2;
			num1Next     = data_fromRAM;
			num2Next     = 0;
			wrEn         = 0;
			data_toRAM   = 0;
			stateNext    = 6;
		end
		6: begin
			pCounterNext = pCounter; 
			opcodeNext   = opcode;
			operand1Next = operand1;
			operand2Next = operand2;
			num1Next     = num1;
			num2Next     = data_fromRAM;
			wrEn         = 0;
			data_toRAM   = 0;
			case(opcode)
				4'b1010: addr_toRAM = data_fromRAM;
				4'b1011: addr_toRAM = num1;
			endcase
			stateNext    = 7;
		end
		7: begin
			pCounterNext = pCounter + 1;
			operand1Next = operand1;
			operand2Next = operand2;
			opcodeNext   = opcode;
			wrEn         = 1;
			if(opcode == 4'b1010) begin
				num1Next     = num1;
				num2Next     = data_fromRAM;
				data_toRAM   = data_fromRAM;
				addr_toRAM   = operand1;
			end
			if(opcode == 4'b1011) begin
				num2Next     = num2;
				data_toRAM   = num2;
				addr_toRAM   = num1;
			end
			stateNext = 0;
		end
		default: begin
			stateNext    = 0;
			pCounterNext = 0;
			opcodeNext   = 0;
			operand1Next = 0;
			operand2Next = 0;
			num1Next     = 0;
			num2Next     = 0;
			addr_toRAM   = 0;
			wrEn         = 0;
			data_toRAM   = 0;
		end
	endcase
	
end

endmodule
