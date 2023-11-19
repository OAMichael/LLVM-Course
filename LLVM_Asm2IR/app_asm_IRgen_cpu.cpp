#include "../SDL/lib/sim.h"
#include <SDL2/SDL.h>
#include <assert.h>
#include <stdlib.h>
#include <time.h>

#define FRAME_TICKS 2

static SDL_Renderer *Renderer = NULL;
static SDL_Window *Window = NULL;
static Uint32 Ticks = 0;

void simInit() {
  SDL_Init(SDL_INIT_VIDEO);
  SDL_CreateWindowAndRenderer(SIM_X_SIZE, SIM_Y_SIZE, 0, &Window, &Renderer);
  SDL_SetRenderDrawColor(Renderer, 0, 0, 0, 0);
  SDL_RenderClear(Renderer);
}

void simExit() {
  SDL_Event event;
  while (1) {
    if (SDL_PollEvent(&event) && event.type == SDL_QUIT)
      break;
  }
  SDL_DestroyRenderer(Renderer);
  SDL_DestroyWindow(Window);
  SDL_Quit();
}

void simFlush() {
  SDL_PumpEvents();
  assert(SDL_TRUE != SDL_HasEvent(SDL_QUIT) && "User-requested quit");
  Uint32 cur_ticks = SDL_GetTicks() - Ticks;
  if (cur_ticks < FRAME_TICKS) {
    SDL_Delay(FRAME_TICKS - cur_ticks);
  }
  SDL_RenderPresent(Renderer);
}

void simPutPixel(int x, int y, int argb) {
  assert(0 <= x && x < SIM_X_SIZE && "Out of range");
  assert(0 <= y && y < SIM_Y_SIZE && "Out of range");
  Uint8 a = argb >> 24;
  Uint8 r = (argb >> 16) & 0xFF;
  Uint8 g = (argb >> 8) & 0xFF;
  Uint8 b = argb & 0xFF;
  SDL_SetRenderDrawColor(Renderer, r, g, b, a);
  SDL_RenderDrawPoint(Renderer, x, y);
  Ticks = SDL_GetTicks();
}

int simRand() {
  return rand();
}

#include "llvm/ExecutionEngine/ExecutionEngine.h"
#include "llvm/ExecutionEngine/GenericValue.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Verifier.h"
#include "llvm/Support/TargetSelect.h"
#include "llvm/Support/raw_ostream.h"
#include <fstream>
#include <iostream>
#include <unordered_map>
using namespace llvm;


//////////////////////////////
// All instructions
//////////////////////////////

enum InsnId_t {

// 0 arguments
	RET,
	PUT_PIXELS_14,
	FLUSH,

// 1 argument
	JMP,
	CALL,
	RAND,

// 2 arguments
	MV,
	MVI,
	ALLOCA,

// 3 arguments
	ADD,
	SUB,
	DIV,
	OR,

	ADDI,
	MULI,
	REMI,
	ANDI,
	SLI,

	LOAD,
	STORE,

	ICMPGE,
	ICMPNE,
	CONDBR,
};

//////////////////////////////
// Model for simulation
//////////////////////////////

using RegId_t = uint8_t;
using RegVal_t = uint64_t;
using Stack_t = std::stack<RegVal_t>;

const int REG_FILE_SIZE = 16;
class CPU {
public:
  RegVal_t REG_FILE[REG_FILE_SIZE] = {};
  RegVal_t PC;
  RegVal_t NEXT_PC;
	Stack_t  CALL_STACK;
  uint32_t RUN;

	inline bool call_stack_empty() {
		return CALL_STACK.empty();
	}
};

//////////////////////////////
// Universal Instruction
//////////////////////////////

class Instr {
public:
  InsnId_t m_ID;
  void (*m_INSTR)(CPU *, Instr *);
  RegId_t m_rs1;
  RegId_t m_rs2;
  RegId_t m_rs3;
  RegVal_t m_imm;
	RegVal_t m_imm2;
  std::string m_name;

	// Nothing
  Instr(InsnId_t ID, void (*do_INSTR)(CPU *, Instr *), std::string name)
      : m_ID(ID), m_INSTR(do_INSTR), m_name(name) {}

