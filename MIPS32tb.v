`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/17/2025 09:46:15 AM
// Design Name: 
// Module Name: MIPS32tb
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
module MIPS32tb;
reg clk1, clk2;
integer k;
MIPS32 dut(clk1, clk2);
  
initial begin
  clk1 = 0;
  clk2 = 0;
  repeat(100) begin
    #5 clk1 = 1; #5 clk1 = 0;
    #5 clk2 = 1; #5 clk2 = 0;
  end
end
  
  initial 
    begin
      $dumpfile("dump.vcd");
      $dumpvars(0,MIPS32tb);
    end
  
  task reset_dut;
    begin
      dut.Halted = 0;
      dut.PC = 0;
      dut.taken_branch = 0;
      
      for (k = 0; k < 1024; k = k + 1) begin
        dut.memory[k] = 32'b0;
      end
      
      for (k = 0; k < 32; k = k + 1) begin
        dut.reg_bank[k] = 32'b0;
      end
    end
  endtask
  
  task add_program_load;
    begin
      for (k = 0; k < 31; k = k + 1) begin
        dut.reg_bank[k] = k;
      end
      dut.memory[0] = 32'h2801000a; // ADDI R1,R0,10
      dut.memory[1] = 32'h28020014; // ADDI R2,R0,20
      dut.memory[2] = 32'h28030019; // ADDI R3,R0,25
      dut.memory[3] = 32'h0ce77800; // NOP (OR R7,R7,R7)
      dut.memory[4] = 32'h0ce77800; // NOP
      dut.memory[5] = 32'h00222000; // ADD R4,R1,R2
      dut.memory[6] = 32'h0ce77800; // NOP
      dut.memory[7] = 32'h00832800; // ADD R5,R4,R3
      dut.memory[8] = 32'hfc000000; // HLT
    end
  endtask
  
  task load_store_program_load;
    begin
      
      for (k = 0; k < 31; k = k + 1) begin
        dut.reg_bank[k] = k;
      end
      dut.memory[0] = 32'h28010078; // ADDI R1, R0, 120
      dut.memory[1] = 32'h00000000; // NOP
      dut.memory[2] = 32'h20220000; // LW R2, 0(R1)
      dut.memory[3] = 32'h00000000; // NOP
      dut.memory[4] = 32'h2842002d; // ADDI R2, R2, 45
      dut.memory[5] = 32'h00000000; // NOP 
      dut.memory[6] = 32'h00000000; // NOP
      dut.memory[7] = 32'h24220001; // SW R2, 1(R1)
      dut.memory[8] = 32'hfc000000; // HLT
      dut.memory[120] = 85;
      dut.memory[121] = 0;
    end
  endtask
  
  task branch_program_load;
    begin
      for(k=0;k<31;k++) begin
        dut.reg_bank[k]=k;
      end
      dut.memory[0]=32'h280a00c8;//ADDI R10,R0,200d
      dut.memory[1]=32'h28020001;//ADDI R2.R0,1
      dut.memory[2]=32'h0e94a000;//OR R20,R20,R20
      dut.memory[3]=32'h21430000;//LW R3,0 (R10)
      dut.memory[4]=32'h0e94a000;//OR R20,R20,R20
      dut.memory[5]=32'h14431000;//LOOP:MUL R2,R2,R3
      dut.memory[6]=32'h2c630001;//UBI R3,R3,1
      dut.memory[7]=32'h0e94a000;//OR R20,R20,R20
      dut.memory[8]=32'h3860fffc;//BNEQZ R3,Loop(-4 offset)
      dut.memory[9]=32'h2542fffe;//SW R2,-2(R10)
      dut.memory[10]=32'hfc000000;//HLT
      dut.memory[200]=7;
    end
  endtask
  
  initial begin
    reset_dut; 
    add_program_load;
    @(posedge clk1); 
    wait(dut.Halted == 1);
    $display("--- Add Program Results ---");
    for (k = 0; k < 6; k = k + 1) 
      $display("R%1d = %2d", k, dut.reg_bank[k]);
    $display("---------------------------\n");
    
    reset_dut; 
    load_store_program_load; 
    @(posedge clk1); 
    wait(dut.Halted == 1);
    $display("--- Load/Store Program Results ---");
    $display("memory[120] = %4d", dut.memory[120]);
    $display("memory[121] = %4d", dut.memory[121]);
    $display("----------------------------------\n");
    
    reset_dut;
    branch_program_load;
    $display("---Branch program Results ---");
    $monitor("R2:%4d",dut.reg_bank[2]);
    @(posedge clk1);
    wait(dut.Halted==1);
    $display("memory[200]=%2d\n memory[198]=%6d",dut.memory[200],dut.memory[198]);
    $display("---------------------------\n");
    #1000 $finish;
  end
endmodule



