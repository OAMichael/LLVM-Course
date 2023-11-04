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

int simRand()
{
    return rand();
}




#include "llvm/ExecutionEngine/ExecutionEngine.h"
#include "llvm/ExecutionEngine/GenericValue.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Module.h"
#include "llvm/Support/TargetSelect.h"
#include "llvm/Support/raw_ostream.h"
using namespace llvm;

int main() {
  LLVMContext context;
  // ; ModuleID = 'app'
  // source_filename = "app"
  Module *module = new Module("app", context);
  IRBuilder<> builder(context);

  /*
    Define struct and global (static) variable  
  */

  StructType* cellStructType = StructType::create(context, {IntegerType::get(context, 32), IntegerType::get(context, 32)}, "struct.Cell");

  ArrayType::Type *arrayType = ArrayType::get(cellStructType, 2500);
  Constant *swapCells = module->getOrInsertGlobal("updatePixels.swapCells", arrayType);
  GlobalVariable *swapCellsGV = module->getNamedGlobal("updatePixels.swapCells");

  Align align16 = Align(16);
  Align align8  = Align(8);
  Align align4  = Align(4);

  swapCellsGV->setUnnamedAddr(GlobalValue::UnnamedAddr::Global);
  swapCellsGV->setLinkage(GlobalValue::LinkageTypes::InternalLinkage);
  swapCellsGV->setAlignment(align16);
  swapCellsGV->setInitializer(ConstantAggregateZero::get(arrayType));
  

  /*
    Declare external functions
  */

  // declare dso_local void @simFlush(...) local_unnamed_addr #2
  FunctionType *simFlushFuncType = FunctionType::get(builder.getVoidTy(), false);
  FunctionCallee simFlushFunc = module->getOrInsertFunction("simFlush", simFlushFuncType);

  // declare dso_local void @simPutPixel(i32, i32, i32) local_unnamed_addr #2
  FunctionType *simPutPixelFuncType = FunctionType::get(builder.getVoidTy(), {builder.getInt32Ty(), builder.getInt32Ty(), builder.getInt32Ty()}, false);
  FunctionCallee simPutPixelFunc = module->getOrInsertFunction("simPutPixel", simPutPixelFuncType);

  // declare dso_local i32 @simRand(...) local_unnamed_addr #2
  FunctionType *simRandFuncType = FunctionType::get(builder.getInt32Ty(), false);
  FunctionCallee simRandFunc = module->getOrInsertFunction("simRand", simRandFuncType);


  /*
    Define main functions
  */

  // define dso_local void @app() local_unnamed_addr #0
  FunctionType *appFuncType = FunctionType::get(builder.getVoidTy(), false);
  Function *appFunc = Function::Create(appFuncType, Function::ExternalLinkage, "app", module);
  appFunc->setDSOLocal(true);
  appFunc->setUnnamedAddr(GlobalValue::UnnamedAddr::Local);

  // define internal fastcc void @paintCellPixels(i32 %0, i32 %1, i32 %2) unnamed_addr #3
  FunctionType *paintCellPixelsFuncType = FunctionType::get(builder.getVoidTy(), {builder.getInt32Ty(), builder.getInt32Ty(), builder.getInt32Ty()}, false);
  Function *paintCellPixelsFunc = Function::Create(paintCellPixelsFuncType, Function::InternalLinkage, "paintCellPixels", module);
  paintCellPixelsFunc->setUnnamedAddr(GlobalValue::UnnamedAddr::Global);
  paintCellPixelsFunc->setCallingConv(CallingConv::Fast);


  /*
    Actual IR for app() function
  */
  {
    // Declare all basic blocks in advance
    BasicBlock *bBlock0   = BasicBlock::Create(context, "", appFunc);
    BasicBlock *bBlock3   = BasicBlock::Create(context, "", appFunc);
    BasicBlock *bBlock7   = BasicBlock::Create(context, "", appFunc);
    BasicBlock *bBlock10  = BasicBlock::Create(context, "", appFunc);
    BasicBlock *bBlock15  = BasicBlock::Create(context, "", appFunc);
    BasicBlock *bBlock20  = BasicBlock::Create(context, "", appFunc);
    BasicBlock *bBlock23  = BasicBlock::Create(context, "", appFunc);
    BasicBlock *bBlock24  = BasicBlock::Create(context, "", appFunc);
    BasicBlock *bBlock37  = BasicBlock::Create(context, "", appFunc);
    BasicBlock *bBlock38  = BasicBlock::Create(context, "", appFunc);
    BasicBlock *bBlock111 = BasicBlock::Create(context, "", appFunc);
    BasicBlock *bBlock113 = BasicBlock::Create(context, "", appFunc);
    BasicBlock *bBlock117 = BasicBlock::Create(context, "", appFunc);
    BasicBlock *bBlock118 = BasicBlock::Create(context, "", appFunc);
    BasicBlock *bBlock121 = BasicBlock::Create(context, "", appFunc);
    BasicBlock *bBlock122 = BasicBlock::Create(context, "", appFunc);
    BasicBlock *bBlock123 = BasicBlock::Create(context, "", appFunc);
    BasicBlock *bBlock127 = BasicBlock::Create(context, "", appFunc);
    BasicBlock *bBlock131 = BasicBlock::Create(context, "", appFunc);
    BasicBlock *bBlock134 = BasicBlock::Create(context, "", appFunc);
    BasicBlock *bBlock144 = BasicBlock::Create(context, "", appFunc);
    BasicBlock *bBlock145 = BasicBlock::Create(context, "", appFunc);
    BasicBlock *bBlock147 = BasicBlock::Create(context, "", appFunc);
    BasicBlock *bBlock151 = BasicBlock::Create(context, "", appFunc);
    BasicBlock *bBlock153 = BasicBlock::Create(context, "", appFunc);
    BasicBlock *bBlock164 = BasicBlock::Create(context, "", appFunc);


    // 0:
    builder.SetInsertPoint(bBlock0);

    // %1 = alloca [2500 x %struct.Cell], align 16
    AllocaInst *value1 = builder.CreateAlloca(arrayType);
    value1->setAlignment(align16);

    // %2 = bitcast [2500 x %struct.Cell]* %1 to i8*
    Value *value2 = builder.CreateBitCast(value1, builder.getInt8PtrTy());
    
    // call void @llvm.lifetime.start.p0i8(i64 20000, i8* nonnull %2) #4
    Type *intrinStartTypes[2] = {builder.getInt64Ty(), builder.getInt8PtrTy()}; 
    Value *intrinStartArgs[2] = {builder.getInt64(20000), value2};
    CallInst *intrinStart = builder.CreateIntrinsic(Intrinsic::lifetime_start, intrinStartTypes, intrinStartArgs);
    intrinStart->addAttribute(2, Attribute::NonNull);
  
    // call void @llvm.memset.p0i8.i64(i8* nonnull align 16 dereferenceable(20000) %2, i8 0, i64 20000, i1 false)
    Type *intrinMemsetTypes[4] = {builder.getInt8PtrTy(), builder.getInt8Ty(), builder.getInt64Ty(), builder.getInt1Ty()}; 
    Value *intrinMemsetArgs[4] = {value2, builder.getInt8(0), builder.getInt64(20000), builder.getFalse()};
    CallInst *intrinMemset = builder.CreateIntrinsic(Intrinsic::memset, intrinMemsetTypes, intrinMemsetArgs);
    intrinMemset->addAttribute(1, Attribute::NonNull);
    intrinMemset->addAttribute(1, Attribute::getWithAlignment(context, align16));
    intrinMemset->addDereferenceableAttr(1, 20000);

    // br label %3
    builder.CreateBr(bBlock3);


    // 3:
    builder.SetInsertPoint(bBlock3);

    // %4 = phi i64 [ 0, %0 ], [ %8, %7 ]
    PHINode *value4 = builder.CreatePHI(builder.getInt64Ty(), 2);

    // %5 = mul nuw nsw i64 %4, 50
    Value *value5 = builder.CreateMul(value4, builder.getInt64(50), "", true, true);

    // %6 = trunc i64 %4 to i32
    Value *value6 = builder.CreateTrunc(value4, builder.getInt32Ty());

    // br label %10
    builder.CreateBr(bBlock10);


    // 7:
    builder.SetInsertPoint(bBlock7);

    // %8 = add nuw nsw i64 %4, 1
    Value *value8 = builder.CreateAdd(value4, builder.getInt64(1), "", true, true);

    // %9 = icmp eq i64 %8, 50
    Value *value9 = builder.CreateICmpEQ(value8, builder.getInt64(50));

    // br i1 %9, label %23, label %3
    builder.CreateCondBr(value9, bBlock23, bBlock3);


    // 10:
    builder.SetInsertPoint(bBlock10);

    // %11 = phi i64 [ 0, %3 ], [ %21, %20 ]
    PHINode *value11 = builder.CreatePHI(builder.getInt64Ty(), 2);

    // %12 = tail call i32 (...) @simRand() #4
    CallInst *value12 = builder.CreateCall(simRandFunc);
    value12->setTailCall(true);

    // %13 = srem i32 %12, 31
    Value *value13 = builder.CreateSRem(value12, builder.getInt32(31));

    // %14 = icmp eq i32 %13, 0
    Value *value14 = builder.CreateICmpEQ(value13, builder.getInt32(0));

    // br i1 %14, label %15, label %20
    builder.CreateCondBr(value14, bBlock15, bBlock20);


    // 15:
    builder.SetInsertPoint(bBlock15);

    // %16 = add nuw nsw i64 %11, %5
    Value *value16 = builder.CreateAdd(value11, value5, "", true, true);

    // %17 = getelementptr inbounds [2500 x %struct.Cell], [2500 x %struct.Cell]* %1, i64 0, i64 %16, i32 0
    Value *value17 = builder.CreateInBoundsGEP(value1, {builder.getInt64(0), value16, builder.getInt32(0)});

    // store i32 1, i32* %17, align 8, !tbaa !2
    builder.CreateAlignedStore(builder.getInt32(1), value17, align8);

    // %18 = getelementptr inbounds [2500 x %struct.Cell], [2500 x %struct.Cell]* %1, i64 0, i64 %16, i32 1
    Value *value18 = builder.CreateInBoundsGEP(value1, {builder.getInt64(0), value16, builder.getInt32(1)});

    // store i32 1, i32* %18, align 4, !tbaa !7
    builder.CreateAlignedStore(builder.getInt32(1), value18, align4);

    // %19 = trunc i64 %11 to i32
    Value *value19 = builder.CreateTrunc(value11, builder.getInt32Ty());

    // tail call fastcc void @paintCellPixels(i32 %19, i32 %6, i32 -16711936) #4
    Value *callPaintArgs0[3] = {value19, value6, builder.getInt32(-16711936)};
    CallInst *callPaint0 = builder.CreateCall(paintCellPixelsFunc, callPaintArgs0);
    callPaint0->setTailCall(true);
    callPaint0->setCallingConv(CallingConv::Fast);

    // br label %20
    builder.CreateBr(bBlock20);


    // 20:
    builder.SetInsertPoint(bBlock20);

    // %21 = add nuw nsw i64 %11, 1
    Value *value21 = builder.CreateAdd(value11, builder.getInt64(1), "", true, true);

    // %22 = icmp eq i64 %21, 50
    Value *value22 = builder.CreateICmpEQ(value21, builder.getInt64(50));

    // br i1 %22, label %7, label %10
    builder.CreateCondBr(value22, bBlock7, bBlock10);


    // 23:
    builder.SetInsertPoint(bBlock23);

    // tail call void (...) @simFlush() #4
    CallInst *callSimFlush0 = builder.CreateCall(simFlushFunc, {});
    callSimFlush0->setTailCall(true);

    // br label %24
    builder.CreateBr(bBlock24);


    // 24:
    builder.SetInsertPoint(bBlock24);

    // %25 = phi i64 [ 0, %23 ], [ %30, %37 ]
    PHINode *value25 = builder.CreatePHI(builder.getInt64Ty(), 2);

    // %26 = mul nuw nsw i64 %25, 50
    Value *value26 = builder.CreateMul(value25, builder.getInt64(50), "", true, true);

    // %27 = trunc i64 %25 to i32
    Value *value27 = builder.CreateTrunc(value25, builder.getInt32Ty());

    // %28 = add i32 %27, 49
    Value *value28 = builder.CreateAdd(value27, builder.getInt32(49));

    // %29 = urem i32 %28, 50
    Value *value29 = builder.CreateURem(value28, builder.getInt32(50));

    // %30 = add nuw nsw i64 %25, 1
    Value *value30 = builder.CreateAdd(value25, builder.getInt64(1), "", true, true);

    // %31 = icmp eq i64 %30, 50
    Value *value31 = builder.CreateICmpEQ(value30, builder.getInt64(50));

    // %32 = trunc i64 %30 to i32
    Value *value32 = builder.CreateTrunc(value30, builder.getInt32Ty());

    // %33 = mul nuw nsw i32 %29, 50
    Value *value33 = builder.CreateMul(value29, builder.getInt32(50), "", true, true);

    // %34 = mul i32 %32, 50
    Value *value34 = builder.CreateMul(value32, builder.getInt32(50));

    // %35 = select i1 %31, i32 0, i32 %34
    Value *value35 = builder.CreateSelect(value31, builder.getInt32(0), value34);

    // %36 = trunc i64 %26 to i32
    Value *value36 = builder.CreateTrunc(value26, builder.getInt32Ty());

    // br label %38
    builder.CreateBr(bBlock38);


    // 37:
    builder.SetInsertPoint(bBlock37);

    // br i1 %31, label %127, label %24
    builder.CreateCondBr(value31, bBlock127, bBlock24);


    // 38:
    builder.SetInsertPoint(bBlock38);
    
    // %39 = phi i64 [ 0, %24 ], [ %47, %123 ]
    PHINode *value39 = builder.CreatePHI(builder.getInt64Ty(), 2);

    // %40 = phi i32 [ 0, %24 ], [ %48, %123 ]
    PHINode *value40 = builder.CreatePHI(builder.getInt32Ty(), 2);

    // %41 = trunc i32 %40 to i8
    Value *value41 = builder.CreateTrunc(value40, builder.getInt8Ty());

    // %42 = add i8 %41, 49
    Value *value42 = builder.CreateAdd(value41, builder.getInt8(49));

    // %43 = urem i8 %42, 50
    Value *value43 = builder.CreateURem(value42, builder.getInt8(50));

    // %44 = zext i8 %43 to i32
    Value *value44 = builder.CreateZExt(value43, builder.getInt32Ty());

    // %45 = urem i8 %41, 50
    Value *value45 = builder.CreateURem(value41, builder.getInt8(50));

    // %46 = zext i8 %45 to i32
    Value *value46 = builder.CreateZExt(value45, builder.getInt32Ty());

    // %47 = add nuw nsw i64 %39, 1
    Value *value47 = builder.CreateAdd(value39, builder.getInt64(1), "", true, true);

    // %48 = add nuw nsw i32 %40, 1
    Value *value48 = builder.CreateAdd(value40, builder.getInt32(1), "", true, true);

    // %49 = trunc i64 %47 to i8
    Value *value49 = builder.CreateTrunc(value47, builder.getInt8Ty());

    // %50 = urem i8 %49, 50
    Value *value50 = builder.CreateURem(value49, builder.getInt8(50));

    // %51 = zext i8 %50 to i32
    Value *value51 = builder.CreateZExt(value50, builder.getInt32Ty());

    // %52 = add nuw nsw i32 %33, %44
    Value *value52 = builder.CreateAdd(value33, value44, "", true, true);

    // %53 = zext i32 %52 to i64
    Value *value53 = builder.CreateZExt(value52, builder.getInt64Ty());

    // %54 = getelementptr inbounds [2500 x %struct.Cell], [2500 x %struct.Cell]* %1, i64 0, i64 %53, i32 0
    Value *value54 = builder.CreateInBoundsGEP(value1, {builder.getInt64(0), value53, builder.getInt32(0)});

    // %55 = load i32, i32* %54, align 8, !tbaa !8
    Value *value55 = builder.CreateAlignedLoad(value54, align8);

    // %56 = add nuw nsw i32 %44, %36
    Value *value56 = builder.CreateAdd(value44, value36, "", true, true);

    // %57 = zext i32 %56 to i64
    Value *value57 = builder.CreateZExt(value56, builder.getInt64Ty());

    // %58 = getelementptr inbounds [2500 x %struct.Cell], [2500 x %struct.Cell]* %1, i64 0, i64 %57, i32 0
    Value *value58 = builder.CreateInBoundsGEP(value1, {builder.getInt64(0), value57, builder.getInt32(0)});

    // %59 = load i32, i32* %58, align 8, !tbaa !8
    Value *value59 = builder.CreateAlignedLoad(value58, align8);

    // %60 = add nuw nsw i32 %35, %44
    Value *value60 = builder.CreateAdd(value35, value44, "", true, true);

    // %61 = zext i32 %60 to i64
    Value *value61 = builder.CreateZExt(value60, builder.getInt64Ty());    

    // %62 = getelementptr inbounds [2500 x %struct.Cell], [2500 x %struct.Cell]* %1, i64 0, i64 %61, i32 0
    Value *value62 = builder.CreateInBoundsGEP(value1, {builder.getInt64(0), value61, builder.getInt32(0)});

    // %63 = load i32, i32* %62, align 8, !tbaa !8
    Value *value63 = builder.CreateAlignedLoad(value62, align8);

    // %64 = add nuw nsw i32 %33, %46
    Value *value64 = builder.CreateAdd(value33, value46, "", true, true);

    // %65 = zext i32 %64 to i64
    Value *value65 = builder.CreateZExt(value64, builder.getInt64Ty());        

    // %66 = getelementptr inbounds [2500 x %struct.Cell], [2500 x %struct.Cell]* %1, i64 0, i64 %65, i32 0
    Value *value66 = builder.CreateInBoundsGEP(value1, {builder.getInt64(0), value65, builder.getInt32(0)});

    // %67 = load i32, i32* %66, align 8, !tbaa !8
    Value *value67 = builder.CreateAlignedLoad(value66, align8);

    // %68 = add nuw nsw i32 %35, %46
    Value *value68 = builder.CreateAdd(value35, value46, "", true, true);

    // %69 = zext i32 %68 to i64
    Value *value69 = builder.CreateZExt(value68, builder.getInt64Ty());      

    // %70 = getelementptr inbounds [2500 x %struct.Cell], [2500 x %struct.Cell]* %1, i64 0, i64 %69, i32 0
    Value *value70 = builder.CreateInBoundsGEP(value1, {builder.getInt64(0), value69, builder.getInt32(0)});

    // %71 = load i32, i32* %70, align 8, !tbaa !8
    Value *value71 = builder.CreateAlignedLoad(value70, align8);

    // %72 = add nuw nsw i32 %33, %51
    Value *value72 = builder.CreateAdd(value33, value51, "", true, true);
    
    // %73 = zext i32 %72 to i64
    Value *value73 = builder.CreateZExt(value72, builder.getInt64Ty());

    // %74 = getelementptr inbounds [2500 x %struct.Cell], [2500 x %struct.Cell]* %1, i64 0, i64 %73, i32 0
    Value *value74 = builder.CreateInBoundsGEP(value1, {builder.getInt64(0), value73, builder.getInt32(0)});

    // %75 = load i32, i32* %74, align 8, !tbaa !8
    Value *value75 = builder.CreateAlignedLoad(value74, align8);    

    // %76 = add nuw nsw i32 %51, %36
    Value *value76 = builder.CreateAdd(value51, value36, "", true, true);

    // %77 = zext i32 %76 to i64
    Value *value77 = builder.CreateZExt(value76, builder.getInt64Ty());

    // %78 = getelementptr inbounds [2500 x %struct.Cell], [2500 x %struct.Cell]* %1, i64 0, i64 %77, i32 0
    Value *value78 = builder.CreateInBoundsGEP(value1, {builder.getInt64(0), value77, builder.getInt32(0)});    

    // %79 = load i32, i32* %78, align 8, !tbaa !8
    Value *value79 = builder.CreateAlignedLoad(value78, align8);

    // %80 = add nuw nsw i32 %35, %51
    Value *value80 = builder.CreateAdd(value35, value51, "", true, true);

    // %81 = zext i32 %80 to i64
    Value *value81 = builder.CreateZExt(value80, builder.getInt64Ty());    

    // %82 = getelementptr inbounds [2500 x %struct.Cell], [2500 x %struct.Cell]* %1, i64 0, i64 %81, i32 0
    Value *value82 = builder.CreateInBoundsGEP(value1, {builder.getInt64(0), value81, builder.getInt32(0)});      

    // %83 = load i32, i32* %82, align 8, !tbaa !8
    Value *value83 = builder.CreateAlignedLoad(value82, align8);    

    // %84 = icmp eq i32 %55, 1
    Value *value84 = builder.CreateICmpEQ(value55, builder.getInt32(1));

    // %85 = zext i1 %84 to i32
    Value *value85 = builder.CreateZExt(value84, builder.getInt32Ty());

    // %86 = icmp eq i32 %59, 1
    Value *value86 = builder.CreateICmpEQ(value59, builder.getInt32(1));

    // %87 = zext i1 %86 to i32
    Value *value87 = builder.CreateZExt(value86, builder.getInt32Ty());

    // %88 = add nuw nsw i32 %87, %85
    Value *value88 = builder.CreateAdd(value87, value85, "", true, true);

    // %89 = icmp eq i32 %63, 1
    Value *value89 = builder.CreateICmpEQ(value63, builder.getInt32(1));

    // %90 = zext i1 %89 to i32
    Value *value90 = builder.CreateZExt(value89, builder.getInt32Ty());

    // %91 = add nuw nsw i32 %88, %90
    Value *value91 = builder.CreateAdd(value88, value90, "", true, true);

    // %92 = icmp eq i32 %67, 1
    Value *value92 = builder.CreateICmpEQ(value67, builder.getInt32(1));

    // %93 = zext i1 %92 to i32
    Value *value93 = builder.CreateZExt(value92, builder.getInt32Ty());

    // %94 = add nuw nsw i32 %91, %93
    Value *value94 = builder.CreateAdd(value91, value93, "", true, true);

    // %95 = icmp eq i32 %71, 1
    Value *value95 = builder.CreateICmpEQ(value71, builder.getInt32(1));    

    // %96 = zext i1 %95 to i32
    Value *value96 = builder.CreateZExt(value95, builder.getInt32Ty());

    // %97 = add nuw nsw i32 %94, %96
    Value *value97 = builder.CreateAdd(value94, value96, "", true, true);

    // %98 = icmp eq i32 %75, 1
    Value *value98 = builder.CreateICmpEQ(value75, builder.getInt32(1));    

    // %99 = zext i1 %98 to i32
    Value *value99 = builder.CreateZExt(value98, builder.getInt32Ty());    

    // %100 = add nuw nsw i32 %97, %99
    Value *value100 = builder.CreateAdd(value97, value99, "", true, true);

    // %101 = icmp eq i32 %79, 1
    Value *value101 = builder.CreateICmpEQ(value79, builder.getInt32(1));    

    // %102 = zext i1 %101 to i32
    Value *value102 = builder.CreateZExt(value101, builder.getInt32Ty());    

    // %103 = add nuw nsw i32 %100, %102
    Value *value103 = builder.CreateAdd(value100, value102, "", true, true);

    // %104 = icmp eq i32 %83, 1
    Value *value104 = builder.CreateICmpEQ(value83, builder.getInt32(1));    

    // %105 = zext i1 %104 to i32
    Value *value105 = builder.CreateZExt(value104, builder.getInt32Ty());    

    // %106 = add nuw nsw i32 %103, %105
    Value *value106 = builder.CreateAdd(value103, value105, "", true, true);

    // %107 = add nuw nsw i64 %39, %26
    Value *value107 = builder.CreateAdd(value39, value26, "", true, true);

    // %108 = getelementptr inbounds [2500 x %struct.Cell], [2500 x %struct.Cell]* %1, i64 0, i64 %107, i32 0
    Value *value108 = builder.CreateInBoundsGEP(value1, {builder.getInt64(0), value107, builder.getInt32(0)});  

    // %109 = load i32, i32* %108, align 8, !tbaa !2
    Value *value109 = builder.CreateAlignedLoad(value108, align8);

    // %110 = icmp eq i32 %109, 1
    Value *value110 = builder.CreateICmpEQ(value109, builder.getInt32(1));    

    // br i1 %110, label %111, label %118
    builder.CreateCondBr(value110, bBlock111, bBlock118);


    // 111:
    builder.SetInsertPoint(bBlock111);

    // %112 = getelementptr inbounds [2500 x %struct.Cell], [2500 x %struct.Cell]* @updatePixels.swapCells, i64 0, i64 %107, i32 0
    Value *value112 = builder.CreateInBoundsGEP(swapCells, {builder.getInt64(0), value107, builder.getInt32(0)});

    // switch i32 %106, label %117 [
    SwitchInst *switchInst = builder.CreateSwitch(value106, bBlock117, 4);
    switchInst->addCase(builder.getInt32(5), bBlock113);
    switchInst->addCase(builder.getInt32(4), bBlock113);
    switchInst->addCase(builder.getInt32(3), bBlock113);
    switchInst->addCase(builder.getInt32(0), bBlock113);


    // 113:
    builder.SetInsertPoint(bBlock113);

    // store i32 1, i32* %112, align 8, !tbaa !2
    builder.CreateAlignedStore(builder.getInt32(1), value112, align8);

    // %114 = getelementptr inbounds [2500 x %struct.Cell], [2500 x %struct.Cell]* %1, i64 0, i64 %107, i32 1
    Value *value114 = builder.CreateInBoundsGEP(value1, {builder.getInt64(0), value107, builder.getInt32(1)});

    // %115 = load i32, i32* %114, align 4, !tbaa !7
    Value *value115 = builder.CreateAlignedLoad(value114, align4);

    // %116 = add i32 %115, 1
    Value *value116 = builder.CreateAdd(value115, builder.getInt32(1));

    // br label %123
    builder.CreateBr(bBlock123);


    // 117:
    builder.SetInsertPoint(bBlock117);

    // store i32 0, i32* %112, align 8, !tbaa !2
    builder.CreateAlignedStore(builder.getInt32(0), value112, align8);

    // br label %123
    builder.CreateBr(bBlock123);


    // 118:
    builder.SetInsertPoint(bBlock118);

    // %119 = icmp eq i32 %106, 2
    Value *value119 = builder.CreateICmpEQ(value106, builder.getInt32(2));

    // %120 = getelementptr inbounds [2500 x %struct.Cell], [2500 x %struct.Cell]* @updatePixels.swapCells, i64 0, i64 %107, i32 0
    Value *value120 = builder.CreateInBoundsGEP(swapCells, {builder.getInt64(0), value107, builder.getInt32(0)});

    // br i1 %119, label %121, label %122
    builder.CreateCondBr(value119, bBlock121, bBlock122);


    // 121:
    builder.SetInsertPoint(bBlock121);

    // store i32 1, i32* %120, align 8, !tbaa !2
    builder.CreateAlignedStore(builder.getInt32(1), value120, align8);

    // br label %123
    builder.CreateBr(bBlock123);


    // 122:
    builder.SetInsertPoint(bBlock122);

    // store i32 0, i32* %120, align 8, !tbaa !2
    builder.CreateAlignedStore(builder.getInt32(0), value120, align8);

    // br label %123
    builder.CreateBr(bBlock123);


    // 123:
    builder.SetInsertPoint(bBlock123);

    // %124 = phi i32 [ 0, %122 ], [ 1, %121 ], [ 0, %117 ], [ %116, %113 ]
    PHINode *value124 = builder.CreatePHI(builder.getInt32Ty(), 4);

    // %125 = getelementptr inbounds [2500 x %struct.Cell], [2500 x %struct.Cell]* @updatePixels.swapCells, i64 0, i64 %107, i32 1
    Value *value125 = builder.CreateInBoundsGEP(swapCells, {builder.getInt64(0), value107, builder.getInt32(1)});

    // store i32 %124, i32* %125, align 4, !tbaa !7
    builder.CreateAlignedStore(value124, value125, align4);

    // %126 = icmp eq i64 %47, 50
    Value *value126 = builder.CreateICmpEQ(value47, builder.getInt64(50));

    // br i1 %126, label %37, label %38
    builder.CreateCondBr(value126, bBlock37, bBlock38);


    // 127:
    builder.SetInsertPoint(bBlock127);

    // %128 = phi i64 [ %132, %131 ], [ 0, %37 ]
    PHINode *value128 = builder.CreatePHI(builder.getInt64Ty(), 2);

    // %129 = mul nuw nsw i64 %128, 50
    Value *value129 = builder.CreateMul(value128, builder.getInt64(50), "", true, true);

    // %130 = trunc i64 %128 to i32
    Value *value130 = builder.CreateTrunc(value128, builder.getInt32Ty());

    // br label %134
    builder.CreateBr(bBlock134);


    // 131:
    builder.SetInsertPoint(bBlock131);

    // %132 = add nuw nsw i64 %128, 1
    Value *value132 = builder.CreateAdd(value128, builder.getInt64(1), "", true, true);

    // %133 = icmp eq i64 %132, 50
    Value *value133 = builder.CreateICmpEQ(value132, builder.getInt64(50));

    // br i1 %133, label %23, label %127
    builder.CreateCondBr(value133, bBlock23, bBlock127);


    // 134:
    builder.SetInsertPoint(bBlock134);

    // %135 = phi i64 [ 0, %127 ], [ %167, %164 ]
    PHINode *value135 = builder.CreatePHI(builder.getInt64Ty(), 2);

    // %136 = add nuw nsw i64 %135, %129
    Value *value136 = builder.CreateAdd(value135, value129, "", true, true);

    // %137 = getelementptr inbounds [2500 x %struct.Cell], [2500 x %struct.Cell]* @updatePixels.swapCells, i64 0, i64 %136, i32 0
    Value *value137 = builder.CreateInBoundsGEP(swapCells, {builder.getInt64(0), value136, builder.getInt32(0)});

    // %138 = load i32, i32* %137, align 8, !tbaa !2
    Value *value138 = builder.CreateAlignedLoad(value137, align8);

    // %139 = getelementptr inbounds [2500 x %struct.Cell], [2500 x %struct.Cell]* %1, i64 0, i64 %136, i32 0
    Value *value139 = builder.CreateInBoundsGEP(value1, {builder.getInt64(0), value136, builder.getInt32(0)});

    // store i32 %138, i32* %139, align 8, !tbaa !2
    builder.CreateAlignedStore(value138, value139, align8);

    // %140 = getelementptr inbounds [2500 x %struct.Cell], [2500 x %struct.Cell]* @updatePixels.swapCells, i64 0, i64 %136, i32 1
    Value *value140 = builder.CreateInBoundsGEP(swapCells, {builder.getInt64(0), value136, builder.getInt32(1)});

    // %141 = load i32, i32* %140, align 4, !tbaa !7
    Value *value141 = builder.CreateAlignedLoad(value140, align4);

    // %142 = getelementptr inbounds [2500 x %struct.Cell], [2500 x %struct.Cell]* %1, i64 0, i64 %136, i32 1
    Value *value142 = builder.CreateInBoundsGEP(value1, {builder.getInt64(0), value136, builder.getInt32(1)});

    // store i32 %141, i32* %142, align 4, !tbaa !7
    builder.CreateAlignedStore(value141, value142, align4);

    // %143 = icmp eq i32 %141, 10
    Value *value143 = builder.CreateICmpEQ(value141, builder.getInt32(10));

    // br i1 %143, label %144, label %145
    builder.CreateCondBr(value143, bBlock144, bBlock145);


    // 144:
    builder.SetInsertPoint(bBlock144);

    // store i32 0, i32* %139, align 8, !tbaa !2
    builder.CreateAlignedStore(builder.getInt32(0), value139, align8);

    // store i32 0, i32* %142, align 4, !tbaa !7
    builder.CreateAlignedStore(builder.getInt32(0), value142, align4);

    // br label %164
    builder.CreateBr(bBlock164);


    // 145:
    builder.SetInsertPoint(bBlock145);

    // %146 = icmp eq i32 %138, 1
    Value *value146 = builder.CreateICmpEQ(value138, builder.getInt32(1));

    // br i1 %146, label %147, label %164
    builder.CreateCondBr(value146, bBlock147, bBlock164);


    // 147:
    builder.SetInsertPoint(bBlock147);
    
    // %148 = icmp sgt i32 %141, 6
    Value *value148 = builder.CreateICmpSGT(value141, builder.getInt32(6));

    // %149 = shl i32 %141, 17
    Value *value149 = builder.CreateShl(value141, builder.getInt32(17));

    // %150 = icmp slt i32 %141, 5
    Value *value150 = builder.CreateICmpSLT(value141, builder.getInt32(5));

    // br i1 %150, label %151, label %153
    builder.CreateCondBr(value150, bBlock151, bBlock153);


    // 151:
    builder.SetInsertPoint(bBlock151);

    // %152 = udiv i32 255, %141
    Value *value152 = builder.CreateUDiv(builder.getInt32(255), value141);

    // br label %153
    builder.CreateBr(bBlock153);


    // 153:
    builder.SetInsertPoint(bBlock153);

    // %154 = phi i32 [ %152, %151 ], [ 0, %147 ]
    PHINode *value154 = builder.CreatePHI(builder.getInt32Ty(), 2);

    // %155 = add i32 %141, -5
    Value *value155 = builder.CreateAdd(value141, builder.getInt32(-5));

    // %156 = icmp ult i32 %155, 2
    Value *value156 = builder.CreateICmpULT(value155, builder.getInt32(2));

    // %157 = select i1 %156, i32 127, i32 0
    Value *value157 = builder.CreateSelect(value156, builder.getInt32(127), builder.getInt32(0));

    // %158 = add i32 %149, 7012352
    Value *value158 = builder.CreateAdd(value149, builder.getInt32(7012352));

    // %159 = shl nuw nsw i32 %154, 8
    Value *value159 = builder.CreateShl(value154, builder.getInt32(8), "", true, true);

    // %160 = or i32 %158, -16777216
    Value *value160 = builder.CreateOr(value158, builder.getInt32(-16777216));

    // %161 = select i1 %148, i32 %160, i32 -16777216
    Value *value161 = builder.CreateSelect(value148, value160, builder.getInt32(-16777216));

    // %162 = or i32 %161, %157
    Value *value162 = builder.CreateOr(value161, value157);

    // %163 = or i32 %162, %159
    Value *value163 = builder.CreateOr(value162, value159);

    // br label %164
    builder.CreateBr(bBlock164);


    // 164:
    builder.SetInsertPoint(bBlock164);

    // %165 = phi i32 [ %163, %153 ], [ 0, %145 ], [ 0, %144 ]
    PHINode *value165 = builder.CreatePHI(builder.getInt32Ty(), 3);

    // %166 = trunc i64 %135 to i32
    Value *value166 = builder.CreateTrunc(value135, builder.getInt32Ty());

    // tail call fastcc void @paintCellPixels(i32 %166, i32 %130, i32 %165) #4
    Value *callPaintArgs1[3] = {value166, value130, value165};
    CallInst *callPaint1 = builder.CreateCall(paintCellPixelsFunc, callPaintArgs1);
    callPaint1->setTailCall(true);
    callPaint1->setCallingConv(CallingConv::Fast);

    // %167 = add nuw nsw i64 %135, 1
    Value *value167 = builder.CreateAdd(value135, builder.getInt64(1), "", true, true);

    // %168 = icmp eq i64 %167, 50
    Value *value168 = builder.CreateICmpEQ(value167, builder.getInt64(50));

    // br i1 %168, label %131, label %134
    builder.CreateCondBr(value168, bBlock131, bBlock134);


    /*
      Now resolve all PHI nodes
    */

    value4->addIncoming(builder.getInt64(0), bBlock0);
    value4->addIncoming(value8, bBlock7);

    value11->addIncoming(builder.getInt64(0), bBlock3);
    value11->addIncoming(value21, bBlock20);

    value25->addIncoming(builder.getInt64(0), bBlock23);
    value25->addIncoming(value30, bBlock37);

    value39->addIncoming(builder.getInt64(0), bBlock24);
    value39->addIncoming(value47, bBlock123);

    value40->addIncoming(builder.getInt32(0), bBlock24);
    value40->addIncoming(value48, bBlock123);

    value124->addIncoming(builder.getInt32(0), bBlock122);
    value124->addIncoming(builder.getInt32(1), bBlock121);
    value124->addIncoming(builder.getInt32(0), bBlock117);
    value124->addIncoming(value116, bBlock113);

    value128->addIncoming(value132, bBlock131);
    value128->addIncoming(builder.getInt64(0), bBlock37);

    value135->addIncoming(builder.getInt64(0), bBlock127);
    value135->addIncoming(value167, bBlock164);

    value154->addIncoming(value152, bBlock151);
    value154->addIncoming(builder.getInt32(0), bBlock147);

    value165->addIncoming(value163, bBlock153);
    value165->addIncoming(builder.getInt32(0), bBlock145);
    value165->addIncoming(builder.getInt32(0), bBlock144);

  }




  /*
    Actual IR for paintCellPixels() function
  */
  {
    // Declare all basic blocks in advance
    BasicBlock *bBlock0   = BasicBlock::Create(context, "", paintCellPixelsFunc);
    BasicBlock *bBlock10  = BasicBlock::Create(context, "", paintCellPixelsFunc);
    BasicBlock *bBlock26  = BasicBlock::Create(context, "", paintCellPixelsFunc);
    BasicBlock *bBlock28  = BasicBlock::Create(context, "", paintCellPixelsFunc);
    BasicBlock *bBlock29  = BasicBlock::Create(context, "", paintCellPixelsFunc);
    BasicBlock *bBlock30  = BasicBlock::Create(context, "", paintCellPixelsFunc);
    

    Value *value0 = paintCellPixelsFunc->getArg(0);
    Value *value1 = paintCellPixelsFunc->getArg(1);
    Value *value2 = paintCellPixelsFunc->getArg(2);

    // 0:
    builder.SetInsertPoint(bBlock0);

    // %4 = shl nsw i32 %0, 4
    Value *value4 = builder.CreateShl(value0, builder.getInt32(4), "", false, true);

    // %5 = or i32 %4, 1
    Value *value5 = builder.CreateOr(value4, builder.getInt32(1));

    // %6 = shl nsw i32 %1, 4
    Value *value6 = builder.CreateShl(value1, builder.getInt32(4), "", false, true);

    // %7 = or i32 %6, 1
    Value *value7 = builder.CreateOr(value6, builder.getInt32(1));

    // %8 = or i32 %6, 15
    Value *value8 = builder.CreateOr(value6, builder.getInt32(15));

    // %9 = icmp slt i32 %7, %8
    Value *value9 = builder.CreateICmpSLT(value7, value8);

    // br i1 %9, label %10, label %29
    builder.CreateCondBr(value9, bBlock10, bBlock29);


    // 10:
    builder.SetInsertPoint(bBlock10);

    // %11 = or i32 %4, 15
    Value *value11 = builder.CreateOr(value4, builder.getInt32(15));

    // %12 = icmp slt i32 %5, %11
    Value *value12 = builder.CreateICmpSLT(value5, value11);

    // %13 = add nuw nsw i32 %5, 1
    Value *value13 = builder.CreateAdd(value5, builder.getInt32(1), "", true, true);

    // %14 = or i32 %4, 3
    Value *value14 = builder.CreateOr(value4, builder.getInt32(3));

    // %15 = add nuw nsw i32 %14, 1
    Value *value15 = builder.CreateAdd(value14, builder.getInt32(1), "", true, true);

    // %16 = add nuw nsw i32 %14, 2
    Value *value16 = builder.CreateAdd(value14, builder.getInt32(2), "", true, true);

    // %17 = add nuw nsw i32 %14, 3
    Value *value17 = builder.CreateAdd(value14, builder.getInt32(3), "", true, true);

    // %18 = or i32 %4, 7
    Value *value18 = builder.CreateOr(value4, builder.getInt32(7));

    // %19 = add nuw nsw i32 %18, 1
    Value *value19 = builder.CreateAdd(value18, builder.getInt32(1), "", true, true);

    // %20 = add nuw nsw i32 %18, 2
    Value *value20 = builder.CreateAdd(value18, builder.getInt32(2), "", true, true);

    // %21 = add nuw nsw i32 %18, 3
    Value *value21 = builder.CreateAdd(value18, builder.getInt32(3), "", true, true);

    // %22 = add nuw nsw i32 %18, 4
    Value *value22 = builder.CreateAdd(value18, builder.getInt32(4), "", true, true);

    // %23 = add nuw nsw i32 %18, 5
    Value *value23 = builder.CreateAdd(value18, builder.getInt32(5), "", true, true);

    // %24 = add nuw nsw i32 %18, 6
    Value *value24 = builder.CreateAdd(value18, builder.getInt32(6), "", true, true);

    // %25 = add nuw nsw i32 %18, 7
    Value *value25 = builder.CreateAdd(value18, builder.getInt32(7), "", true, true);

    // br label %26
    builder.CreateBr(bBlock26);


    // 26:
    builder.SetInsertPoint(bBlock26);
    
    // %27 = phi i32 [ %7, %10 ], [ %31, %30 ]
    PHINode *value27 = builder.CreatePHI(builder.getInt32Ty(), 2);

    // br i1 %12, label %28, label %30
    builder.CreateCondBr(value12, bBlock28, bBlock30);


    // 28:
    builder.SetInsertPoint(bBlock28);

    Value *simPutPixelArgs[3];
    simPutPixelArgs[1] = value27;
    simPutPixelArgs[2] = value2;

    // tail call void @simPutPixel(i32 %5, i32 %27, i32 %2) #4
    simPutPixelArgs[0] = value5;
    CallInst *call5 = builder.CreateCall(simPutPixelFunc, simPutPixelArgs);
    call5->setTailCall(true);

    // tail call void @simPutPixel(i32 %13, i32 %27, i32 %2) #4
    simPutPixelArgs[0] = value13;
    CallInst *call13 = builder.CreateCall(simPutPixelFunc, simPutPixelArgs);
    call13->setTailCall(true);

    // tail call void @simPutPixel(i32 %14, i32 %27, i32 %2) #4
    simPutPixelArgs[0] = value14;
    CallInst *call14 = builder.CreateCall(simPutPixelFunc, simPutPixelArgs);
    call14->setTailCall(true);

    // tail call void @simPutPixel(i32 %15, i32 %27, i32 %2) #4
    simPutPixelArgs[0] = value15;
    CallInst *call15 = builder.CreateCall(simPutPixelFunc, simPutPixelArgs);
    call15->setTailCall(true);

    // tail call void @simPutPixel(i32 %16, i32 %27, i32 %2) #4
    simPutPixelArgs[0] = value16;
    CallInst *call16 = builder.CreateCall(simPutPixelFunc, simPutPixelArgs);
    call16->setTailCall(true);

    // tail call void @simPutPixel(i32 %17, i32 %27, i32 %2) #4
    simPutPixelArgs[0] = value17;
    CallInst *call17 = builder.CreateCall(simPutPixelFunc, simPutPixelArgs);
    call17->setTailCall(true);

    // tail call void @simPutPixel(i32 %18, i32 %27, i32 %2) #4
    simPutPixelArgs[0] = value18;
    CallInst *call18 = builder.CreateCall(simPutPixelFunc, simPutPixelArgs);
    call18->setTailCall(true);

    // tail call void @simPutPixel(i32 %19, i32 %27, i32 %2) #4
    simPutPixelArgs[0] = value19;
    CallInst *call19 = builder.CreateCall(simPutPixelFunc, simPutPixelArgs);
    call19->setTailCall(true);

    // tail call void @simPutPixel(i32 %20, i32 %27, i32 %2) #4
    simPutPixelArgs[0] = value20;
    CallInst *call20 = builder.CreateCall(simPutPixelFunc, simPutPixelArgs);
    call20->setTailCall(true);

    // tail call void @simPutPixel(i32 %21, i32 %27, i32 %2) #4
    simPutPixelArgs[0] = value21;
    CallInst *call21 = builder.CreateCall(simPutPixelFunc, simPutPixelArgs);
    call21->setTailCall(true);

    // tail call void @simPutPixel(i32 %22, i32 %27, i32 %2) #4
    simPutPixelArgs[0] = value22;
    CallInst *call22 = builder.CreateCall(simPutPixelFunc, simPutPixelArgs);
    call22->setTailCall(true);

    // tail call void @simPutPixel(i32 %23, i32 %27, i32 %2) #4
    simPutPixelArgs[0] = value23;
    CallInst *call23 = builder.CreateCall(simPutPixelFunc, simPutPixelArgs);
    call23->setTailCall(true);

    // tail call void @simPutPixel(i32 %24, i32 %27, i32 %2) #4
    simPutPixelArgs[0] = value24;
    CallInst *call24 = builder.CreateCall(simPutPixelFunc, simPutPixelArgs);
    call24->setTailCall(true);

    // tail call void @simPutPixel(i32 %25, i32 %27, i32 %2) #4
    simPutPixelArgs[0] = value25;
    CallInst *call25 = builder.CreateCall(simPutPixelFunc, simPutPixelArgs);
    call25->setTailCall(true);

    // br label %30
    builder.CreateBr(bBlock30);


    // 29:
    builder.SetInsertPoint(bBlock29);

    // ret void
    builder.CreateRetVoid();


    // 30:
    builder.SetInsertPoint(bBlock30);

    // %31 = add nuw i32 %27, 1
    Value *value31 = builder.CreateAdd(value27, builder.getInt32(1), "", true, false);

    // %32 = icmp eq i32 %31, %8
    Value *value32 = builder.CreateICmpEQ(value31, value8);

    // br i1 %32, label %29, label %26
    builder.CreateCondBr(value32, bBlock29, bBlock26);


    /*
      Now resolve all PHI nodes
    */

    value27->addIncoming(value7, bBlock10);
    value27->addIncoming(value31, bBlock30);

  }


  // Dump LLVM IR
  module->print(outs(), nullptr);

  
  // Interpreter of LLVM IR
  outs() << "Running code...\n";
  InitializeNativeTarget();
  InitializeNativeTargetAsmPrinter();

  ExecutionEngine *ee = EngineBuilder(std::unique_ptr<Module>(module)).create();
  ee->InstallLazyFunctionCreator([&](const std::string &fnName) -> void * {
			if (fnName == "simPutPixel") {
				return reinterpret_cast<void *>(simPutPixel);
			}
			if (fnName == "simFlush") {
				return reinterpret_cast<void *>(simFlush);
			}
			if (fnName == "simRand") {
				return reinterpret_cast<void *>(simRand);
			}
			return nullptr;
		});
  ee->finalizeObject();

  simInit();

  ArrayRef<GenericValue> noargs;
  GenericValue v = ee->runFunction(appFunc, noargs);
  outs() << "Code was run.\n";
  
  simExit();
  return 0;
}