	// 1 register
  Instr(InsnId_t ID, void (*do_INSTR)(CPU *, Instr *), std::string name,
        RegId_t rs1)
      : m_ID(ID), m_INSTR(do_INSTR), m_name(name), m_rs1(rs1) {}
  
	// 2 registers
  Instr(InsnId_t ID, void (*do_INSTR)(CPU *, Instr *), std::string name,
        RegId_t rs1, RegId_t rs2)
      : m_ID(ID), m_INSTR(do_INSTR), m_name(name), m_rs1(rs1), m_rs2(rs2) {}

	// 3 registers
  Instr(InsnId_t ID, void (*do_INSTR)(CPU *, Instr *), std::string name,
        RegId_t rs1, RegId_t rs2, RegId_t rs3)
      : m_ID(ID), m_INSTR(do_INSTR), m_name(name), m_rs1(rs1), m_rs2(rs2),
        m_rs3(rs3) {}

	// Only immediate
	Instr(InsnId_t ID, void (*do_INSTR)(CPU *, Instr *), std::string name,
        RegVal_t imm)
      : m_ID(ID), m_INSTR(do_INSTR), m_name(name), m_imm(imm) {}

	// 1 register and immediate
  Instr(InsnId_t ID, void (*do_INSTR)(CPU *, Instr *), std::string name,
        RegId_t rs1, RegVal_t imm)
      : m_ID(ID), m_INSTR(do_INSTR), m_name(name), m_rs1(rs1), m_imm(imm) {}

	// 2 registers and immediate
  Instr(InsnId_t ID, void (*do_INSTR)(CPU *, Instr *), std::string name,
        RegId_t rs1, RegId_t rs2, RegVal_t imm)
      : m_ID(ID), m_INSTR(do_INSTR), m_name(name), m_rs1(rs1), m_rs2(rs2),
        m_imm(imm) {}

	// 1 register and 2 immediates (labels for basic blocks)
	Instr(InsnId_t ID, void (*do_INSTR)(CPU *, Instr *), std::string name,
        RegId_t rs1, RegVal_t imm, RegVal_t imm2)
      : m_ID(ID), m_INSTR(do_INSTR), m_name(name), m_rs1(rs1), m_imm(imm), m_imm2(imm2) {}


  void dump() { /* outs() << m_name << "\n"; */ }
};

//////////////////////////////
// Interpreter function
//////////////////////////////

void do_RET(CPU *cpu, Instr *instr) {
	instr->dump();
	if (cpu->call_stack_empty()) {
		cpu->RUN = 0;
		return;
	}
	cpu->NEXT_PC = cpu->CALL_STACK.top();
  cpu->CALL_STACK.pop();
}

void do_PUT_PIXELS_14(CPU *cpu, Instr *instr) {
	instr->dump();
	const int xStart = cpu->REG_FILE[0];
	const int y = cpu->REG_FILE[1];
	const int color = cpu->REG_FILE[2];
	for (int i = 0; i < 14; ++i) {
		simPutPixel(xStart + i, y, color);
	}
}

void do_FLUSH(CPU *cpu, Instr *instr) {
	instr->dump();
  simFlush();
}


void do_JMP(CPU *cpu, Instr *instr) {
	instr->dump();
	cpu->NEXT_PC = instr->m_imm;
}

void do_CALL(CPU *cpu, Instr *instr) {
	instr->dump();
  cpu->CALL_STACK.push(cpu->PC + 1);
  cpu->NEXT_PC = instr->m_imm;
}

void do_RAND(CPU *cpu, Instr *instr) {
	instr->dump();
  cpu->REG_FILE[instr->m_rs1] = simRand();
}


void do_MV(CPU *cpu, Instr *instr) {
	instr->dump();
  cpu->REG_FILE[instr->m_rs1] = cpu->REG_FILE[instr->m_rs2];
}

void do_MVI(CPU *cpu, Instr *instr) {
	instr->dump();
  cpu->REG_FILE[instr->m_rs1] = instr->m_imm;
}

void do_ALLOCA(CPU *cpu, Instr *instr) {
	instr->dump();
  cpu->REG_FILE[instr->m_rs1] = reinterpret_cast<RegVal_t>(new RegVal_t[instr->m_imm]);
}


