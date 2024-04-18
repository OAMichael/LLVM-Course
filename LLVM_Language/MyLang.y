%{
#include <iostream>
#include <stack>
#include "llvm/Support/raw_ostream.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/ExecutionEngine/ExecutionEngine.h"
#include "llvm/ExecutionEngine/GenericValue.h"
#include "llvm/Support/TargetSelect.h"
using namespace llvm;

#define YYSTYPE Value*
extern "C" {
    int yyparse();
    int yylex();
    void yyerror(char *s) {
        std::cerr << s << "\n";
    }
    int yywrap(void){ return 1; }
}

#include <SDL2/SDL.h>
#include <assert.h>
#include <stdlib.h>
#include <time.h>
#define SIM_X_SIZE 800
#define SIM_Y_SIZE 800
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




LLVMContext context;
IRBuilder<> *builder;
Module *module;

FunctionCallee simFlushFunc;
FunctionCallee simPutPixelFunc;
FunctionCallee simRandFunc;

Function *currFunc = nullptr;
std::map<std::string, BasicBlock *> currFuncBBMap;
std::vector<Type *> currFuncArgsTypes;
std::vector<std::pair<std::string, Value *>> currFuncArgsValues;
bool isScopeFunction = false;

std::vector<Value *> currFuncCalleeArgs;

std::stack<int> ifTrueBBNums;
std::stack<int> ifFalseBBNums;
std::stack<int> afterIfBBNums;

std::stack<int> forLoopInBBNums;
std::stack<int> forLoopBodyBBNums;
std::stack<int> forLoopOutBBNums;
std::stack<int> forLoopExitBBNums;

std::stack<int> whileLoopInBBNums;
std::stack<int> whileLoopBodyBBNums;
std::stack<int> whileLoopExitBBNums;

struct ArrayValue {
    Value *val;
    int size;
};

struct StatementScope {
    std::map<std::string, Value *> ValueMap;
    std::map<std::string, ArrayValue> ArrayMap;
    StatementScope *parentScope = nullptr;

    void insertValue(const std::string &name, Value *value) {
        ValueMap[name] = value;
    }

    void insertArrayValue(const std::string &name, const ArrayValue arrayValue) {
        ArrayMap[name] = arrayValue;
    }

    Value *findValue(const std::string &name) {
        auto it = ValueMap.find(name);
        if (it != ValueMap.end()) {
            return it->second;
        }
        if (parentScope) {
            return parentScope->findValue(name);
        }
        return nullptr;
    }

    ArrayValue findArrayValue(const std::string &name) {
        auto it = ArrayMap.find(name);
        if (it != ArrayMap.end()) {
            return it->second;
        }
        if (parentScope) {
            return parentScope->findArrayValue(name);
        }
        return {nullptr, 0};
    }
};

StatementScope *currentScope = nullptr;

std::map<std::string, Value *> globalValueMap;
std::map<std::string, ArrayValue> globalArrayMap;

int main(int argc, char **argv)
{
    bool runSimulation = false;

    InitializeNativeTarget();
    InitializeNativeTargetAsmPrinter();

    // ; ModuleID = 'top'
    // source_filename = "top"
    module = new Module("top", context);
    builder = new IRBuilder<> (context);

    Type *voidType = Type::getVoidTy(context);
    // declare void @simPutPixel(i32 noundef, i32 noundef, i32 noundef)
    ArrayRef<Type *> simPutPixelParamTypes = {Type::getInt32Ty(context),
                                                Type::getInt32Ty(context),
                                                Type::getInt32Ty(context)};

    FunctionType *simPutPixelType = FunctionType::get(voidType, simPutPixelParamTypes, false);
    simPutPixelFunc = module->getOrInsertFunction("llvm.riscx.putpixel", simPutPixelType);

    // declare void @simFlush(...)
    FunctionType *simFlushType = FunctionType::get(voidType, {}, false);
    simFlushFunc = module->getOrInsertFunction("llvm.riscx.flush", simFlushType);

    // declare i32 @simRand(...)
    FunctionType *simRandType = FunctionType::get(Type::getInt32Ty(context), {}, false);
    simRandFunc = module->getOrInsertFunction("llvm.riscx.rand", simRandType);

    yyparse();

    // outs() << "\n#[LLVM IR]:\n";
    module->print(outs(), nullptr);


    if (!runSimulation) {
        return 0;
    }

    // Interpreter of LLVM IR
    outs() << "Running code...\n";
	ExecutionEngine *ee = EngineBuilder(std::unique_ptr<Module>(module)).create();
    ee->InstallLazyFunctionCreator([&](const std::string &fnName) -> void * {
        if (fnName == "llvm.riscx.putpixel") {
            return reinterpret_cast<void *>(simPutPixel);
        }
        if (fnName == "llvm.riscx.flush") {
            return reinterpret_cast<void *>(simFlush);
        }
        if (fnName == "llvm.riscx.rand") {
            return reinterpret_cast<void *>(simRand);
        }
        return nullptr;
    });

    ee->finalizeObject();

    simInit();

	std::vector<GenericValue> noargs;
    Function *appFunc = module->getFunction("app");
    if (appFunc == nullptr) {
	    outs() << "Can't find app\n";
        return -1;
    }
	ee->runFunction(appFunc, noargs);
	outs() << "Code was run.\n";

    simExit();

    return 0;
}
%}

