; RUN: opt < %s -lower-autodiff -mem2reg -instsimplify -simplifycfg -S | FileCheck %s

; Function Attrs: noinline norecurse nounwind readnone uwtable
define dso_local double* @cast(double* readnone returned %x) local_unnamed_addr #0 {
entry:
  ret double* %x
}

; Function Attrs: noinline norecurse nounwind uwtable
define dso_local void @function(double %y, double %z, double* %x) local_unnamed_addr #1 {
entry:
  %mul = fmul fast double %z, %y
  %call = tail call double* @cast(double* %x)
  store double %mul, double* %call, align 8, !tbaa !2
  ret void
}

; Function Attrs: noinline norecurse nounwind uwtable
define dso_local void @addOne(double* nocapture %x) local_unnamed_addr #1 {
entry:
  %0 = load double, double* %x, align 8, !tbaa !2
  %add = fadd fast double %0, 1.000000e+00
  store double %add, double* %x, align 8, !tbaa !2
  ret void
}

; Function Attrs: noinline norecurse nounwind uwtable
define dso_local void @function0(double %y, double %z, double* %x) #1 {
entry:
  tail call void @function(double %y, double %z, double* %x)
  tail call void @addOne(double* %x)
  ret void
}

; Function Attrs: nounwind uwtable
define dso_local double @test_derivative(double* %x, double* %xp, double %y, double %z) local_unnamed_addr #2 {
entry:
  %0 = tail call double (void (double, double, double*)*, ...) @llvm.autodiff.p0f_isVoidf64f64p0f64f(void (double, double, double*)* nonnull @function0, double %y, double %z, double* %x, double* %xp)
  ret double %0
}

; Function Attrs: nounwind
declare double @llvm.autodiff.p0f_isVoidf64f64p0f64f(void (double, double, double*)*, ...) #3

attributes #0 = { noinline norecurse nounwind readnone uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="true" "no-jump-tables"="false" "no-nans-fp-math"="true" "no-signed-zeros-fp-math"="true" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="true" "use-soft-float"="false" }
attributes #1 = { noinline norecurse nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="true" "no-jump-tables"="false" "no-nans-fp-math"="true" "no-signed-zeros-fp-math"="true" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="true" "use-soft-float"="false" }
attributes #2 = { nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="true" "no-jump-tables"="false" "no-nans-fp-math"="true" "no-signed-zeros-fp-math"="true" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="true" "use-soft-float"="false" }
attributes #3 = { nounwind }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 7.1.0 "}
!2 = !{!3, !3, i64 0}
!3 = !{!"double", !4, i64 0}
!4 = !{!"omnipotent char", !5, i64 0}
!5 = !{!"Simple C/C++ TBAA"}

; CHECK: define internal { double, double } @diffefunction(double %y, double %z, double* %x, double* %"x'", { double*, {} } %tapeArg)
