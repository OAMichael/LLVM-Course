; ModuleID = '/home/michael/Desktop/MIPT/LLVM-Course/SDL/app.c'
source_filename = "/home/michael/Desktop/MIPT/LLVM-Course/SDL/app.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

%struct.Cell = type { i32, i32 }

@updatePixels.swapCells = internal unnamed_addr global [2500 x %struct.Cell] zeroinitializer, align 16

; Function Attrs: noreturn nounwind uwtable
define dso_local void @app() local_unnamed_addr #0 {
  %1 = alloca [2500 x %struct.Cell], align 16
  %2 = bitcast [2500 x %struct.Cell]* %1 to i8*
  call void @llvm.lifetime.start.p0i8(i64 20000, i8* nonnull %2) #4
  call void @llvm.memset.p0i8.i64(i8* nonnull align 16 dereferenceable(20000) %2, i8 0, i64 20000, i1 false)
  br label %3

3:                                                ; preds = %7, %0
  %4 = phi i64 [ 0, %0 ], [ %8, %7 ]
  %5 = mul nuw nsw i64 %4, 50
  %6 = trunc i64 %4 to i32
  br label %10

7:                                                ; preds = %20
  %8 = add nuw nsw i64 %4, 1
  %9 = icmp eq i64 %8, 50
  br i1 %9, label %23, label %3

10:                                               ; preds = %20, %3
  %11 = phi i64 [ 0, %3 ], [ %21, %20 ]
  %12 = tail call i32 (...) @simRand() #4
  %13 = srem i32 %12, 31
  %14 = icmp eq i32 %13, 0
  br i1 %14, label %15, label %20

15:                                               ; preds = %10
  %16 = add nuw nsw i64 %11, %5
  %17 = getelementptr inbounds [2500 x %struct.Cell], [2500 x %struct.Cell]* %1, i64 0, i64 %16, i32 0
  store i32 1, i32* %17, align 8, !tbaa !2
  %18 = getelementptr inbounds [2500 x %struct.Cell], [2500 x %struct.Cell]* %1, i64 0, i64 %16, i32 1
  store i32 1, i32* %18, align 4, !tbaa !7
  %19 = trunc i64 %11 to i32
  tail call fastcc void @paintCellPixels(i32 %19, i32 %6, i32 -16711936) #4
  br label %20

20:                                               ; preds = %15, %10
  %21 = add nuw nsw i64 %11, 1
  %22 = icmp eq i64 %21, 50
  br i1 %22, label %7, label %10

23:                                               ; preds = %131, %7
  tail call void (...) @simFlush() #4
  br label %24

24:                                               ; preds = %37, %23
  %25 = phi i64 [ 0, %23 ], [ %30, %37 ]
  %26 = mul nuw nsw i64 %25, 50
  %27 = trunc i64 %25 to i32
  %28 = add i32 %27, 49
  %29 = urem i32 %28, 50
  %30 = add nuw nsw i64 %25, 1
  %31 = icmp eq i64 %30, 50
  %32 = trunc i64 %30 to i32
  %33 = mul nuw nsw i32 %29, 50
  %34 = mul i32 %32, 50
  %35 = select i1 %31, i32 0, i32 %34
  %36 = trunc i64 %26 to i32
  br label %38

37:                                               ; preds = %123
  br i1 %31, label %127, label %24