%token IntLiteral
%token Identifier
%token Mul
%token Div
%token Rem
%token Add
%token Sub
%token ShiftLeft
%token ShiftRight
%token Less
%token LessOrEq
%token Greater
%token GreaterOrEq
%token Equal
%token NotEqual
%token Assignment
%token LogicAnd
%token LogicOr
%token BitwiseAnd
%token BitwiseOr
%token LeftParent
%token RightParent
%token LeftBracket
%token RightBracket
%token LeftBrace
%token RightBrace
%token Semicolon
%token Comma
%token Comment
%token Whitespace
%token IntType
%token VoidType
%token IfKeyword
%token ElseKeyword
%token ForKeyword
%token WhileKeyword
%token FunctionKeyword
%token ReturnKeyword

%%

Parse: Program {YYACCEPT;}


Program:                        FunctionDeclaration {}
                                | IntVariableDeclaration {}
                                | Program FunctionDeclaration {}
                                | Program IntVariableDeclaration {}
                                | %empty {}




SimpleIntDeclaration:           IntType Identifier {
                                    if (!currentScope) {
                                        // Global variables
                                        Value *val = module->getOrInsertGlobal((char*)$2, builder->getInt32Ty());
                                        GlobalVariable *valGV = module->getNamedGlobal((char*)$2);
                                        valGV->setUnnamedAddr(GlobalValue::UnnamedAddr::Global);
                                        valGV->setLinkage(GlobalValue::LinkageTypes::InternalLinkage);
                                        globalValueMap.insert({(char*)$2, val});
                                    }
                                    else {
                                        // Current scope variables
                                        Value *val = builder->CreateAlloca(builder->getInt32Ty());
                                        currentScope->insertValue((char*)$2, val);
                                    }
                                }

InitIntDeclaration:             IntType Identifier Assignment Expression {
                                    if (!currentScope) {
                                        // Global variables
                                        Constant *val = module->getOrInsertGlobal((char*)$2, builder->getInt32Ty());
                                        GlobalVariable *valGV = module->getNamedGlobal((char*)$2);
                                        valGV->setInitializer(builder->getInt32(atoi((char*)$4)));
                                        valGV->setUnnamedAddr(GlobalValue::UnnamedAddr::Global);
                                        valGV->setLinkage(GlobalValue::LinkageTypes::InternalLinkage);
                                        globalValueMap.insert({(char*)$2, val});
                                    }
                                    else {
                                        // Current scope variables
                                        Value *val = builder->CreateAlloca(builder->getInt32Ty());
                                        builder->CreateStore($4, val);
                                        currentScope->insertValue((char*)$2, val);
                                    }
                                }

