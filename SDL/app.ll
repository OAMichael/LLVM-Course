; ModuleID = '/home/michael/Desktop/MIPT/LLVM-Course/SDL/app.c'
source_filename = "/home/michael/Desktop/MIPT/LLVM-Course/SDL/app.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

%struct.Cell = type { i32, i32 }

@updatePixels.swapCells = internal global [2500 x %struct.Cell] zeroinitializer, align 16

; Function Attrs: noinline nounwind optnone uwtable
define dso_local void @app() #0 {
  %1 = alloca [2500 x %struct.Cell], align 16
  %2 = bitcast [2500 x %struct.Cell]* %1 to i8*
  call void @llvm.memset.p0i8.i64(i8* align 16 %2, i8 0, i64 20000, i1 false)
  %3 = getelementptr inbounds [2500 x %struct.Cell], [2500 x %struct.Cell]* %1, i64 0, i64 0
  call void @initCells(%struct.Cell* %3)
  call void (...) @simFlush()
  br label %4

4:                                                ; preds = %0, %4
  %5 = getelementptr inbounds [2500 x %struct.Cell], [2500 x %struct.Cell]* %1, i64 0, i64 0
  call void @updatePixels(%struct.Cell* %5)
  call void (...) @simFlush()
  br label %4
}

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.memset.p0i8.i64(i8* nocapture writeonly, i8, i64, i1 immarg) #1

; Function Attrs: noinline nounwind optnone uwtable
define internal void @initCells(%struct.Cell* %0) #0 {
  %2 = alloca %struct.Cell*, align 8
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  %5 = alloca i32, align 4
  %6 = alloca i32, align 4
  store %struct.Cell* %0, %struct.Cell** %2, align 8
  store i32 0, i32* %3, align 4
  br label %7

7:                                                ; preds = %45, %1
  %8 = load i32, i32* %3, align 4
  %9 = icmp slt i32 %8, 50
  br i1 %9, label %10, label %48

10:                                               ; preds = %7
  store i32 0, i32* %4, align 4
  br label %11

11:                                               ; preds = %41, %10
  %12 = load i32, i32* %4, align 4
  %13 = icmp slt i32 %12, 50
  br i1 %13, label %14, label %44

14:                                               ; preds = %11
  %15 = call i32 (...) @simRand()
  %16 = srem i32 %15, 31
  store i32 %16, i32* %5, align 4
  %17 = load i32, i32* %5, align 4
  %18 = icmp ne i32 %17, 0
  br i1 %18, label %40, label %19

19:                                               ; preds = %14
  %20 = load %struct.Cell*, %struct.Cell** %2, align 8
  %21 = load i32, i32* %4, align 4
  %22 = load i32, i32* %3, align 4
  %23 = mul nsw i32 %22, 50
  %24 = add nsw i32 %21, %23
  %25 = sext i32 %24 to i64
  %26 = getelementptr inbounds %struct.Cell, %struct.Cell* %20, i64 %25
  %27 = getelementptr inbounds %struct.Cell, %struct.Cell* %26, i32 0, i32 0
  store i32 1, i32* %27, align 4
  %28 = load %struct.Cell*, %struct.Cell** %2, align 8
  %29 = load i32, i32* %4, align 4
  %30 = load i32, i32* %3, align 4
  %31 = mul nsw i32 %30, 50
  %32 = add nsw i32 %29, %31
  %33 = sext i32 %32 to i64
  %34 = getelementptr inbounds %struct.Cell, %struct.Cell* %28, i64 %33
  %35 = getelementptr inbounds %struct.Cell, %struct.Cell* %34, i32 0, i32 1
  store i32 1, i32* %35, align 4
  %36 = call i32 @makeColor(i32 0, i32 255, i32 0)
  store i32 %36, i32* %6, align 4
  %37 = load i32, i32* %4, align 4
  %38 = load i32, i32* %3, align 4
  %39 = load i32, i32* %6, align 4
  call void @paintCellPixels(i32 %37, i32 %38, i32 %39)
  br label %40

