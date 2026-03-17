-- File: main.adb
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Calendar; use Ada.Calendar;
with Ada.Numerics.Discrete_Random;
with Calculator; use Calculator;

procedure Main is
   
   -- Random generator to simulate multiple users
   type Rand_User is range 1..5;
   type Rand_Operation is range 0..3;
   
   package Rand_User is new Ada.Numerics.Discrete_Random(Rand_User);
   package Rand_Op is new Ada.Numerics.Discrete_Random(Rand_Operation);
   
   Gen_User : Rand_User.Generator;
   Gen_Op : Rand_Op.Generator;
   
   -- Task simulating an active user
   task type User(ID : User_ID);
   
   task body User is
      A, B : Operand;
      Op_Code : Rand_Operation;
      Op_Enum : Operation;
   begin
      Put_Line("[User" & User_ID'Image(ID) & "] Started");
      
      for I in 1..3 loop
         A := Operand(Rand_User.Random(Gen_User) * 10);
         B := Operand(Rand_User.Random(Gen_User) * 10);
         Op_Code := Rand_Op.Random(Gen_Op);
         
         case Op_Code is
            when 0 => Op_Enum := Plus;
            when 1 => Op_Enum := Minus;
            when 2 => Op_Enum := Multiply;
            when 3 => Op_Enum := Divide;
         end case;
         
         -- Force a division by zero to test robustness
         if I = 2 and ID = 3 then
            B := 0;
            Op_Enum := Divide;
         end if;
         
         Submit_Request(ID, A, B, Op_Enum);
         delay Duration(Rand_User.Random(Gen_User)) / 10.0;
      end loop;
      
      Put_Line("[User" & User_ID'Image(ID) & "] Finished");
   end User;
   
   -- Declare users
   U1 : User(1);
   U2 : User(2);
   U3 : User(3);
   U4 : User(4);
   U5 : User(5);
   
begin
   Put_Line("==========================================");
   Put_Line("MULTI-USER ROBUST CALCULATOR");
   Put_Line("Demonstration of Ada's Protected Object Concept");
   Put_Line("==========================================");
   New_Line;
   
   Rand_User.Reset(Gen_User);
   Rand_Op.Reset(Gen_Op);
   
   Start_Server;
   delay 5.0;
   Stop_Server;
   
   New_Line;
   Put_Line("Program terminated.");
   
end Main;
