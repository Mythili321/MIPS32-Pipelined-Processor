`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/16/2025 05:06:27 PM
// Design Name: 
// Module Name: MIPS32
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module MIPS32(
    input clk1,
    input clk2
    
    );
    
    reg [31:0] PC,IF_ID_IR,IF_ID_NPC;
  reg [31:0] ID_EXE_IR,ID_EXE_A,ID_EXE_B,ID_EXE_IMM,ID_EXE_NPC;
    reg [31:0] EXE_MEM_ALUOUT, EXE_MEM_IR,EXE_MEM_B,EXE_MEM_COND;
    reg [31:0] MEM_WB_IR,MEM_WB_ALUOUT,MEM_WB_LMD;
    reg [2:0] ID_EXE_type,EXE_MEM_type,MEM_WB_type;
    reg Halted;
    reg taken_branch;
    reg[31:0] reg_bank [0:31];
    reg[31:0] memory [0:1023];
    parameter ADD=6'b000000,SUB=6'b000001,AND=6'b000010,OR=6'b000011,SLT=6'b000100,MUL=6'b000101,HLT=6'b111111,LW=6'b001000,SW=6'b001001,ADDI=6'b001010,SUBI=6'b001011,SLTI=6'b001100,BEQZ=6'b001101,BNEQZ=6'b001110;
    parameter RR_ALU=3'b000,RM_ALU=3'b001,LOAD=3'b010,STORE=3'b011,BRANCH=3'b100,HALT=3'b101;
  always @ (posedge clk1)
    if (Halted==0) begin
    if(((EXE_MEM_IR[31:26]==BEQZ) &&(EXE_MEM_COND==1))||((EXE_MEM_IR[31:26]==BNEQZ) &&(EXE_MEM_COND==0)))
      begin
        IF_ID_IR<=#2 memory[EXE_MEM_ALUOUT];
        taken_branch<=#2 1;
        IF_ID_NPC<=#2 EXE_MEM_ALUOUT+1;
        PC<=#2 EXE_MEM_ALUOUT+1;
      end
      else begin
        IF_ID_IR<=#2 memory[PC];
        IF_ID_NPC<=#2 PC+1;
        PC<=#2 PC+1;
      end
    end
  always @ (posedge clk2)
    if(Halted==0) begin
      if(IF_ID_IR[25:21]==5'b00000)
        ID_EXE_A<=0;
      else
        ID_EXE_A<=#2 reg_bank[IF_ID_IR[25:21]];
      if (IF_ID_IR[20:16]==5'b00000)
        ID_EXE_B<=0;
      else
        ID_EXE_B<=#2 reg_bank[IF_ID_IR[20:16]];
      ID_EXE_NPC<=#2 IF_ID_NPC;
      ID_EXE_IR<=#2 IF_ID_IR;
      ID_EXE_IMM<=#2 {{16{IF_ID_IR[15]}},{IF_ID_IR[15:0]}};
      case(IF_ID_IR[31:26])
        ADD,SUB,AND,OR,MUL,SLT:ID_EXE_type<=#2 RR_ALU;
        ADDI,SUBI,SLTI:ID_EXE_type<=#2 RM_ALU;
        BEQZ,BNEQZ:ID_EXE_type<=#2 BRANCH;
        LW:ID_EXE_type<=#2 LOAD;
        SW:ID_EXE_type<=#2 STORE;
        HLT:ID_EXE_type<=#2 HALT;
        default: ID_EXE_type<=#2 HALT;
        endcase
    end
  always @(posedge clk1)
    if(Halted==0) begin
      EXE_MEM_IR<=#2 ID_EXE_IR;
      EXE_MEM_type<=#2ID_EXE_type;
      taken_branch<=#2 0;
      case(ID_EXE_type)
        RR_ALU:begin
          case(ID_EXE_IR[31:26])
            ADD: EXE_MEM_ALUOUT<=#2 ID_EXE_A+ID_EXE_B;
            SUB: EXE_MEM_ALUOUT<=#2 ID_EXE_A-ID_EXE_B;
            AND: EXE_MEM_ALUOUT<=#2 ID_EXE_A&ID_EXE_B;
            OR: EXE_MEM_ALUOUT<=#2 ID_EXE_A|ID_EXE_B;
            SLT: EXE_MEM_ALUOUT<=#2 ID_EXE_A<ID_EXE_B;
            MUL: EXE_MEM_ALUOUT<=#2 ID_EXE_A*ID_EXE_B;
            default: EXE_MEM_ALUOUT<=#2 32'hxxxxxxxx;
          endcase
        end
        RM_ALU: begin
          case(ID_EXE_IR[31:26])
            ADDI:EXE_MEM_ALUOUT<=#2 ID_EXE_A+ID_EXE_IMM;
            SUBI: EXE_MEM_ALUOUT<=#2 ID_EXE_A-ID_EXE_IMM;
            SLT: EXE_MEM_ALUOUT<=#2 ID_EXE_A<ID_EXE_IMM;
            default: EXE_MEM_ALUOUT<=#2 32'hxxxxxxxx;
          endcase
        end
        LOAD,STORE:begin
        EXE_MEM_ALUOUT<=#2 ID_EXE_A+ID_EXE_IMM;
        EXE_MEM_B<=#2 ID_EXE_B;
        end 
        BRANCH: begin
          EXE_MEM_ALUOUT<=#2 ID_EXE_NPC+ID_EXE_IMM;
          EXE_MEM_COND<=#2 (ID_EXE_A==0);
        end
      endcase
    end
  always @ (posedge clk2)
    if(Halted==0)  begin
      MEM_WB_type<=#2 EXE_MEM_type;
      MEM_WB_IR<=#2 EXE_MEM_IR;
      case(EXE_MEM_type)
        RR_ALU,RM_ALU:
          MEM_WB_ALUOUT<=#2 EXE_MEM_ALUOUT;
        LOAD: MEM_WB_LMD<=#2 memory[EXE_MEM_ALUOUT];
        STORE: if(taken_branch==0)
          memory[EXE_MEM_ALUOUT]<=#2 EXE_MEM_B;
      endcase
    end
  always@(posedge clk1)
    begin
      if(taken_branch==0)
        case(MEM_WB_type)
          RR_ALU:reg_bank[MEM_WB_IR[15:11]]<=#2 MEM_WB_ALUOUT;
          RM_ALU:reg_bank[MEM_WB_IR[20:16]]<=#2 MEM_WB_ALUOUT;
          LOAD:reg_bank[MEM_WB_IR[20:16]]<=#2 MEM_WB_LMD;
          HALT: Halted<=#2 1'b1;
        endcase
    end
   
 endmodule
   

