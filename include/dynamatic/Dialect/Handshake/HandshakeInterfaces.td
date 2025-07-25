//===- HandshakeInterfaces.td - Handshake interfaces -------*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file originates from the CIRCT project (https://github.com/llvm/circt).
// It includes modifications made as part of Dynamatic.
//
//===----------------------------------------------------------------------===//
//
// This is the definition file for the structured interface for Handshake ops.
//
//===----------------------------------------------------------------------===//

#ifndef DYNAMATIC_DIALECT_HANDSHAKE_HANDSHAKE_INTERFACES
#define DYNAMATIC_DIALECT_HANDSHAKE_HANDSHAKE_INTERFACES

include "mlir/IR/OpBase.td"

def ArithOpInterface : OpInterface<"ArithOpInterface"> {
  let cppNamespace = "::dynamatic::handshake";
  let description = [{
     Handshake operations which semantically correspond to an operation from the
     `ArithDialect`.
  }];
}

def MergeLikeOpInterface : OpInterface<"MergeLikeOpInterface"> {
  let cppNamespace = "::dynamatic::handshake";
  let description = [{
     Some handshake operations can have predecessors in other
     blocks. This is primarily useful for verification purposes during
     lowering from other dialect, such as the standard CDFG dialect.
  }];

  let methods = [
    InterfaceMethod<[{
        Returns an operand range over the data signals being merged.
      }],
      "mlir::OperandRange", "getDataOperands", (ins)
    >,
    InterfaceMethod<[{
        Returns the operation's result representing the selected data operand.
      }],
      "mlir::OpResult", "getDataResult", (ins)
    >,
  ];
}

def MemoryOpInterface : OpInterface<"MemoryOpInterface"> {
  let cppNamespace = "::dynamatic::handshake";
  let description =
      [{"Allocate the memory to the meory map in the simulation. "}];

  let methods = [
    InterfaceMethod<[{
        Returns whether the interface is a "master" interface i.e., one that
        directly connects to an external memory through its parent Handshake
        function's ports.
      }], "bool", "isMasterInterface", (ins)
    >,
    InterfaceMethod<
      "Returns the memref-typed SSA value that the interface references.",
      "::mlir::TypedValue<::mlir::MemRefType>", "getMemRef", (ins)
    >,
    InterfaceMethod<[{
      Returns the type of the memref-typed SSA value that the interface
      references.
      }],
      "::mlir::MemRefType", "getMemRefType", (ins),
      "", [{
        ConcreteOp concreteOp = cast<ConcreteOp>($_op);
        return concreteOp.getMemRef().getType().template cast<mlir::MemRefType>();
      }]
    >,
    InterfaceMethod<[{
        Returns the memory start signal associated to the memory region this
        interfaces to.
      }],
      "::mlir::TypedValue<::dynamatic::handshake::ControlType>", "getMemStart",
      (ins)
    >,
    InterfaceMethod<[{
        Returns the memory end signal associated to the memory region this
        interfaces to.
      }],
      "::mlir::TypedValue<::dynamatic::handshake::ControlType>", "getMemEnd",
      (ins)
    >,
    InterfaceMethod<[{
        Returns the control end signal associated to the memory region this
        interfaces to.
      }],
      "::mlir::TypedValue<::dynamatic::handshake::ControlType>", "getCtrlEnd",
      (ins)
    >
  ];
}

def MemPortOpInterface : OpInterface<"MemPortOpInterface"> {
  let cppNamespace = "::dynamatic::handshake";
  let description = [{
    Handshake operations which act as a memory port (load or store) to a memory
    interface.
  }];

 let methods = [
    InterfaceMethod<
      "Returns the port's address input.",
      "::mlir::TypedValue<::dynamatic::handshake::ChannelType>", "getAddressInput",
      (ins), "", [{
        ConcreteOp concreteOp = mlir::cast<ConcreteOp>($_op);
        return concreteOp.getAddress();
      }]
    >,
    InterfaceMethod<
      "Returns the port's data input.",
      "::mlir::TypedValue<::dynamatic::handshake::ChannelType>", "getDataInput",
      (ins), "", [{
        ConcreteOp concreteOp = mlir::cast<ConcreteOp>($_op);
        return concreteOp.getData();
      }]
    >,
    InterfaceMethod<
      "Returns the port's address output.",
      "::mlir::TypedValue<::dynamatic::handshake::ChannelType>", "getAddressOutput",
      (ins), "", [{
        ConcreteOp concreteOp = mlir::cast<ConcreteOp>($_op);
        return concreteOp.getAddressResult();
      }]
    >,
    InterfaceMethod<
      "Returns the port's data output.",
      "::mlir::TypedValue<::dynamatic::handshake::ChannelType>", "getDataOutput",
      (ins), "", [{
        ConcreteOp concreteOp = mlir::cast<ConcreteOp>($_op);
        return concreteOp.getDataResult();
      }]
    >,
  ];
}