38:                                               ; preds = %123, %24
  %39 = phi i64 [ 0, %24 ], [ %47, %123 ]
  %40 = phi i32 [ 0, %24 ], [ %48, %123 ]
  %41 = trunc i32 %40 to i8
  %42 = add i8 %41, 49
  %43 = urem i8 %42, 50
  %44 = zext i8 %43 to i32
  %45 = urem i8 %41, 50
  %46 = zext i8 %45 to i32
  %47 = add nuw nsw i64 %39, 1
  %48 = add nuw nsw i32 %40, 1
  %49 = trunc i64 %47 to i8
  %50 = urem i8 %49, 50
  %51 = zext i8 %50 to i32
  %52 = add nuw nsw i32 %33, %44
  %53 = zext i32 %52 to i64
  %54 = getelementptr inbounds [2500 x %struct.Cell], [2500 x %struct.Cell]* %1, i64 0, i64 %53, i32 0
  %55 = load i32, i32* %54, align 8, !tbaa !8
  %56 = add nuw nsw i32 %44, %36
  %57 = zext i32 %56 to i64
  %58 = getelementptr inbounds [2500 x %struct.Cell], [2500 x %struct.Cell]* %1, i64 0, i64 %57, i32 0
  %59 = load i32, i32* %58, align 8, !tbaa !8
  %60 = add nuw nsw i32 %35, %44
  %61 = zext i32 %60 to i64
  %62 = getelementptr inbounds [2500 x %struct.Cell], [2500 x %struct.Cell]* %1, i64 0, i64 %61, i32 0
  %63 = load i32, i32* %62, align 8, !tbaa !8
  %64 = add nuw nsw i32 %33, %46
  %65 = zext i32 %64 to i64
  %66 = getelementptr inbounds [2500 x %struct.Cell], [2500 x %struct.Cell]* %1, i64 0, i64 %65, i32 0
  %67 = load i32, i32* %66, align 8, !tbaa !8
  %68 = add nuw nsw i32 %35, %46
  %69 = zext i32 %68 to i64
  %70 = getelementptr inbounds [2500 x %struct.Cell], [2500 x %struct.Cell]* %1, i64 0, i64 %69, i32 0
  %71 = load i32, i32* %70, align 8, !tbaa !8
  %72 = add nuw nsw i32 %33, %51
  %73 = zext i32 %72 to i64
  %74 = getelementptr inbounds [2500 x %struct.Cell], [2500 x %struct.Cell]* %1, i64 0, i64 %73, i32 0
  %75 = load i32, i32* %74, align 8, !tbaa !8
  %76 = add nuw nsw i32 %51, %36
  %77 = zext i32 %76 to i64
  %78 = getelementptr inbounds [2500 x %struct.Cell], [2500 x %struct.Cell]* %1, i64 0, i64 %77, i32 0
  %79 = load i32, i32* %78, align 8, !tbaa !8
  %80 = add nuw nsw i32 %35, %51
  %81 = zext i32 %80 to i64
  %82 = getelementptr inbounds [2500 x %struct.Cell], [2500 x %struct.Cell]* %1, i64 0, i64 %81, i32 0
  %83 = load i32, i32* %82, align 8, !tbaa !8
  %84 = icmp eq i32 %55, 1
  %85 = zext i1 %84 to i32
  %86 = icmp eq i32 %59, 1
  %87 = zext i1 %86 to i32
  %88 = add nuw nsw i32 %87, %85
  %89 = icmp eq i32 %63, 1
  %90 = zext i1 %89 to i32
  %91 = add nuw nsw i32 %88, %90
  %92 = icmp eq i32 %67, 1
  %93 = zext i1 %92 to i32
  %94 = add nuw nsw i32 %91, %93
  %95 = icmp eq i32 %71, 1
  %96 = zext i1 %95 to i32
  %97 = add nuw nsw i32 %94, %96
  %98 = icmp eq i32 %75, 1
  %99 = zext i1 %98 to i32
  %100 = add nuw nsw i32 %97, %99
  %101 = icmp eq i32 %79, 1
  %102 = zext i1 %101 to i32
  %103 = add nuw nsw i32 %100, %102
  %104 = icmp eq i32 %83, 1
  %105 = zext i1 %104 to i32
  %106 = add nuw nsw i32 %103, %105
  %107 = add nuw nsw i64 %39, %26
  %108 = getelementptr inbounds [2500 x %struct.Cell], [2500 x %struct.Cell]* %1, i64 0, i64 %107, i32 0
  %109 = load i32, i32* %108, align 8, !tbaa !2
  %110 = icmp eq i32 %109, 1
  br i1 %110, label %111, label %118

111:                                              ; preds = %38
  %112 = getelementptr inbounds [2500 x %struct.Cell], [2500 x %struct.Cell]* @updatePixels.swapCells, i64 0, i64 %107, i32 0
  switch i32 %106, label %117 [
    i32 5, label %113
    i32 4, label %113
    i32 3, label %113
    i32 0, label %113
  ]

