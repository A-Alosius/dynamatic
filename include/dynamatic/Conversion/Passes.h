//===- Passes.h - Conversion passes registration ---------------=*- C++ -*-===//
//
// Dynamatic is under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file contains declarations to register all conversion passes.
//
//===----------------------------------------------------------------------===//

#ifndef DYNAMATIC_CONVERSION_PASSES_H
#define DYNAMATIC_CONVERSION_PASSES_H

#include "dynamatic/Conversion/AffineToScf.h"
#include "dynamatic/Conversion/CfToHandshake.h"
#include "dynamatic/Conversion/HandshakeToHW.h"
#include "dynamatic/Conversion/LLVMToControlFlow.h"
#include "dynamatic/Conversion/ScfToCf.h"
#include "mlir/IR/DialectRegistry.h"
#include "mlir/Pass/Pass.h"
#include "mlir/Pass/PassRegistry.h"

namespace dynamatic {

// Generate the code for registering conversion passes.
#define GEN_PASS_REGISTRATION
#include "dynamatic/Conversion/Passes.h.inc"

} // namespace dynamatic

#endif // DYNAMATIC_CONVERSION_PASSES_H