40:                                               ; preds = %19, %14
  br label %41

41:                                               ; preds = %40
  %42 = load i32, i32* %4, align 4
  %43 = add nsw i32 %42, 1
  store i32 %43, i32* %4, align 4
  br label %11

44:                                               ; preds = %11
  br label %45

45:                                               ; preds = %44
  %46 = load i32, i32* %3, align 4
  %47 = add nsw i32 %46, 1
  store i32 %47, i32* %3, align 4
  br label %7

48:                                               ; preds = %7
  ret void
}

declare dso_local void @simFlush(...) #2

; Function Attrs: noinline nounwind optnone uwtable
define internal void @updatePixels(%struct.Cell* %0) #0 {
  %2 = alloca %struct.Cell*, align 8
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  %5 = alloca i32, align 4
  %6 = alloca i32, align 4
  %7 = alloca i32, align 4
  %8 = alloca i32, align 4
  %9 = alloca i32, align 4
  %10 = alloca i32, align 4
  %11 = alloca i32, align 4
  %12 = alloca [8 x i32], align 16
  %13 = alloca i32, align 4
  %14 = alloca i32, align 4
  %15 = alloca i32, align 4
  %16 = alloca i32, align 4
  %17 = alloca i32, align 4
  %18 = alloca i32, align 4
  %19 = alloca i32, align 4
  %20 = alloca i32, align 4
  %21 = alloca i32, align 4
  %22 = alloca i32, align 4
  store %struct.Cell* %0, %struct.Cell** %2, align 8
  store i32 0, i32* %3, align 4
  br label %23

23:                                               ; preds = %224, %1
  %24 = load i32, i32* %3, align 4
  %25 = icmp slt i32 %24, 50
  br i1 %25, label %26, label %227

26:                                               ; preds = %23
  store i32 0, i32* %4, align 4
  br label %27

27:                                               ; preds = %220, %26
  %28 = load i32, i32* %4, align 4
  %29 = icmp slt i32 %28, 50
  br i1 %29, label %30, label %223

