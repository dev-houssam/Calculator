-- File: calculator.adb
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Exceptions; use Ada.Exceptions;

package body Calculator is
   
   -- ===========================================================
   -- 1. PROTECTED OBJECT: THE CALCULATOR ITSELF
   -- ===========================================================
   -- This is the heart of the article: a protected object
   -- automatically handles concurrency without manual mutex
   protected type Protected_Calculator is
      entry Calculate(Req : Request; Res : out Result);
   private
      Busy : Boolean := False;
   end Protected_Calculator;
   
   protected body Protected_Calculator is
      
      entry Calculate(Req : Request; Res : out Result) 
        when True is
      begin
         Busy := True;
         
         case Req.Op is
            when Plus =>
               Res := Result(Req.A + Req.B);
               
            when Minus =>
               Res := Result(Req.A - Req.B);
               
            when Multiply =>
               Res := Result(Req.A * Req.B);
               
            when Divide =>
               if Req.B = 0 then
                  raise Calculation_Error with "Division by zero by user " & 
                     User_ID'Image(Req.User);
               else
                  Res := Result(Req.A / Req.B);
               end if;
         end case;
         
         Busy := False;
         
      exception
         when Calculation_Error =>
            Busy := False;
            raise;
         when others =>
            Busy := False;
            raise;
      end Calculate;
      
   end Protected_Calculator;
   
   -- Single instance of the protected calculator
   Critical_Calculator : Protected_Calculator;
   
   -- ===========================================================
   -- 2. USER MANAGEMENT AND REQUEST QUEUE
   -- ===========================================================
   
   protected type Request_Queue is
      entry Add(R : Request);
      entry Remove(R : out Request);
      function Is_Empty return Boolean;
      function Length return Natural;
   private
      type Queue_Index is mod Queue_Max_Size;
      Table : array (Queue_Index) of Request;
      Head, Tail : Queue_Index := Queue_Index'First;
      Count : Natural := 0;
   end Request_Queue;
   
   protected body Request_Queue is
      
      entry Add(R : Request) when Count < Queue_Max_Size is
      begin
         Table(Tail) := R;
         Tail := Tail + 1;
         Count := Count + 1;
      end Add;
      
      entry Remove(R : out Request) when Count > 0 is
      begin
         R := Table(Head);
         Head := Head + 1;
         Count := Count - 1;
      end Remove;
      
      function Is_Empty return Boolean is (Count = 0);
      
      function Length return Natural is (Count);
      
   end Request_Queue;
   
   -- Queue instance
   Request_Queue_Instance : Request_Queue;
   
   -- ===========================================================
   -- 3. SERVER TASK: PROCESSES REQUESTS IN BACKGROUND
   -- ===========================================================
   task type Calculation_Server is
      entry Start;
      entry Stop;
   end Calculation_Server;
   
   task body Calculation_Server is
      Running : Boolean := False;
      Current_Request : Request;
      Current_Result : Result;
   begin
      accept Start do
         Running := True;
         Put_Line("[Server] Started");
      end Start;
      
      while Running loop
         select
            accept Stop do
               Running := False;
               Put_Line("[Server] Stop requested");
            end Stop;
         else
            null;
         end select;
         
         if not Request_Queue_Instance.Is_Empty then
            Request_Queue_Instance.Remove(Current_Request);
            
            Put_Line("[Server] Processing request from user " & 
                     User_ID'Image(Current_Request.User));
            
            -- HIGHLIGHT: Call to protected object
            -- Protection is AUTOMATIC, no manual lock/unlock
            begin
               Critical_Calculator.Calculate(Current_Request, Current_Result);
               
               Put_Line("[Server] User " & 
                        User_ID'Image(Current_Request.User) & 
                        " : " & 
                        Operand'Image(Current_Request.A) & 
                        Operation'Image(Current_Request.Op) & 
                        Operand'Image(Current_Request.B) & 
                        " = " & 
                        Result'Image(Current_Result));
                        
            exception
               when Calculation_Error =>
                  Put_Line("[Server] ERROR: " & Exception_Message(Calculation_Error));
               when others =>
                  Put_Line("[Server] Unknown error");
            end;
         end if;
         
         delay 0.1;
      end loop;
      
   exception
      when others =>
         Put_Line("[Server] Server crashed!");
   end Calculation_Server;
   
   -- Server instance
   Server : Calculation_Server;
   
   -- ===========================================================
   -- 4. PUBLIC INTERFACE
   -- ===========================================================
   
   procedure Submit_Request(User : User_ID; 
                            A, B : Operand; 
                            Op : Operation) is
      Req : Request;
   begin
      Req := (User => User, A => A, B => B, Op => Op);
      Request_Queue_Instance.Add(Req);
      Put_Line("[Client] User " & User_ID'Image(User) & 
               " : request submitted");
   end Submit_Request;
   
   procedure Start_Server is
   begin
      Server.Start;
   end Start_Server;
   
   procedure Stop_Server is
   begin
      Server.Stop;
   end Stop_Server;
   
end Calculator;
