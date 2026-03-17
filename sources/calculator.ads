-- File: calculator.ads
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

package Calculator is
   
   -- Strong types for safety
   type User_ID is range 1..1000;
   type Operand is range -1000000..1000000;
   type Result is range -1000000..1000000;
   
   -- Enumerated type for operations (no magic chars)
   type Operation is (Plus, Minus, Multiply, Divide);
   
   -- Request structure
   type Request is record
      User     : User_ID;
      A, B     : Operand;
      Op       : Operation;
   end record;
   
   -- Exception for calculation errors
   Calculation_Error : exception;
   
   -- Public interface
   procedure Submit_Request(User : User_ID; 
                            A, B : Operand; 
                            Op : Operation);
   
   -- Start the calculation server
   procedure Start_Server;
   
   -- Stop the server
   procedure Stop_Server;
   
private
   -- Maximum queue size
   Queue_Max_Size : constant Integer := 100;
   
end Calculator;