30:                                               ; preds = %27
  %31 = load i32, i32* %4, align 4
  %32 = load i32, i32* %3, align 4
  %33 = mul nsw i32 %32, 50
  %34 = add nsw i32 %31, %33
  store i32 %34, i32* %5, align 4
  %35 = load i32, i32* %4, align 4
  %36 = sub nsw i32 %35, 1
  %37 = add nsw i32 %36, 50
  %38 = srem i32 %37, 50
  store i32 %38, i32* %6, align 4
  %39 = load i32, i32* %4, align 4
  %40 = add nsw i32 %39, 0
  %41 = srem i32 %40, 50
  store i32 %41, i32* %7, align 4
  %42 = load i32, i32* %4, align 4
  %43 = add nsw i32 %42, 1
  %44 = srem i32 %43, 50
  store i32 %44, i32* %8, align 4
  %45 = load i32, i32* %3, align 4
  %46 = sub nsw i32 %45, 1
  %47 = add nsw i32 %46, 50
  %48 = srem i32 %47, 50
  store i32 %48, i32* %9, align 4
  %49 = load i32, i32* %3, align 4
  %50 = add nsw i32 %49, 0
  %51 = srem i32 %50, 50
  store i32 %51, i32* %10, align 4
  %52 = load i32, i32* %3, align 4
  %53 = add nsw i32 %52, 1
  %54 = srem i32 %53, 50
  store i32 %54, i32* %11, align 4
  %55 = getelementptr inbounds [8 x i32], [8 x i32]* %12, i64 0, i64 0
  %56 = load %struct.Cell*, %struct.Cell** %2, align 8
  %57 = load i32, i32* %6, align 4
  %58 = load i32, i32* %9, align 4
  %59 = mul nsw i32 %58, 50
  %60 = add nsw i32 %57, %59
  %61 = sext i32 %60 to i64
  %62 = getelementptr inbounds %struct.Cell, %struct.Cell* %56, i64 %61
  %63 = getelementptr inbounds %struct.Cell, %struct.Cell* %62, i32 0, i32 0
  %64 = load i32, i32* %63, align 4
  store i32 %64, i32* %55, align 4
  %65 = getelementptr inbounds i32, i32* %55, i64 1
  %66 = load %struct.Cell*, %struct.Cell** %2, align 8
  %67 = load i32, i32* %6, align 4
  %68 = load i32, i32* %10, align 4
  %69 = mul nsw i32 %68, 50
  %70 = add nsw i32 %67, %69
  %71 = sext i32 %70 to i64
  %72 = getelementptr inbounds %struct.Cell, %struct.Cell* %66, i64 %71
  %73 = getelementptr inbounds %struct.Cell, %struct.Cell* %72, i32 0, i32 0
  %74 = load i32, i32* %73, align 4
  store i32 %74, i32* %65, align 4
  %75 = getelementptr inbounds i32, i32* %65, i64 1
  %76 = load %struct.Cell*, %struct.Cell** %2, align 8
  %77 = load i32, i32* %6, align 4
  %78 = load i32, i32* %11, align 4
  %79 = mul nsw i32 %78, 50
  %80 = add nsw i32 %77, %79
  %81 = sext i32 %80 to i64
  %82 = getelementptr inbounds %struct.Cell, %struct.Cell* %76, i64 %81
  %83 = getelementptr inbounds %struct.Cell, %struct.Cell* %82, i32 0, i32 0
  %84 = load i32, i32* %83, align 4
  store i32 %84, i32* %75, align 4
  %85 = getelementptr inbounds i32, i32* %75, i64 1
  %86 = load %struct.Cell*, %struct.Cell** %2, align 8
  %87 = load i32, i32* %7, align 4
  %88 = load i32, i32* %9, align 4
  %89 = mul nsw i32 %88, 50
  %90 = add nsw i32 %87, %89
  %91 = sext i32 %90 to i64
  %92 = getelementptr inbounds %struct.Cell, %struct.Cell* %86, i64 %91
  %93 = getelementptr inbounds %struct.Cell, %struct.Cell* %92, i32 0, i32 0
  %94 = load i32, i32* %93, align 4
  store i32 %94, i32* %85, align 4
  %95 = getelementptr inbounds i32, i32* %85, i64 1
  %96 = load %struct.Cell*, %struct.Cell** %2, align 8
  %97 = load i32, i32* %7, align 4
  %98 = load i32, i32* %11, align 4
  %99 = mul nsw i32 %98, 50
  %100 = add nsw i32 %97, %99
  %101 = sext i32 %100 to i64
  %102 = getelementptr inbounds %struct.Cell, %struct.Cell* %96, i64 %101
  %103 = getelementptr inbounds %struct.Cell, %struct.Cell* %102, i32 0, i32 0
  %104 = load i32, i32* %103, align 4
  store i32 %104, i32* %95, align 4
  %105 = getelementptr inbounds i32, i32* %95, i64 1
  %106 = load %struct.Cell*, %struct.Cell** %2, align 8
  %107 = load i32, i32* %8, align 4
  %108 = load i32, i32* %9, align 4
  %109 = mul nsw i32 %108, 50
  %110 = add nsw i32 %107, %109
  %111 = sext i32 %110 to i64
  %112 = getelementptr inbounds %struct.Cell, %struct.Cell* %106, i64 %111
  %113 = getelementptr inbounds %struct.Cell, %struct.Cell* %112, i32 0, i32 0
  %114 = load i32, i32* %113, align 4
  store i32 %114, i32* %105, align 4
  %115 = getelementptr inbounds i32, i32* %105, i64 1
  %116 = load %struct.Cell*, %struct.Cell** %2, align 8
  %117 = load i32, i32* %8, align 4
  %118 = load i32, i32* %10, align 4
  %119 = mul nsw i32 %118, 50
  %120 = add nsw i32 %117, %119
  %121 = sext i32 %120 to i64
  %122 = getelementptr inbounds %struct.Cell, %struct.Cell* %116, i64 %121
  %123 = getelementptr inbounds %struct.Cell, %struct.Cell* %122, i32 0, i32 0
  %124 = load i32, i32* %123, align 4
  store i32 %124, i32* %115, align 4
  %125 = getelementptr inbounds i32, i32* %115, i64 1
  %126 = load %struct.Cell*, %struct.Cell** %2, align 8
  %127 = load i32, i32* %8, align 4
  %128 = load i32, i32* %11, align 4
  %129 = mul nsw i32 %128, 50
  %130 = add nsw i32 %127, %129
  %131 = sext i32 %130 to i64
  %132 = getelementptr inbounds %struct.Cell, %struct.Cell* %126, i64 %131
  %133 = getelementptr inbounds %struct.Cell, %struct.Cell* %132, i32 0, i32 0
  %134 = load i32, i32* %133, align 4
  store i32 %134, i32* %125, align 4
  store i32 0, i32* %13, align 4
  store i32 0, i32* %14, align 4
  br label %135