ArrayIntDeclaration:            IntType Identifier LeftBracket IntLiteral RightBracket {
                                    int size = atoi((char*)$4);
                                    ArrayType *arrayType = ArrayType::get(builder->getInt32Ty(), size);

                                    if (!currentScope) {
                                        // Global variables
                                        Value *val = module->getOrInsertGlobal((char*)$2, arrayType);
                                        GlobalVariable *valGV = module->getNamedGlobal((char*)$2);
                                        valGV->setLinkage(GlobalValue::LinkageTypes::InternalLinkage);
                                        valGV->setAlignment(Align(16));
                                        valGV->setInitializer(ConstantAggregateZero::get(arrayType));
                                        valGV->setDSOLocal(true);
                                        ArrayValue arr = { val, size };
                                        globalArrayMap.insert({(char*)$2, arr});
                                    }
                                    else {
                                        // Current scope variables
                                        Value *val = builder->CreateAlloca(arrayType);
                                        ArrayValue arr = { val, size };
                                        currentScope->insertArrayValue((char*)$2, arr);
                                    }
                                }

IntVariableDeclaration:         InitIntDeclaration {}
                                | ArrayIntDeclaration {}
                                | SimpleIntDeclaration {}

IntValue:                       Identifier LeftBracket Expression RightBracket {
                                    std::string arrName = (char*)$1;

                                    ArrayValue arr = currentScope->findArrayValue(arrName);
                                    if (!arr.val) {
                                        auto itGlob = globalArrayMap.find(arrName);
                                        if (itGlob != globalArrayMap.end()) {
                                            arr = itGlob->second;
                                        }
                                    }

                                    if (arr.val) {
                                        ArrayType *arrayType = ArrayType::get(builder->getInt32Ty(), arr.size);
                                        std::vector<Value *> gepArgs;
                                        gepArgs.push_back(builder->getInt32(0));
                                        gepArgs.push_back($3);
                                        $$ = builder->CreateGEP(arrayType, arr.val, gepArgs);
                                    }
                                }
                                | Identifier {
                                    std::string valName = (char*)$1;

                                    Value *val = currentScope->findValue(valName);
                                    if (!val) {
                                        auto itGlob = globalValueMap.find(valName);
                                        if (itGlob != globalValueMap.end()) {
                                            val = itGlob->second;
                                        }
                                    }

                                    if (val) {
                                        $$ = builder->CreateConstGEP1_32(builder->getInt32Ty(), val, 0);
                                    }
                                }




BeginScope:                     LeftBrace {
                                    StatementScope *child = new StatementScope();
                                    if (currentScope) {
                                        child->parentScope = currentScope;
                                    }
                                    currentScope = child;

                                    if (isScopeFunction) {
                                        for (int i = 0; i < currFuncArgsTypes.size(); ++i) {
                                            if (currFuncArgsTypes[i]->getTypeID() == Type::TypeID::IntegerTyID) {
                                                Value *val = builder->CreateAlloca(currFuncArgsTypes[i]);
                                                builder->CreateStore(currFuncArgsValues[i].second, val);
                                                currentScope->insertValue(currFuncArgsValues[i].first, val);
                                            }
                                            else if (currFuncArgsTypes[i]->getTypeID() == Type::TypeID::ArrayTyID) {
                                                ArrayValue arr;
                                                arr.val = currFuncArgsValues[i].second;
                                                arr.size = currFuncArgsTypes[i]->getArrayNumElements();
                                                currentScope->insertArrayValue(currFuncArgsValues[i].first, arr);
                                            }
                                        }
                                        isScopeFunction = false;
                                    }
                                }

EndScope:                       RightBrace {
                                    if (currentScope) {
                                        StatementScope *tmp = currentScope;
                                        currentScope = currentScope->parentScope;
                                        delete tmp;
                                    }
                                }

StatementsScope:                BeginScope StatementList EndScope {}




