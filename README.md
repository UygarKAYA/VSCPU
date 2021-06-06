# _VSCPU_

***32 bit Instruction Word (IW) of SimpleCPU:***

![set](https://user-images.githubusercontent.com/73105132/120936180-2b4f8280-c70f-11eb-90f0-7ad6eb81926d.png)

***i=1 implies B is Immediate (meaning a number) as opposed to a Pointer (meaning Address)***

***Instruction Set of SimpleCPU:***

*ADD   -> unsigned Add* <br/>
         &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;*{opcode, i} = {0, 0}* <br/>
         &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;_*A <- (*A) + (*B)_ <br/>
         &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;*write (readFromAddress(A) + readAddress(B)) to address (A)* <br/>
         &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;_*A = value (content of) address A = mem[A] (mem means memory)_ <br/>
         &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;_*B = value (content of) address B = mem[B]_ <br/>
         &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;*<- means write (assign)* <br/>
         &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;*mem[A] = mem[A] + mem[B]* <br/>
         &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;*mem[IW[27:14]] = mem[IW[27:14]] + mem[IW[13:0]]* <br/>

*ADDi  -> unsigned Add immediate* <br/>
         &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; *{opcode, i} = {0, 1}* <br/>
         &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; _*A <- (*A) + B_ <br/>
         &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; *B = read section B of the Instruction* <br/>
         &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; *mem[A] = mem[A] + B* <br/>
         &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; *mem[IW[27:14]] = mem[IW[27:14]] + IW[13:0]* <br/>

*NAND  -> bitwise NAND <br/>*
         &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; *{opcode, i} = {1, 0}* <br/>
         &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; _*A <- ~((*A) & (*B))_ <br/>
         &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; *{opcode, i} = {0, 1}* <br/>

*NANDi -> bitwise NAND immediate* <br/>
         &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;*{opcode, i} = {1, 1}* <br/>
         &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;_*A <- ~((*A) & B)_ <br/>

_SRL   -> Shift Right if the shift amount (*B) is less than 32, otherwise Shift Left_ <br/>
         &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; *{opcode, i} = {2, 0}* <br/>
         &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; _*A <- ((*B) < 32) ? ((*A) >> (*B)) : ((*A) << ((*B) - 32))_ <br/>

*SRLi  -> Shift Right if the shift amount (B) is less than 32, otherwise Shift Left* <br/>
         &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; *{opcode, i} = {2, 0}* <br/>
         &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; _*A <- (B < 32) ? ((*A) >> B) : ((*A) << (B - 32))_ <br/>

_LT    -> if *A is Less Than *B then *A is set to 1, otherwise to 0_ <br/>
         &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; *{opcode, i} = {3, 0}* <br/>
         &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; _*A <- ((*A) < (*B))_ <br/>
         
_LTi   -> if *A is Less Than B then *A is set to 1, otherwise to 0_ <br/>
         &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; *{opcode, i} = {3, 1}* <br/>
         &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; _*A <- ((*A) < B)_ <br/>

_CP    -> Copy *B to *A_ <br/>
         &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; *{opcode, i} = {4, 0}* <br/>
         &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; _*A <- *B_ <br/>

_CPi   -> Copy B to *A_ <br/>
         &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;*{opcode, i} = {4, 1}* <br/>
         &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;_*A <- B_ <br/>

_CPI   -> (regular) Copy Indirect: Copy **B to *A_ <br/>
         &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;*(go to address B and fetch the number then treat it as an address and go to that address and get that data and write to address A)* <br/>
         &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;*{opcode, i} = {5, 0}* <br/>
         &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;_*A <- *(*B)_ <br/>
         &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;*write (readFromAddress(readFromAddress(B))) to address (A)* <br/>

_CPIi  -> (immediate) Copy Indirect: Copy *B to **A_ <br/>
         &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;_(go to address B and fetch the number (*B) then go to address A and fetch the number there and treat it as an address and write there *B)_ <br/>
         &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;*{opcode, i} = {5, 1}* <br/>
         &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;_*(*A) <- *B_ <br/>
         &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;*write (readFromAddress(B)) to address (readFromAddress(A))* <br/>

*BZJ   -> Branch on Zero* <br/>
         &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;_(Branch to *A if *B is Zero, otherwise increment Program Counter (PC))_ <br/>
         &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;*{opcode, i} = {6, 0}* <br/>
         &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;_PC <- (*B == 0) ? (*A) : (PC+1)_ <br/>
         &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;_if(*B == 0) goTo(*A), else goTo(nextInstruction)_ <br/>

*BZJi  -> Jump (unconditional branch)* <br/>
         &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; *{opcode, i} = {6, 1}* <br/>
         &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; _PC <- (*A) + B_ <br/>

*MUL   -> unsigned Multiply* <br/>
         &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;*{opcode, i} = {7, 0}* <br/>
         &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;_*A <- (*A) * (*B)_ <br/>
         
*MULi  -> unsigned Multiply* <br/>
         &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; *{opcode, i} = {7, 1}* <br/>
         &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; _*A <- (*A) * B_ <br/>