113:                                              ; preds = %111, %111, %111, %111
  store i32 1, i32* %112, align 8, !tbaa !2
  %114 = getelementptr inbounds [2500 x %struct.Cell], [2500 x %struct.Cell]* %1, i64 0, i64 %107, i32 1
  %115 = load i32, i32* %114, align 4, !tbaa !7
  %116 = add i32 %115, 1
  br label %123

117:                                              ; preds = %111
  store i32 0, i32* %112, align 8, !tbaa !2
  br label %123

118:                                              ; preds = %38
  %119 = icmp eq i32 %106, 2
  %120 = getelementptr inbounds [2500 x %struct.Cell], [2500 x %struct.Cell]* @updatePixels.swapCells, i64 0, i64 %107, i32 0
  br i1 %119, label %121, label %122

121:                                              ; preds = %118
  store i32 1, i32* %120, align 8, !tbaa !2
  br label %123

122:                                              ; preds = %118
  store i32 0, i32* %120, align 8, !tbaa !2
  br label %123

123:                                              ; preds = %122, %121, %117, %113
  %124 = phi i32 [ 0, %122 ], [ 1, %121 ], [ 0, %117 ], [ %116, %113 ]
  %125 = getelementptr inbounds [2500 x %struct.Cell], [2500 x %struct.Cell]* @updatePixels.swapCells, i64 0, i64 %107, i32 1
  store i32 %124, i32* %125, align 4, !tbaa !7
  %126 = icmp eq i64 %47, 50
  br i1 %126, label %37, label %38

127:                                              ; preds = %37, %131
  %128 = phi i64 [ %132, %131 ], [ 0, %37 ]
  %129 = mul nuw nsw i64 %128, 50
  %130 = trunc i64 %128 to i32
  br label %134

131:                                              ; preds = %164
  %132 = add nuw nsw i64 %128, 1
  %133 = icmp eq i64 %132, 50
  br i1 %133, label %23, label %127

134:                                              ; preds = %164, %127
  %135 = phi i64 [ 0, %127 ], [ %167, %164 ]
  %136 = add nuw nsw i64 %135, %129
  %137 = getelementptr inbounds [2500 x %struct.Cell], [2500 x %struct.Cell]* @updatePixels.swapCells, i64 0, i64 %136, i32 0
  %138 = load i32, i32* %137, align 8, !tbaa !2
  %139 = getelementptr inbounds [2500 x %struct.Cell], [2500 x %struct.Cell]* %1, i64 0, i64 %136, i32 0
  store i32 %138, i32* %139, align 8, !tbaa !2
  %140 = getelementptr inbounds [2500 x %struct.Cell], [2500 x %struct.Cell]* @updatePixels.swapCells, i64 0, i64 %136, i32 1
  %141 = load i32, i32* %140, align 4, !tbaa !7
  %142 = getelementptr inbounds [2500 x %struct.Cell], [2500 x %struct.Cell]* %1, i64 0, i64 %136, i32 1
  store i32 %141, i32* %142, align 4, !tbaa !7
  %143 = icmp eq i32 %141, 10
  br i1 %143, label %144, label %145

144:                                              ; preds = %134
  store i32 0, i32* %139, align 8, !tbaa !2
  store i32 0, i32* %142, align 4, !tbaa !7
  br label %164

145:                                              ; preds = %134
  %146 = icmp eq i32 %138, 1
  br i1 %146, label %147, label %164

147:                                              ; preds = %145
  %148 = icmp sgt i32 %141, 6
  %149 = shl i32 %141, 17
  %150 = icmp slt i32 %141, 5
  br i1 %150, label %151, label %153

151:                                              ; preds = %147
  %152 = udiv i32 255, %141
  br label %153

153:                                              ; preds = %151, %147
  %154 = phi i32 [ %152, %151 ], [ 0, %147 ]
  %155 = add i32 %141, -5
  %156 = icmp ult i32 %155, 2
  %157 = select i1 %156, i32 127, i32 0
  %158 = add i32 %149, 7012352
  %159 = shl nuw nsw i32 %154, 8
  %160 = or i32 %158, -16777216
  %161 = select i1 %148, i32 %160, i32 -16777216
  %162 = or i32 %161, %157
  %163 = or i32 %162, %159
  br label %164