IfHeader:                       IfKeyword LeftParent Expression RightParent {
                                    ifTrueBBNums.push(currFuncBBMap.size() + 1);
                                    std::string trueBBName = "BB_" + std::to_string(ifTrueBBNums.top());
                                    currFuncBBMap.insert({trueBBName, BasicBlock::Create(context, trueBBName, currFunc)});

                                    ifFalseBBNums.push(currFuncBBMap.size() + 1);
                                    std::string falseBBName = "BB_" + std::to_string(ifFalseBBNums.top());
                                    currFuncBBMap.insert({falseBBName, BasicBlock::Create(context, falseBBName, currFunc)});

                                    Value *cond = builder->CreateICmpNE($3, builder->getInt32(0));
                                    builder->CreateCondBr(cond, currFuncBBMap[trueBBName], currFuncBBMap[falseBBName]);
                                    builder->SetInsertPoint(currFuncBBMap["BB_" + std::to_string(ifTrueBBNums.top())]);
                                }

ElseHeader:                     ElseKeyword {
                                    afterIfBBNums.push(currFuncBBMap.size() + 1);
                                    std::string afterIfBBName = "BB_" + std::to_string(afterIfBBNums.top());
                                    currFuncBBMap.insert({afterIfBBName, BasicBlock::Create(context, afterIfBBName, currFunc)});

                                    builder->CreateBr(currFuncBBMap["BB_" + std::to_string(afterIfBBNums.top())]);
                                    builder->SetInsertPoint(currFuncBBMap["BB_" + std::to_string(ifFalseBBNums.top())]);
                                }

IfStatement:                    IfHeader StatementsScope ElseHeader StatementsScope {
                                    builder->CreateBr(currFuncBBMap["BB_" + std::to_string(afterIfBBNums.top())]);
                                    builder->SetInsertPoint(currFuncBBMap["BB_" + std::to_string(afterIfBBNums.top())]);

                                    ifTrueBBNums.pop();
                                    ifFalseBBNums.pop();
                                    afterIfBBNums.pop();
                                }
                                | IfHeader StatementsScope {
                                    builder->CreateBr(currFuncBBMap["BB_" + std::to_string(ifFalseBBNums.top())]);
                                    builder->SetInsertPoint(currFuncBBMap["BB_" + std::to_string(ifFalseBBNums.top())]);

                                    ifTrueBBNums.pop();
                                    ifFalseBBNums.pop();
                                }




ForLoopPreHeader:               ForKeyword LeftParent Statement {
                                    forLoopInBBNums.push(currFuncBBMap.size() + 1);
                                    std::string forLoopInBBName = "BB_" + std::to_string(forLoopInBBNums.top());
                                    currFuncBBMap.insert({forLoopInBBName, BasicBlock::Create(context, forLoopInBBName, currFunc)});

                                    forLoopBodyBBNums.push(currFuncBBMap.size() + 1);
                                    std::string forLoopBodyBBName = "BB_" + std::to_string(forLoopBodyBBNums.top());
                                    currFuncBBMap.insert({forLoopBodyBBName, BasicBlock::Create(context, forLoopBodyBBName, currFunc)});

                                    forLoopOutBBNums.push(currFuncBBMap.size() + 1);
                                    std::string forLoopOutBBName = "BB_" + std::to_string(forLoopOutBBNums.top());
                                    currFuncBBMap.insert({forLoopOutBBName, BasicBlock::Create(context, forLoopOutBBName, currFunc)});

                                    forLoopExitBBNums.push(currFuncBBMap.size() + 1);
                                    std::string forLoopExitBBName = "BB_" + std::to_string(forLoopExitBBNums.top());
                                    currFuncBBMap.insert({forLoopExitBBName, BasicBlock::Create(context, forLoopExitBBName, currFunc)});

                                    builder->CreateBr(currFuncBBMap["BB_" + std::to_string(forLoopInBBNums.top())]);
                                    builder->SetInsertPoint(currFuncBBMap["BB_" + std::to_string(forLoopInBBNums.top())]);
                                }

