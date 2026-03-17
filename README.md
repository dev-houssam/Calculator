# Calculator : A Simple Multi-User Calculator

## Anatomy of Robust Software — A Comparative Study

This repository contains a complete Ada implementation of a **multi-user calculator** used as a case study in the article *"Anatomy of Robust Software: What Your Multi-User Calculator Reveals About Ada, C/C++, Rust, and Arduino"*.

### 📋 Overview

The project demonstrates a critical resource (calculator) shared between multiple concurrent users, showcasing:

- **Protected objects** for automatic synchronization
- **Strong typing** for safety
- **Exception handling** for robust error management
- **Tasking** for natural concurrency
- **Request queue** for fair user handling

###  Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│    Users        │    │  Request Queue   │    │    Server       │
│  (Tasks 1..5)   │───▶│   (Protected)    │───▶│    (Task)       │
└─────────────────┘    └──────────────────┘    └────────┬────────┘
                                                         │
                                                         ▼
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│    Results      │◀───│    Calculator    │◀───│   Protected     │
│   (Console)     │    │   (Critical)     │    │    Object       │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

###  Getting Started

#### Prerequisites
- GNAT Ada compiler (GPL or FSF version)
- Make (optional)

#### Compilation

```bash
# Using gnatmake directly
gnatmake -o calculator main.adb calculator.adb

# Or using the project file
gnatmake -Pcalculator.gpr
```

#### Running

```bash
./calculator
```

### 📁 Files

| File | Description |
|------|-------------|
| `main.adb` | Main program with 5 concurrent user tasks |
| `calculator.ads` | Package specification (public interface) |
| `calculator.adb` | Package body (implementation) |
| `calculator.gpr` | GNAT project file |

###  Example Output

```
==========================================
MULTI-USER ROBUST CALCULATOR
Demonstration of Ada's Protected Object Concept
==========================================

[User 1] Started
[User 2] Started
[User 3] Started
[User 4] Started
[User 5] Started
[Server] Started
[Client] User 1 : request submitted
[Client] User 2 : request submitted
[Server] Processing request from user 1
[Server] User 1 : 5 + 3 = 8
[Server] Processing request from user 2
[Server] User 2 : 7 * 2 = 14
[Client] User 3 : request submitted
[Server] Processing request from user 3
[Server] ERROR: Division by zero by user 3
[User 1] Finished
[User 2] Finished
...
```

###  Key Concepts Demonstrated

#### 1. **Protected Objects**
```ada
protected type Protected_Calculator is
   entry Calculate(Req : Request; Res : out Result);
private
   Busy : Boolean := False;
end Protected_Calculator;
```
Automatic mutual exclusion — no manual lock/unlock.

#### 2. **Strong Typing**
```ada
type User_ID is range 1..1000;
type Operand is range -1000000..1000000;
```
Type safety by construction — impossible to mix incompatible values.

#### 3. **Exception Handling**
```ada
if Req.B = 0 then
   raise Calculation_Error with "Division by zero";
end if;
```
Clean error isolation — one user's error doesn't crash the system.

#### 4. **Concurrent Tasks**
```ada
task type User(ID : User_ID);
task type Calculation_Server;
```
Native language support for concurrency — no external libraries.

###  Comparison With Other Languages

This implementation is part of a broader analysis comparing:

| Language | Safety Level | Concurrency | Memory Management |
|----------|--------------|-------------|-------------------|
| **Ada** | Maximum | Built-in (protected objects) | Built-in |
| **Rust** | High | Mutex + Ownership | Ownership |
| **C++** | Medium | Mutex + RAII | Manual/RAII |
| **C** | Low | Manual mutex | Manual |
| **Arduino** | Minimal | None | Static |

###  Learning Objectives

By studying this code, you'll understand:

- Why **atomic operations** matter in concurrent systems
- How **protected objects** eliminate race conditions
- The difference between **manual locking** and **language-enforced safety**
- How **strong typing** prevents entire classes of bugs
- Why **Ada** is used in critical systems (aviation, railways, nuclear)

###  Contributing

Feel free to:
- Open issues for questions or suggestions
- Submit PRs for improvements
- Port the example to other languages (Rust, C++, etc.)
- Add more test cases or features

### 📖 Related Article

This code accompanies the Medium article:  
**[Anatomy of Robust Software: What Your Multi-User Calculator Reveals About Ada, C/C++, Rust, and Arduino]**

###  License

MIT License — use freely, learn deeply, build safely.