void do_ADD(CPU *cpu, Instr *instr) {
	instr->dump();
	cpu->REG_FILE[instr->m_rs1] = cpu->REG_FILE[instr->m_rs2] + cpu->REG_FILE[instr->m_rs3];
}

void do_SUB(CPU *cpu, Instr *instr) {
	instr->dump();
	cpu->REG_FILE[instr->m_rs1] = cpu->REG_FILE[instr->m_rs2] - cpu->REG_FILE[instr->m_rs3];
}

void do_DIV(CPU *cpu, Instr *instr) {
	instr->dump();
	cpu->REG_FILE[instr->m_rs1] = cpu->REG_FILE[instr->m_rs2] / cpu->REG_FILE[instr->m_rs3];
}

void do_OR(CPU *cpu, Instr *instr) {
	instr->dump();
	cpu->REG_FILE[instr->m_rs1] = cpu->REG_FILE[instr->m_rs2] | cpu->REG_FILE[instr->m_rs3];
}

void do_ADDI(CPU *cpu, Instr *instr) {
	instr->dump();
  cpu->REG_FILE[instr->m_rs1] = cpu->REG_FILE[instr->m_rs2] + instr->m_imm;
}

void do_MULI(CPU *cpu, Instr *instr) {
	instr->dump();
  cpu->REG_FILE[instr->m_rs1] = cpu->REG_FILE[instr->m_rs2] * instr->m_imm;
}

void do_REMI(CPU *cpu, Instr *instr) {
	instr->dump();
	cpu->REG_FILE[instr->m_rs1] = cpu->REG_FILE[instr->m_rs2] % instr->m_imm;
}

void do_ANDI(CPU *cpu, Instr *instr) {
	instr->dump();
  cpu->REG_FILE[instr->m_rs1] = cpu->REG_FILE[instr->m_rs2] & instr->m_imm;
}

void do_SLI(CPU *cpu, Instr *instr) {
	instr->dump();
	cpu->REG_FILE[instr->m_rs1] = cpu->REG_FILE[instr->m_rs2] << instr->m_imm;
}

void do_LOAD(CPU *cpu, Instr *instr) {
	instr->dump();
	RegVal_t *ptr = reinterpret_cast<RegVal_t *>(cpu->REG_FILE[instr->m_rs2]);
	RegVal_t idx = cpu->REG_FILE[instr->m_rs3];
	cpu->REG_FILE[instr->m_rs1] = ptr[idx];
}

void do_STORE(CPU *cpu, Instr *instr) {
	instr->dump();
	RegVal_t *ptr = reinterpret_cast<RegVal_t *>(cpu->REG_FILE[instr->m_rs2]);
	RegVal_t idx = cpu->REG_FILE[instr->m_rs3];
	ptr[idx] = cpu->REG_FILE[instr->m_rs1];
}

void do_ICMPGE(CPU *cpu, Instr *instr) {
	instr->dump();
	cpu->REG_FILE[instr->m_rs1] = cpu->REG_FILE[instr->m_rs2] >= cpu->REG_FILE[instr->m_rs3];
}

void do_ICMPNE(CPU *cpu, Instr *instr) {
	instr->dump();
	cpu->REG_FILE[instr->m_rs1] = cpu->REG_FILE[instr->m_rs2] != cpu->REG_FILE[instr->m_rs3];
}

void do_CONDBR(CPU *cpu, Instr *instr) {
	instr->dump();
	if (cpu->REG_FILE[instr->m_rs1])
		cpu->NEXT_PC = instr->m_imm;
	else
		cpu->NEXT_PC = instr->m_imm2;
}