ForLoopHeader:                  Expression {
                                    Value *cond = builder->CreateICmpNE($1, builder->getInt32(0));
                                    builder->CreateCondBr(cond, currFuncBBMap["BB_" + std::to_string(forLoopBodyBBNums.top())],
                                                                currFuncBBMap["BB_" + std::to_string(forLoopExitBBNums.top())]);

                                    builder->SetInsertPoint(currFuncBBMap["BB_" + std::to_string(forLoopOutBBNums.top())]);
                                }

ForLoopPostHeader:              Statement RightParent {
                                    builder->CreateBr(currFuncBBMap["BB_" + std::to_string(forLoopInBBNums.top())]);
                                    builder->SetInsertPoint(currFuncBBMap["BB_" + std::to_string(forLoopBodyBBNums.top())]);
                                }

ForLoopStatement:               ForLoopPreHeader Semicolon ForLoopHeader Semicolon ForLoopPostHeader StatementsScope {
                                    builder->CreateBr(currFuncBBMap["BB_" + std::to_string(forLoopOutBBNums.top())]);
                                    builder->SetInsertPoint(currFuncBBMap["BB_" + std::to_string(forLoopExitBBNums.top())]);

                                    forLoopInBBNums.pop();
                                    forLoopBodyBBNums.pop();
                                    forLoopOutBBNums.pop();
                                    forLoopExitBBNums.pop();
                                }




WhileLoopPreHeader:             WhileKeyword LeftParent {
                                    whileLoopInBBNums.push(currFuncBBMap.size() + 1);
                                    std::string whileLoopInBBName = "BB_" + std::to_string(whileLoopInBBNums.top());
                                    currFuncBBMap.insert({whileLoopInBBName, BasicBlock::Create(context, whileLoopInBBName, currFunc)});

                                    whileLoopBodyBBNums.push(currFuncBBMap.size() + 1);
                                    std::string whileLoopBodyBBName = "BB_" + std::to_string(whileLoopBodyBBNums.top());
                                    currFuncBBMap.insert({whileLoopBodyBBName, BasicBlock::Create(context, whileLoopBodyBBName, currFunc)});

                                    whileLoopExitBBNums.push(currFuncBBMap.size() + 1);
                                    std::string whileLoopExitBBName = "BB_" + std::to_string(whileLoopExitBBNums.top());
                                    currFuncBBMap.insert({whileLoopExitBBName, BasicBlock::Create(context, whileLoopExitBBName, currFunc)});

                                    builder->CreateBr(currFuncBBMap["BB_" + std::to_string(whileLoopInBBNums.top())]);
                                    builder->SetInsertPoint(currFuncBBMap["BB_" + std::to_string(whileLoopInBBNums.top())]);
                                }

WhileLoopPostHeader:            Expression RightParent {
                                    Value *cond = builder->CreateICmpNE($1, builder->getInt32(0));
                                    builder->CreateCondBr(cond, currFuncBBMap["BB_" + std::to_string(whileLoopBodyBBNums.top())],
                                                                currFuncBBMap["BB_" + std::to_string(whileLoopExitBBNums.top())]);

                                    builder->SetInsertPoint(currFuncBBMap["BB_" + std::to_string(whileLoopBodyBBNums.top())]);
                                }

WhileLoopStatement:             WhileLoopPreHeader WhileLoopPostHeader StatementsScope {
                                    builder->CreateBr(currFuncBBMap["BB_" + std::to_string(whileLoopInBBNums.top())]);
                                    builder->SetInsertPoint(currFuncBBMap["BB_" + std::to_string(whileLoopExitBBNums.top())]);

                                    whileLoopInBBNums.pop();
                                    whileLoopBodyBBNums.pop();
                                    whileLoopExitBBNums.pop();
                                }




ReturnType:                     IntType {}
                                | VoidType {}

IntArgumentDeclaration:         IntType Identifier {
                                    currFuncArgsTypes.push_back(builder->getInt32Ty());
                                    currFuncArgsValues.push_back({(char*)$2, nullptr});
                                }
                                | IntType Identifier LeftBracket IntLiteral RightBracket {
                                    int size = atoi((char*)$4);
                                    ArrayType *arrayType = ArrayType::get(builder->getInt32Ty(), size);
                                    currFuncArgsTypes.push_back(arrayType);
                                    currFuncArgsValues.push_back({(char*)$2, nullptr});
                                }