135:                                              ; preds = %148, %30
  %136 = load i32, i32* %14, align 4
  %137 = icmp slt i32 %136, 8
  br i1 %137, label %138, label %151

138:                                              ; preds = %135
  %139 = load i32, i32* %14, align 4
  %140 = sext i32 %139 to i64
  %141 = getelementptr inbounds [8 x i32], [8 x i32]* %12, i64 0, i64 %140
  %142 = load i32, i32* %141, align 4
  %143 = icmp eq i32 %142, 1
  br i1 %143, label %144, label %147

144:                                              ; preds = %138
  %145 = load i32, i32* %13, align 4
  %146 = add nsw i32 %145, 1
  store i32 %146, i32* %13, align 4
  br label %147

147:                                              ; preds = %144, %138
  br label %148

148:                                              ; preds = %147
  %149 = load i32, i32* %14, align 4
  %150 = add nsw i32 %149, 1
  store i32 %150, i32* %14, align 4
  br label %135

151:                                              ; preds = %135
  %152 = load %struct.Cell*, %struct.Cell** %2, align 8
  %153 = load i32, i32* %5, align 4
  %154 = sext i32 %153 to i64
  %155 = getelementptr inbounds %struct.Cell, %struct.Cell* %152, i64 %154
  %156 = getelementptr inbounds %struct.Cell, %struct.Cell* %155, i32 0, i32 0
  %157 = load i32, i32* %156, align 4
  %158 = icmp eq i32 %157, 1
  br i1 %158, label %159, label %197

159:                                              ; preds = %151
  %160 = load i32, i32* %13, align 4
  %161 = icmp eq i32 %160, 0
  br i1 %161, label %171, label %162

162:                                              ; preds = %159
  %163 = load i32, i32* %13, align 4
  %164 = icmp eq i32 %163, 3
  br i1 %164, label %171, label %165

165:                                              ; preds = %162
  %166 = load i32, i32* %13, align 4
  %167 = icmp eq i32 %166, 4
  br i1 %167, label %171, label %168

168:                                              ; preds = %165
  %169 = load i32, i32* %13, align 4
  %170 = icmp eq i32 %169, 5
  br i1 %170, label %171, label %187

171:                                              ; preds = %168, %165, %162, %159
  %172 = load i32, i32* %5, align 4
  %173 = sext i32 %172 to i64
  %174 = getelementptr inbounds [2500 x %struct.Cell], [2500 x %struct.Cell]* @updatePixels.swapCells, i64 0, i64 %173
  %175 = getelementptr inbounds %struct.Cell, %struct.Cell* %174, i32 0, i32 0
  store i32 1, i32* %175, align 8
  %176 = load %struct.Cell*, %struct.Cell** %2, align 8
  %177 = load i32, i32* %5, align 4
  %178 = sext i32 %177 to i64
  %179 = getelementptr inbounds %struct.Cell, %struct.Cell* %176, i64 %178
  %180 = getelementptr inbounds %struct.Cell, %struct.Cell* %179, i32 0, i32 1
  %181 = load i32, i32* %180, align 4
  %182 = add i32 %181, 1
  %183 = load i32, i32* %5, align 4
  %184 = sext i32 %183 to i64
  %185 = getelementptr inbounds [2500 x %struct.Cell], [2500 x %struct.Cell]* @updatePixels.swapCells, i64 0, i64 %184
  %186 = getelementptr inbounds %struct.Cell, %struct.Cell* %185, i32 0, i32 1
  store i32 %182, i32* %186, align 4
  br label %196