164:                                              ; preds = %153, %145, %144
  %165 = phi i32 [ %163, %153 ], [ 0, %145 ], [ 0, %144 ]
  %166 = trunc i64 %135 to i32
  tail call fastcc void @paintCellPixels(i32 %166, i32 %130, i32 %165) #4
  %167 = add nuw nsw i64 %135, 1
  %168 = icmp eq i64 %167, 50
  br i1 %168, label %131, label %134
}

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #1

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.memset.p0i8.i64(i8* nocapture writeonly, i8, i64, i1 immarg) #1

declare dso_local void @simFlush(...) local_unnamed_addr #2

declare dso_local i32 @simRand(...) local_unnamed_addr #2

; Function Attrs: nounwind uwtable
define internal fastcc void @paintCellPixels(i32 %0, i32 %1, i32 %2) unnamed_addr #3 {
  %4 = shl nsw i32 %0, 4
  %5 = or i32 %4, 1
  %6 = shl nsw i32 %1, 4
  %7 = or i32 %6, 1
  %8 = or i32 %6, 15
  %9 = icmp slt i32 %7, %8
  br i1 %9, label %10, label %29

10:                                               ; preds = %3
  %11 = or i32 %4, 15
  %12 = icmp slt i32 %5, %11
  %13 = add nuw nsw i32 %5, 1
  %14 = or i32 %4, 3
  %15 = add nuw nsw i32 %14, 1
  %16 = add nuw nsw i32 %14, 2
  %17 = add nuw nsw i32 %14, 3
  %18 = or i32 %4, 7
  %19 = add nuw nsw i32 %18, 1
  %20 = add nuw nsw i32 %18, 2
  %21 = add nuw nsw i32 %18, 3
  %22 = add nuw nsw i32 %18, 4
  %23 = add nuw nsw i32 %18, 5
  %24 = add nuw nsw i32 %18, 6
  %25 = add nuw nsw i32 %18, 7
  br label %26

26:                                               ; preds = %30, %10
  %27 = phi i32 [ %7, %10 ], [ %31, %30 ]
  br i1 %12, label %28, label %30

28:                                               ; preds = %26
  tail call void @simPutPixel(i32 %5, i32 %27, i32 %2) #4
  tail call void @simPutPixel(i32 %13, i32 %27, i32 %2) #4
  tail call void @simPutPixel(i32 %14, i32 %27, i32 %2) #4
  tail call void @simPutPixel(i32 %15, i32 %27, i32 %2) #4
  tail call void @simPutPixel(i32 %16, i32 %27, i32 %2) #4
  tail call void @simPutPixel(i32 %17, i32 %27, i32 %2) #4
  tail call void @simPutPixel(i32 %18, i32 %27, i32 %2) #4
  tail call void @simPutPixel(i32 %19, i32 %27, i32 %2) #4
  tail call void @simPutPixel(i32 %20, i32 %27, i32 %2) #4
  tail call void @simPutPixel(i32 %21, i32 %27, i32 %2) #4
  tail call void @simPutPixel(i32 %22, i32 %27, i32 %2) #4
  tail call void @simPutPixel(i32 %23, i32 %27, i32 %2) #4
  tail call void @simPutPixel(i32 %24, i32 %27, i32 %2) #4
  tail call void @simPutPixel(i32 %25, i32 %27, i32 %2) #4
  br label %30

29:                                               ; preds = %30, %3
  ret void

30:                                               ; preds = %28, %26
  %31 = add nuw i32 %27, 1
  %32 = icmp eq i32 %31, %8
  br i1 %32, label %29, label %26
}

declare dso_local void @simPutPixel(i32, i32, i32) local_unnamed_addr #2

attributes #0 = { noreturn nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { argmemonly nounwind willreturn }
attributes #2 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #4 = { nounwind }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 10.0.0-4ubuntu1 "}
!2 = !{!3, !4, i64 0}
!3 = !{!"Cell", !4, i64 0, !4, i64 4}
!4 = !{!"int", !5, i64 0}
!5 = !{!"omnipotent char", !6, i64 0}
!6 = !{!"Simple C/C++ TBAA"}
!7 = !{!3, !4, i64 4}
!8 = !{!4, !4, i64 0}