FunctionArgsDeclarations:       FunctionArgsDeclarations Comma IntArgumentDeclaration {}
                                | IntArgumentDeclaration {}
                                | %empty {}

FunctionArgsExpressions:        FunctionArgsExpressions Comma Expression {
                                    currFuncCalleeArgs.push_back($3);
                                }
                                | Expression {
                                    currFuncCalleeArgs.push_back($1);
                                }
                                | %empty {}

FunctionHeader:                 ReturnType FunctionKeyword Identifier LeftParent FunctionArgsDeclarations RightParent {
                                    Type *retType = nullptr;
                                    
                                    std::string retTypeStr = (char*)$1;
                                    if (retTypeStr == "int") {
                                        retType = builder->getInt32Ty();
                                    }
                                    else if (retTypeStr == "void") {
                                        retType = builder->getVoidTy();
                                    }

                                    if (retType) {
                                        // declare ReturnType @Identifier()
                                        FunctionType *funcType = FunctionType::get(retType, currFuncArgsTypes, false);
                                        currFunc = Function::Create(funcType, Function::ExternalLinkage, (char*)$3, module);

                                        std::string BBName = "BB_" + std::to_string(currFuncBBMap.size() + 1);
                                        BasicBlock *entryBB = BasicBlock::Create(context, BBName, currFunc);
                                        builder->SetInsertPoint(entryBB);
                                        currFuncBBMap.insert({BBName, entryBB});

                                        for (int i = 0; i < currFuncArgsTypes.size(); ++i) {
                                            currFuncArgsValues[i].second = currFunc->getArg(i);
                                        }
                                        isScopeFunction = true;
                                    }
                                }

FunctionDeclaration:            FunctionHeader StatementsScope {}

FunctionCall:                   Identifier LeftParent FunctionArgsExpressions RightParent {
                                    std::string funcName = (char*)$1;
                                    if (funcName == "PUT_PIXEL") {
                                        builder->CreateCall(simPutPixelFunc, currFuncCalleeArgs);
                                        currFuncCalleeArgs.clear();
                                    }
                                    else if (funcName == "FLUSH") {
                                        builder->CreateCall(simFlushFunc, currFuncCalleeArgs);
                                        currFuncCalleeArgs.clear();
                                    }
                                    else if (funcName == "RAND") {
                                        $$ = builder->CreateCall(simRandFunc, currFuncCalleeArgs);
                                        currFuncCalleeArgs.clear();
                                    }
                                    else {
                                        Function *func = module->getFunction(funcName);
                                        if (func) {
                                            $$ = builder->CreateCall(func, currFuncCalleeArgs);
                                            currFuncCalleeArgs.clear();
                                        }
                                    }
                                }




AssigmentStatement:             IntValue Assignment Expression {
                                    builder->CreateStore($3, $1);
                                }

ReturnStatement:                ReturnKeyword Expression {
                                    $$ = builder->CreateRet($2);
                                    currFunc = nullptr;
                                    currFuncArgsTypes.clear();
                                    currFuncArgsValues.clear();
                                    currFuncBBMap.clear();
                                }
                                | ReturnKeyword {
                                    $$ = builder->CreateRetVoid();
                                    currFunc = nullptr;
                                    currFuncArgsTypes.clear();
                                    currFuncArgsValues.clear();
                                    currFuncBBMap.clear();
                                }




Statement:                      IntVariableDeclaration {}
                                | AssigmentStatement {}
                                | IfStatement {}
                                | WhileLoopStatement {}
                                | ForLoopStatement {}
                                | FunctionCall {}
                                | ReturnStatement {}

StatementList:                  StatementList Statement {}
                                | %empty {}




Primary:                        IntLiteral {
                                    $$ = builder->getInt32(atoi((char*)$1));
                                }
                                | IntValue {
                                    $$ = builder->CreateLoad(builder->getInt32Ty(), $1);
                                }
                                | FunctionCall {
                                    $$ = $1;
                                }