187:                                              ; preds = %168
  %188 = load i32, i32* %5, align 4
  %189 = sext i32 %188 to i64
  %190 = getelementptr inbounds [2500 x %struct.Cell], [2500 x %struct.Cell]* @updatePixels.swapCells, i64 0, i64 %189
  %191 = getelementptr inbounds %struct.Cell, %struct.Cell* %190, i32 0, i32 0
  store i32 0, i32* %191, align 8
  %192 = load i32, i32* %5, align 4
  %193 = sext i32 %192 to i64
  %194 = getelementptr inbounds [2500 x %struct.Cell], [2500 x %struct.Cell]* @updatePixels.swapCells, i64 0, i64 %193
  %195 = getelementptr inbounds %struct.Cell, %struct.Cell* %194, i32 0, i32 1
  store i32 0, i32* %195, align 4
  br label %196

196:                                              ; preds = %187, %171
  br label %219

197:                                              ; preds = %151
  %198 = load i32, i32* %13, align 4
  %199 = icmp eq i32 %198, 2
  br i1 %199, label %200, label %209

200:                                              ; preds = %197
  %201 = load i32, i32* %5, align 4
  %202 = sext i32 %201 to i64
  %203 = getelementptr inbounds [2500 x %struct.Cell], [2500 x %struct.Cell]* @updatePixels.swapCells, i64 0, i64 %202
  %204 = getelementptr inbounds %struct.Cell, %struct.Cell* %203, i32 0, i32 0
  store i32 1, i32* %204, align 8
  %205 = load i32, i32* %5, align 4
  %206 = sext i32 %205 to i64
  %207 = getelementptr inbounds [2500 x %struct.Cell], [2500 x %struct.Cell]* @updatePixels.swapCells, i64 0, i64 %206
  %208 = getelementptr inbounds %struct.Cell, %struct.Cell* %207, i32 0, i32 1
  store i32 1, i32* %208, align 4
  br label %218

209:                                              ; preds = %197
  %210 = load i32, i32* %5, align 4
  %211 = sext i32 %210 to i64
  %212 = getelementptr inbounds [2500 x %struct.Cell], [2500 x %struct.Cell]* @updatePixels.swapCells, i64 0, i64 %211
  %213 = getelementptr inbounds %struct.Cell, %struct.Cell* %212, i32 0, i32 0
  store i32 0, i32* %213, align 8
  %214 = load i32, i32* %5, align 4
  %215 = sext i32 %214 to i64
  %216 = getelementptr inbounds [2500 x %struct.Cell], [2500 x %struct.Cell]* @updatePixels.swapCells, i64 0, i64 %215
  %217 = getelementptr inbounds %struct.Cell, %struct.Cell* %216, i32 0, i32 1
  store i32 0, i32* %217, align 4
  br label %218

218:                                              ; preds = %209, %200
  br label %219

219:                                              ; preds = %218, %196
  br label %220

220:                                              ; preds = %219
  %221 = load i32, i32* %4, align 4
  %222 = add nsw i32 %221, 1
  store i32 %222, i32* %4, align 4
  br label %27

223:                                              ; preds = %27
  br label %224

224:                                              ; preds = %223
  %225 = load i32, i32* %3, align 4
  %226 = add nsw i32 %225, 1
  store i32 %226, i32* %3, align 4
  br label %23

227:                                              ; preds = %23
  store i32 0, i32* %15, align 4
  br label %228