void *lazyFunctionCreator(const std::string &fnName) {
  if (fnName == "do_RET") {
    return reinterpret_cast<void *>(do_RET);
  }
	if (fnName == "do_PUT_PIXELS_14") {
    return reinterpret_cast<void *>(do_PUT_PIXELS_14);
  }
	if (fnName == "do_FLUSH") {
    return reinterpret_cast<void *>(do_FLUSH);
  }
	if (fnName == "do_JMP") {
    return reinterpret_cast<void *>(do_JMP);
  }
  if (fnName == "do_CALL") {
    return reinterpret_cast<void *>(do_CALL);
  }
	if (fnName == "do_RAND") {
    return reinterpret_cast<void *>(do_RAND);
  }	
  if (fnName == "do_MV") {
    return reinterpret_cast<void *>(do_MV);
  }
  if (fnName == "do_MVI") {
    return reinterpret_cast<void *>(do_MVI);
  }
	if (fnName == "do_ALLOCA") {
    return reinterpret_cast<void *>(do_ALLOCA);
  }	
  if (fnName == "do_ADD") {
    return reinterpret_cast<void *>(do_ADD);
  }
  if (fnName == "do_SUB") {
    return reinterpret_cast<void *>(do_SUB);
  }
  if (fnName == "do_DIV") {
    return reinterpret_cast<void *>(do_DIV);
  }		
  if (fnName == "do_OR") {
    return reinterpret_cast<void *>(do_OR);
  }
	if (fnName == "do_ADDI") {
    return reinterpret_cast<void *>(do_ADDI);
  }
	if (fnName == "do_MULI") {
    return reinterpret_cast<void *>(do_MULI);
  }
  if (fnName == "do_REMI") {
    return reinterpret_cast<void *>(do_REMI);
  }
  if (fnName == "do_ANDI") {
    return reinterpret_cast<void *>(do_ANDI);
  }	
  if (fnName == "do_SLI") {
    return reinterpret_cast<void *>(do_SLI);
  }
	if (fnName == "do_LOAD") {
    return reinterpret_cast<void *>(do_LOAD);
  }
	if (fnName == "do_STORE") {
    return reinterpret_cast<void *>(do_STORE);
  }
	if (fnName == "do_ICMPGE") {
    return reinterpret_cast<void *>(do_ICMPGE);
  }
	if (fnName == "do_ICMPNE") {
    return reinterpret_cast<void *>(do_ICMPNE);
  }
	if (fnName == "do_CONDBR") {
    return reinterpret_cast<void *>(do_CONDBR);
  }
  return nullptr;
}

//////////////////////////////
// MAIN
//////////////////////////////