def NamedIOInterface : OpInterface<"NamedIOInterface"> {
  let cppNamespace = "::dynamatic::handshake";
  let description =
      [{"Provides detailed names for the operands and results of an operation."}];

  let methods = [
    StaticInterfaceMethod<
        "Returns the default name of a specific operand.",
        "std::string", "getDefaultOperandName", (ins "unsigned" : $idx),
        "",
        [{
          return "ins_" + std::to_string(idx);
        }]>,
    StaticInterfaceMethod<
        "Returns the default name of a specific result.",
        "std::string", "getDefaultResultName", (ins "unsigned" : $idx),
        "",
        [{
          return "outs_" + std::to_string(idx);
        }]>,
    InterfaceMethod<
        "Returns the name of a specific operand.",
        "std::string", "getOperandName", (ins "unsigned" : $idx),
        "",
        [{
          ConcreteOp concreteOp = mlir::cast<ConcreteOp>($_op);

          // Operations which always have a single operand get a specific port
          // name for it
          if (concreteOp.template hasTrait<mlir::OpTrait::OneOperand>()) {
            assert(idx == 0 && "index too high");
            return "ins";
          }

          // Generic input name
          assert(idx < concreteOp->getNumOperands() && "index too high");
          return getDefaultOperandName(idx);
        }]>,
    InterfaceMethod<
        "Returns the name of a specific result.",
        "std::string", "getResultName", (ins "unsigned" : $idx),
        "",
        [{
          ConcreteOp concreteOp = mlir::cast<ConcreteOp>($_op);
          
          // Operations which always have a single result get a specific port
          // name for it
          if (concreteOp.template hasTrait<mlir::OpTrait::OneResult>()) {
            assert(idx == 0 && "index too high");
            return "outs";
          }

          // Generic output name
          assert(idx < concreteOp->getNumResults() && "index too high");
          return getDefaultResultName(idx);
        }]>
  ];
}

def ControlInterface : OpInterface<"ControlInterface"> {
  let cppNamespace = "::dynamatic::handshake";
  let description =
      [{"Provides information on whether this operation is a control operation."}];

  let methods = [
    InterfaceMethod<
      "Returns true if this operation is a control operation.",
      "bool", "isControl", (ins), "",
      "return false;"
    >];
}

def HasClock : NativeOpTrait<"HasClock">;


def InternalDelayInterface : OpInterface<"InternalDelayInterface"> {
  let cppNamespace = "::dynamatic::handshake";
  let description = [{
     Handshake operations which have a variable internal delay
     used in frequency regulation.
  }];

  let methods = [
    InterfaceMethod<[{
      Sets the internal delay as a StringAttr named "internal_delay".
    }], "void", "setInternalDelay", (ins "::llvm::StringRef":$value), [{
      Operation *op = $_op.getOperation();
      op->setAttr("internal_delay",
                   StringAttr::get(op->getContext(), value));
    }]>,
    
    // Return StringAttr instead of StringRef to ensure proper memory allocation.
    // Using StringRef would result in the default value "0.0" becoming a dangling pointer.
    InterfaceMethod<[{
      Gets the internal delay as a StringAttr named "internal_delay". Defaults to "0.0" if not set.
    }], "StringAttr", "getInternalDelay", (ins), [{
      Operation *op = $_op.getOperation();
      if (auto attr = op->getAttrOfType<StringAttr>("internal_delay"))
        return attr;
      return StringAttr::get(op->getContext(), "0.0");
    }]>
  ];
}


def FPUImplInterface : OpInterface<"FPUImplInterface"> {
  let cppNamespace = "::dynamatic::handshake";
  let description = [{
     Specifies which "vendor" of floating point units
     to use
  }];

  let methods = [
    InterfaceMethod<[{
      Sets the FPU Impl. as a FPUImplAttr attr named "fpu_impl".
    }], "void", "setFPUImpl", (ins "FPUImpl":$value), [{
      Operation *op = $_op.getOperation();
      op->setAttr("fpu_impl",
                  FPUImplAttr::get(op->getContext(), value));
    }]>,

InterfaceMethod<[{
      Gets the FPU impl. as a FPUImpl named "fpu_impl". Defaults to "FLOPOCO" if not set.
    }], "FPUImpl", "getFPUImpl", (ins), [{
      Operation *op = $_op.getOperation();
      if (auto attr = op->getAttrOfType<FPUImplAttr>("fpu_impl")) {
        return attr.getValue();
      }
      return FPUImpl::FLOPOCO;
    }]>
  ];
}

#endif //DYNAMATIC_DIALECT_HANDSHAKE_HANDSHAKE_INTERFACES