228:                                              ; preds = %331, %227
  %229 = load i32, i32* %15, align 4
  %230 = icmp slt i32 %229, 50
  br i1 %230, label %231, label %334

231:                                              ; preds = %228
  store i32 0, i32* %16, align 4
  br label %232

232:                                              ; preds = %327, %231
  %233 = load i32, i32* %16, align 4
  %234 = icmp slt i32 %233, 50
  br i1 %234, label %235, label %330

235:                                              ; preds = %232
  %236 = load i32, i32* %16, align 4
  %237 = load i32, i32* %15, align 4
  %238 = mul nsw i32 %237, 50
  %239 = add nsw i32 %236, %238
  store i32 %239, i32* %17, align 4
  %240 = load i32, i32* %17, align 4
  %241 = sext i32 %240 to i64
  %242 = getelementptr inbounds [2500 x %struct.Cell], [2500 x %struct.Cell]* @updatePixels.swapCells, i64 0, i64 %241
  %243 = getelementptr inbounds %struct.Cell, %struct.Cell* %242, i32 0, i32 0
  %244 = load i32, i32* %243, align 8
  %245 = load %struct.Cell*, %struct.Cell** %2, align 8
  %246 = load i32, i32* %17, align 4
  %247 = sext i32 %246 to i64
  %248 = getelementptr inbounds %struct.Cell, %struct.Cell* %245, i64 %247
  %249 = getelementptr inbounds %struct.Cell, %struct.Cell* %248, i32 0, i32 0
  store i32 %244, i32* %249, align 4
  %250 = load i32, i32* %17, align 4
  %251 = sext i32 %250 to i64
  %252 = getelementptr inbounds [2500 x %struct.Cell], [2500 x %struct.Cell]* @updatePixels.swapCells, i64 0, i64 %251
  %253 = getelementptr inbounds %struct.Cell, %struct.Cell* %252, i32 0, i32 1
  %254 = load i32, i32* %253, align 4
  %255 = load %struct.Cell*, %struct.Cell** %2, align 8
  %256 = load i32, i32* %17, align 4
  %257 = sext i32 %256 to i64
  %258 = getelementptr inbounds %struct.Cell, %struct.Cell* %255, i64 %257
  %259 = getelementptr inbounds %struct.Cell, %struct.Cell* %258, i32 0, i32 1
  store i32 %254, i32* %259, align 4
  store i32 0, i32* %18, align 4
  %260 = load %struct.Cell*, %struct.Cell** %2, align 8
  %261 = load i32, i32* %17, align 4
  %262 = sext i32 %261 to i64
  %263 = getelementptr inbounds %struct.Cell, %struct.Cell* %260, i64 %262
  %264 = getelementptr inbounds %struct.Cell, %struct.Cell* %263, i32 0, i32 1
  %265 = load i32, i32* %264, align 4
  %266 = icmp eq i32 %265, 10
  br i1 %266, label %267, label %278

267:                                              ; preds = %235
  %268 = load %struct.Cell*, %struct.Cell** %2, align 8
  %269 = load i32, i32* %17, align 4
  %270 = sext i32 %269 to i64
  %271 = getelementptr inbounds %struct.Cell, %struct.Cell* %268, i64 %270
  %272 = getelementptr inbounds %struct.Cell, %struct.Cell* %271, i32 0, i32 0
  store i32 0, i32* %272, align 4
  %273 = load %struct.Cell*, %struct.Cell** %2, align 8
  %274 = load i32, i32* %17, align 4
  %275 = sext i32 %274 to i64
  %276 = getelementptr inbounds %struct.Cell, %struct.Cell* %273, i64 %275
  %277 = getelementptr inbounds %struct.Cell, %struct.Cell* %276, i32 0, i32 1
  store i32 0, i32* %277, align 4
  br label %278