int main(int argc, char *argv[]) {
  
	if (argc != 2) {
    outs() << "[ERROR] Need 1 argument: file with assembler\n";
    return 1;
  }
  std::ifstream input;
  input.open(argv[1]);
  if (!input.is_open()) {
    outs() << "[ERROR] Can't open " << argv[1] << "\n";
    return 1;
  }

	std::string name;
  std::string arg;
  std::unordered_map<std::string, RegVal_t> labels_pc;

  outs() << "\n#[FILE]:\nBasic blocks or functions:";
  RegVal_t pc = 1;
  while (input >> name) {
    // 0 args
    if (!name.compare("RET") || !name.compare("PUT_PIXELS_14") || !name.compare("FLUSH")) {
      pc++;
      continue;
    }

    // 1 arg
    if (!name.compare("JMP") || !name.compare("CALL") || !name.compare("RAND")) {
      input >> arg;
      pc++;
      continue;
    }

		// 2 args
    if (!name.compare("MV") || !name.compare("MVI") || !name.compare("ALLOCA")) {
      input >> arg >> arg;
      pc++;
      continue;
    }

    // 3 args
    if (!name.compare("ADD")    || !name.compare("SUB")   || !name.compare("DIV")    ||
				!name.compare("OR")     || !name.compare("ADDI")  || !name.compare("MULI")   ||
				!name.compare("REMI")   || !name.compare("ANDI")  || !name.compare("SLI")    ||
				!name.compare("LOAD")   || !name.compare("STORE") || !name.compare("ICMPGE") ||
				!name.compare("ICMPNE") || !name.compare("CONDBR")) {
      input >> arg >> arg >> arg;
      pc++;
      continue;
    }

    outs() << " " << name << "(" << pc << ")";
    labels_pc[name] = pc;
  }
  outs() << "\n";
  input.close();
  input.open(argv[1]);

  std::string arg1;
  std::string arg2;
  std::string arg3;
  std::vector<Instr *> Instructions;
  Instructions.push_back(
      new Instr(InsnId_t::RET, do_RET, "[RUNTIME ERROR] Segmentation fault"));

  // Read instruction from file
  outs() << "#[FILE] BEGIN\n";
  while (input >> name) {
    outs() << name;

    // Nothing
    if (!name.compare("RET") || !name.compare("PUT_PIXELS_14") || !name.compare("FLUSH")) {
			if (!name.compare("RET")) {
				Instructions.push_back(new Instr(InsnId_t::RET, do_RET, name));
				outs() << "\n";
				continue;
			}
			if (!name.compare("PUT_PIXELS_14")) {
				Instructions.push_back(new Instr(InsnId_t::PUT_PIXELS_14, do_PUT_PIXELS_14, name));
				outs() << "\n";
				continue;
			}
			if (!name.compare("FLUSH")) {
				Instructions.push_back(new Instr(InsnId_t::FLUSH, do_FLUSH, name));
				outs() << "\n";
				continue;
			}
		}

    // 1 register
    if (!name.compare("RAND")) {
      input >> arg1;
      outs() << " " << arg1 << "\n";
      RegId_t rs1 = stoi(arg1.substr(1));
      if (!name.compare("RAND")) {
        Instructions.push_back(new Instr(InsnId_t::RAND, do_RAND, name, rs1));
      }
      continue;
    }

    // 2 registers
    if (!name.compare("MV")) {
      input >> arg1 >> arg2;
      outs() << " " << arg1 << " " << arg2 << "\n";
      RegId_t rs1 = stoi(arg1.substr(1));
      RegId_t rs2 = stoi(arg2.substr(1));
      if (!name.compare("MV")) {
        Instructions.push_back(new Instr(InsnId_t::MV, do_MV, name, rs1, rs2));
      }
      continue;
    }

    // 3 registers
    if (!name.compare("ADD")    || !name.compare("SUB")  || !name.compare("DIV")   ||
				!name.compare("OR")     || !name.compare("LOAD") || !name.compare("STORE") ||
				!name.compare("ICMPGE") || !name.compare("ICMPNE")) {
      input >> arg1 >> arg2 >> arg3;
      outs() << " " << arg1 << " " << arg2 << " " << arg3 << "\n";
      RegId_t rs1 = stoi(arg1.substr(1));
      RegId_t rs2 = stoi(arg2.substr(1));
      RegId_t rs3 = stoi(arg3.substr(1));
      if (!name.compare("ADD")) {
        Instructions.push_back(new Instr(InsnId_t::ADD, do_ADD, name, rs1, rs2, rs3));
      }
      if (!name.compare("SUB")) {
        Instructions.push_back(new Instr(InsnId_t::SUB, do_SUB, name, rs1, rs2, rs3));
      }
      if (!name.compare("DIV")) {
        Instructions.push_back(new Instr(InsnId_t::DIV, do_DIV, name, rs1, rs2, rs3));
      }
      if (!name.compare("OR")) {
        Instructions.push_back(new Instr(InsnId_t::OR, do_OR, name, rs1, rs2, rs3));
      }
      if (!name.compare("LOAD")) {
        Instructions.push_back(new Instr(InsnId_t::LOAD, do_LOAD, name, rs1, rs2, rs3));
      }
      if (!name.compare("STORE")) {
        Instructions.push_back(new Instr(InsnId_t::STORE, do_STORE, name, rs1, rs2, rs3));
      }
      if (!name.compare("ICMPGE")) {
        Instructions.push_back(new Instr(InsnId_t::ICMPGE, do_ICMPGE, name, rs1, rs2, rs3));
      }
      if (!name.compare("ICMPNE")) {
        Instructions.push_back(new Instr(InsnId_t::ICMPNE, do_ICMPNE, name, rs1, rs2, rs3));
      }
      continue;
    }

    // Only imm
    if (!name.compare("JMP") || !name.compare("CALL")) {
      input >> arg1;
      outs() << " " << arg1 << "\n";
			if (!name.compare("JMP")) {
	      RegVal_t imm = labels_pc[arg1];
				Instructions.push_back(new Instr(InsnId_t::JMP, do_JMP, name, imm));
				outs() << "\n";
				continue;
	    }
			if (!name.compare("CALL")) {
	      RegVal_t imm = labels_pc[arg1];
				Instructions.push_back(new Instr(InsnId_t::CALL, do_CALL, name, imm));
				outs() << "\n";
				continue;
	    }
			continue;
    }

		// 1 register and imm
    if (!name.compare("MVI") || !name.compare("ALLOCA")) {
      input >> arg1 >> arg2;
      outs() << " " << arg1 << " " << arg2 << "\n";
      RegId_t rs1 = stoi(arg1.substr(1));
			if (!name.compare("MVI")) {
	      RegVal_t imm = stoi(arg2);
				Instructions.push_back(new Instr(InsnId_t::MVI, do_MVI, name, rs1, imm));
				outs() << "\n";
				continue;
	    }
			if (!name.compare("ALLOCA")) {
	      RegVal_t imm = stoi(arg2);
				Instructions.push_back(new Instr(InsnId_t::ALLOCA, do_ALLOCA, name, rs1, imm));
				outs() << "\n";
				continue;
	    }
	    continue;
    }

    // 2 registers and imm
    if (!name.compare("ADDI") || !name.compare("MULI")  || !name.compare("REMI") || 
				!name.compare("ANDI") || !name.compare("SLI")) {
      input >> arg1 >> arg2 >> arg3;
      outs() << " " << arg1 << " " << arg2 << " " << arg3 << "\n";
      RegId_t rs1 = stoi(arg1.substr(1));
      RegId_t rs2 = stoi(arg2.substr(1));
  		if (!name.compare("ADDI")) {
	      RegVal_t imm = stoi(arg3);
				Instructions.push_back(new Instr(InsnId_t::ADDI, do_ADDI, name, rs1, rs2, imm));
				outs() << "\n";
				continue;
	    }
  		if (!name.compare("MULI")) {
	      RegVal_t imm = stoi(arg3);
				Instructions.push_back(new Instr(InsnId_t::MULI, do_MULI, name, rs1, rs2, imm));
				outs() << "\n";
				continue;
	    }
  		if (!name.compare("REMI")) {
	      RegVal_t imm = stoi(arg3);
				Instructions.push_back(new Instr(InsnId_t::REMI, do_REMI, name, rs1, rs2, imm));
				outs() << "\n";
				continue;
	    }
      if (!name.compare("ANDI")) {
	      RegVal_t imm = stoi(arg3);
        Instructions.push_back(new Instr(InsnId_t::ANDI, do_ANDI, name, rs1, rs2, imm));
      }
      if (!name.compare("SLI")) {
	      RegVal_t imm = stoi(arg3);
        Instructions.push_back(new Instr(InsnId_t::SLI, do_SLI, name, rs1, rs2, imm));
      }
      continue;
    }

		// 1 register and 2 imm
    if (!name.compare("CONDBR")) {
      input >> arg1 >> arg2 >> arg3;
      outs() << " " << arg1 << " " << arg2 << " " << arg3 << "\n";
      RegId_t rs1 = stoi(arg1.substr(1));
			if (!name.compare("CONDBR")) {
	      RegVal_t imm = labels_pc[arg2];
	      RegVal_t imm2 = labels_pc[arg3];
				Instructions.push_back(new Instr(InsnId_t::CONDBR, do_CONDBR, name, rs1, imm, imm2));
				outs() << "\n";
				continue;
	    }
	    continue;
    }

    if (labels_pc.find(name) == labels_pc.end()) {
      outs() << "\n[ERROR] Unknown instruction: " << name << "\n";
      Instructions.clear();
      return 1;
    }
    outs() << "\n";
  }
  outs() << "#[FILE] END\n";

  // App simulation
  outs() << "\n#[EXEC] BEGIN\n";

	simInit();

  CPU cpu;
  for (int i = 0; i < REG_FILE_SIZE; i++) {
    cpu.REG_FILE[i] = 0;
  }
  cpu.RUN = 1;
  cpu.PC = 1;
	
  // Loop execution
  while (cpu.RUN) {
    cpu.NEXT_PC = cpu.PC + 1;
    Instructions[cpu.PC]->m_INSTR(&cpu, Instructions[cpu.PC]);
    cpu.PC = cpu.NEXT_PC;
  }

	simExit();

  outs() << "#[EXEC] END\n";

	Instructions.clear();
  return 0;
}