Factor:                         Primary {
                                    $$ = $1;
                                }
                                | Sub Primary {
                                    $$ = builder->CreateNeg($2);
                                }
                                | LeftParent Expression RightParent {
                                    $$ = $2;
                                }

HighPriorityOperation:          Mul {}
                                | Div {}
                                | Rem {}

LowPriorityOperation:           Add {}
                                | Sub {}
                                | ShiftLeft {}
                                | ShiftRight {}
                                | BitwiseAnd {}
                                | BitwiseOr {}

ExpressionOperation:            Less {}
                                | LessOrEq {}
                                | Greater {}
                                | GreaterOrEq {}
                                | Equal {}
                                | NotEqual {}
                                | LogicAnd {}
                                | LogicOr {}

Summand:                        Factor {
                                    $$ = $1;
                                }
                                | Summand HighPriorityOperation Factor {
                                    std::string operation = (char*)$2;
                                    if (operation == "*") {
                                        $$ = builder->CreateMul($1, $3);
                                    }
                                    else if (operation == "/") {
                                        $$ = builder->CreateSDiv($1, $3);
                                    }
                                    else if (operation == "%") {
                                        $$ = builder->CreateSRem($1, $3);
                                    }
                                }

Simple:                         Summand {
                                    $$ = $1;
                                }
                                | Simple LowPriorityOperation Summand {
                                    std::string operation = (char*)$2;
                                    if (operation == "+") {
                                        $$ = builder->CreateAdd($1, $3);
                                    }
                                    else if (operation == "-") {
                                        $$ = builder->CreateSub($1, $3);
                                    }
                                    else if (operation == "<<") {
                                        $$ = builder->CreateShl($1, $3);
                                    }
                                    else if (operation == ">>") {
                                        $$ = builder->CreateLShr($1, $3);
                                    }
                                    else if (operation == "&") {
                                        $$ = builder->CreateAnd($1, $3);
                                    }
                                    else if (operation == "|") {
                                        $$ = builder->CreateOr($1, $3);
                                    }
                                }

Expression:                     Simple {
                                    $$ = $1;
                                }
                                | Expression ExpressionOperation Simple {
                                    std::string operation = (char*)$2;
                                    if (operation == "<") {
                                        $$ = builder->CreateZExt(builder->CreateICmpSLT($1, $3), builder->getInt32Ty());
                                    }
                                    else if (operation == "<=") {
                                        $$ = builder->CreateZExt(builder->CreateICmpSLE($1, $3), builder->getInt32Ty());
                                    }
                                    else if (operation == ">") {
                                        $$ = builder->CreateZExt(builder->CreateICmpSGT($1, $3), builder->getInt32Ty());
                                    }
                                    else if (operation == ">=") {
                                        $$ = builder->CreateZExt(builder->CreateICmpSGE($1, $3), builder->getInt32Ty());
                                    }
                                    else if (operation == "==") {
                                        $$ = builder->CreateZExt(builder->CreateICmpEQ($1, $3), builder->getInt32Ty());
                                    }
                                    else if (operation == "!=") {
                                        $$ = builder->CreateZExt(builder->CreateICmpNE($1, $3), builder->getInt32Ty());
                                    }
                                    else if (operation == "&&") {
                                        Value *first = builder->CreateZExt(builder->CreateICmpSGT($1, builder->getInt32(0)), builder->getInt32Ty());
                                        Value *second = builder->CreateZExt(builder->CreateICmpSGT($3, builder->getInt32(0)), builder->getInt32Ty());
                                        $$ = builder->CreateAnd(first, second);
                                    }
                                    else if (operation == "||") {
                                        Value *first = builder->CreateZExt(builder->CreateICmpSGT($1, builder->getInt32(0)), builder->getInt32Ty());
                                        Value *second = builder->CreateZExt(builder->CreateICmpSGT($3, builder->getInt32(0)), builder->getInt32Ty());
                                        $$ = builder->CreateOr(first, second);
                                    }
                                }

%%