278:                                              ; preds = %267, %235
  %279 = load %struct.Cell*, %struct.Cell** %2, align 8
  %280 = load i32, i32* %17, align 4
  %281 = sext i32 %280 to i64
  %282 = getelementptr inbounds %struct.Cell, %struct.Cell* %279, i64 %281
  %283 = getelementptr inbounds %struct.Cell, %struct.Cell* %282, i32 0, i32 0
  %284 = load i32, i32* %283, align 4
  %285 = icmp eq i32 %284, 1
  br i1 %285, label %286, label %323

286:                                              ; preds = %278
  %287 = load %struct.Cell*, %struct.Cell** %2, align 8
  %288 = load i32, i32* %17, align 4
  %289 = sext i32 %288 to i64
  %290 = getelementptr inbounds %struct.Cell, %struct.Cell* %287, i64 %289
  %291 = getelementptr inbounds %struct.Cell, %struct.Cell* %290, i32 0, i32 1
  %292 = load i32, i32* %291, align 4
  store i32 %292, i32* %19, align 4
  store i32 0, i32* %20, align 4
  store i32 0, i32* %21, align 4
  store i32 0, i32* %22, align 4
  %293 = load i32, i32* %19, align 4
  %294 = icmp sgt i32 %293, 6
  br i1 %294, label %295, label %300

295:                                              ; preds = %286
  %296 = load i32, i32* %19, align 4
  %297 = sub nsw i32 10, %296
  %298 = mul nsw i32 2, %297
  %299 = sub nsw i32 127, %298
  store i32 %299, i32* %20, align 4
  br label %300

300:                                              ; preds = %295, %286
  %301 = load i32, i32* %19, align 4
  %302 = icmp slt i32 %301, 5
  br i1 %302, label %303, label %311

303:                                              ; preds = %300
  %304 = load %struct.Cell*, %struct.Cell** %2, align 8
  %305 = load i32, i32* %17, align 4
  %306 = sext i32 %305 to i64
  %307 = getelementptr inbounds %struct.Cell, %struct.Cell* %304, i64 %306
  %308 = getelementptr inbounds %struct.Cell, %struct.Cell* %307, i32 0, i32 1
  %309 = load i32, i32* %308, align 4
  %310 = udiv i32 255, %309
  store i32 %310, i32* %21, align 4
  br label %311

311:                                              ; preds = %303, %300
  %312 = load i32, i32* %19, align 4
  %313 = icmp sge i32 %312, 5
  br i1 %313, label %314, label %318

314:                                              ; preds = %311
  %315 = load i32, i32* %19, align 4
  %316 = icmp sle i32 %315, 6
  br i1 %316, label %317, label %318

317:                                              ; preds = %314
  store i32 127, i32* %22, align 4
  br label %318

318:                                              ; preds = %317, %314, %311
  %319 = load i32, i32* %20, align 4
  %320 = load i32, i32* %21, align 4
  %321 = load i32, i32* %22, align 4
  %322 = call i32 @makeColor(i32 %319, i32 %320, i32 %321)
  store i32 %322, i32* %18, align 4
  br label %323

323:                                              ; preds = %318, %278
  %324 = load i32, i32* %16, align 4
  %325 = load i32, i32* %15, align 4
  %326 = load i32, i32* %18, align 4
  call void @paintCellPixels(i32 %324, i32 %325, i32 %326)
  br label %327

327:                                              ; preds = %323
  %328 = load i32, i32* %16, align 4
  %329 = add nsw i32 %328, 1
  store i32 %329, i32* %16, align 4
  br label %232

330:                                              ; preds = %232
  br label %331

331:                                              ; preds = %330
  %332 = load i32, i32* %15, align 4
  %333 = add nsw i32 %332, 1
  store i32 %333, i32* %15, align 4
  br label %228

334:                                              ; preds = %228
  ret void
}

declare dso_local i32 @simRand(...) #2

