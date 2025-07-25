// NOTE: Assertions have been autogenerated by utils/generate-test-checks.py
// RUN: dynamatic-opt --lower-handshake-to-hw %s --split-input-file | FileCheck %s

// CHECK-LABEL:   hw.module @dontChangeTypes(in 
// CHECK-SAME:                                  %[[VAL_0:.*]] : !handshake.channel<i32>, in %[[VAL_1:.*]] : !handshake.control<>, in %[[VAL_2:.*]] : i1, in
// CHECK-SAME:                                  %[[VAL_3:.*]] : i1, out out0 : !handshake.control<>) {
// CHECK:           hw.instance "sink0" @handshake_sink_0(ins: %[[VAL_0]]: !handshake.channel<i32>, clk: %[[VAL_2]]: i1, rst: %[[VAL_3]]: i1) -> ()
// CHECK:           hw.output %[[VAL_1]] : !handshake.control<>
// CHECK:         }
// CHECK:         hw.module.extern @handshake_sink_0(in %[[VAL_5:.*]] : !handshake.channel<i32>, in %[[VAL_6:.*]] : i1, in %[[VAL_7:.*]] : i1) attributes {hw.name = "handshake.sink", hw.parameters = {DATA_TYPE = !handshake.channel<i32>}}
handshake.func @dontChangeTypes(%arg : !handshake.channel<i32>, %start: !handshake.control<>) -> !handshake.control<> {
  sink %arg : <i32>
  end %start : <>
}

// -----

// CHECK-LABEL:   hw.module @lowerNonIntTypes(in 
// CHECK-SAME:                                   %[[VAL_0:.*]] : !handshake.channel<i32, [extra: i32]>, in %[[VAL_1:.*]] : !handshake.channel<i32, [extra: i32]>, in %[[VAL_2:.*]] : i1, in
// CHECK-SAME:                                   %[[VAL_3:.*]] : i1, out out0 : !handshake.channel<i32, [extra: i32]>) {
// CHECK:           %[[VAL_4:.*]] = hw.instance "addf0" @handshake_addf_0(lhs: %[[VAL_0]]: !handshake.channel<i32, [extra: i32]>, rhs: %[[VAL_1]]: !handshake.channel<i32, [extra: i32]>, clk: %[[VAL_2]]: i1, rst: %[[VAL_3]]: i1) -> (result: !handshake.channel<i32, [extra: i32]>)
// CHECK:           hw.output %[[VAL_4]] : !handshake.channel<i32, [extra: i32]>
// CHECK:         }
// CHECK:         hw.module.extern @handshake_addf_0(in %[[VAL_6:.*]] : !handshake.channel<i32, [extra: i32]>, in %[[VAL_7:.*]] : !handshake.channel<i32, [extra: i32]>, in %[[VAL_8:.*]] : i1, in %[[VAL_9:.*]] : i1, out result : !handshake.channel<i32, [extra: i32]>) attributes {hw.name = "handshake.addf", hw.parameters = {DATA_TYPE = !handshake.channel<f32, [extra: ui32]>, FPU_IMPL = "flopoco", INTERNAL_DELAY = "0.0"}}
handshake.func @lowerNonIntTypes(%arg0 : !handshake.channel<f32, [extra: ui32]>, %arg1 : !handshake.channel<f32, [extra: ui32]>) -> !handshake.channel<f32, [extra: ui32]> {
  %res = addf %arg0, %arg1 : <f32, [extra: ui32]>
  end %res : <f32, [extra: ui32]>
}