; Function Attrs: noinline nounwind optnone uwtable
define internal i32 @makeColor(i32 %0, i32 %1, i32 %2) #0 {
  %4 = alloca i32, align 4
  %5 = alloca i32, align 4
  %6 = alloca i32, align 4
  %7 = alloca i32, align 4
  %8 = alloca i32, align 4
  store i32 %0, i32* %4, align 4
  store i32 %1, i32* %5, align 4
  store i32 %2, i32* %6, align 4
  store i32 255, i32* %7, align 4
  %9 = load i32, i32* %4, align 4
  %10 = and i32 %9, 255
  %11 = shl i32 %10, 16
  %12 = or i32 -16777216, %11
  %13 = load i32, i32* %5, align 4
  %14 = and i32 %13, 255
  %15 = shl i32 %14, 8
  %16 = or i32 %12, %15
  %17 = load i32, i32* %6, align 4
  %18 = and i32 %17, 255
  %19 = shl i32 %18, 0
  %20 = or i32 %16, %19
  store i32 %20, i32* %8, align 4
  %21 = load i32, i32* %8, align 4
  ret i32 %21
}

; Function Attrs: noinline nounwind optnone uwtable
define internal void @paintCellPixels(i32 %0, i32 %1, i32 %2) #0 {
  %4 = alloca i32, align 4
  %5 = alloca i32, align 4
  %6 = alloca i32, align 4
  %7 = alloca i32, align 4
  %8 = alloca i32, align 4
  %9 = alloca i32, align 4
  %10 = alloca i32, align 4
  %11 = alloca i32, align 4
  %12 = alloca i32, align 4
  store i32 %0, i32* %4, align 4
  store i32 %1, i32* %5, align 4
  store i32 %2, i32* %6, align 4
  %13 = load i32, i32* %4, align 4
  %14 = mul nsw i32 %13, 16
  %15 = add nsw i32 %14, 1
  store i32 %15, i32* %7, align 4
  %16 = load i32, i32* %5, align 4
  %17 = mul nsw i32 %16, 16
  %18 = add nsw i32 %17, 1
  store i32 %18, i32* %8, align 4
  %19 = load i32, i32* %4, align 4
  %20 = mul nsw i32 %19, 16
  %21 = add nsw i32 %20, 16
  %22 = sub nsw i32 %21, 1
  store i32 %22, i32* %9, align 4
  %23 = load i32, i32* %5, align 4
  %24 = mul nsw i32 %23, 16
  %25 = add nsw i32 %24, 16
  %26 = sub nsw i32 %25, 1
  store i32 %26, i32* %10, align 4
  %27 = load i32, i32* %8, align 4
  store i32 %27, i32* %11, align 4
  br label %28

28:                                               ; preds = %46, %3
  %29 = load i32, i32* %11, align 4
  %30 = load i32, i32* %10, align 4
  %31 = icmp slt i32 %29, %30
  br i1 %31, label %32, label %49

32:                                               ; preds = %28
  %33 = load i32, i32* %7, align 4
  store i32 %33, i32* %12, align 4
  br label %34

34:                                               ; preds = %42, %32
  %35 = load i32, i32* %12, align 4
  %36 = load i32, i32* %9, align 4
  %37 = icmp slt i32 %35, %36
  br i1 %37, label %38, label %45

38:                                               ; preds = %34
  %39 = load i32, i32* %12, align 4
  %40 = load i32, i32* %11, align 4
  %41 = load i32, i32* %6, align 4
  call void @simPutPixel(i32 %39, i32 %40, i32 %41)
  br label %42

42:                                               ; preds = %38
  %43 = load i32, i32* %12, align 4
  %44 = add nsw i32 %43, 1
  store i32 %44, i32* %12, align 4
  br label %34

45:                                               ; preds = %34
  br label %46

46:                                               ; preds = %45
  %47 = load i32, i32* %11, align 4
  %48 = add nsw i32 %47, 1
  store i32 %48, i32* %11, align 4
  br label %28

49:                                               ; preds = %28
  ret void
}

declare dso_local void @simPutPixel(i32, i32, i32) #2

attributes #0 = { noinline nounwind optnone uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { argmemonly nounwind willreturn }
attributes #2 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 10.0.0-4ubuntu1 "}
