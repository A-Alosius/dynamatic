# Include headers from tutorials
include_directories(${DYNAMATIC_SOURCE_DIR}/tutorials/CreatingPasses/include)
include_directories(${DYNAMATIC_BINARY_DIR}/tutorials/CreatingPasses/include)

set(LLVM_LINK_COMPONENTS
  Support
)

add_llvm_tool(dynamatic-opt
  dynamatic-opt.cpp
)

llvm_update_compile_flags(dynamatic-opt)
target_link_libraries(dynamatic-opt
  PRIVATE
  AffineToScf
  DynamaticLowerScfToCf
  DynamaticLLVMToControlFlow
  DynamaticBufferPlacement
  DynamaticLSQSizing
  DynamaticSpeculation
  DynamaticRigidification
  DynamaticFormalPropertyAnnotation
  DynamaticExperimentalResourceSharing
  DynamaticCfToHandshake
  DynamaticHandshake
  DynamaticHandshakeToHW
  DynamaticTestTransforms
  DynamaticTransforms
  DynamaticTutorialsCreatingPasses
  DynamaticExperimentalTestTransforms
  DynamaticExperimentalSupport
  DynamaticExperimentalTransforms
  DynamaticExperimentalAnalysis

  MLIRIR
  MLIRAffineTransforms
  MLIRArithTransforms
  MLIRSCFTransforms
  MLIRMemRefTransforms
  MLIRLLVMDialect
  MLIRMemRefDialect
  MLIROptLib
  MLIRParser
  MLIRFuncDialect
  MLIRSupport
  MLIRTransforms
  MLIRSCFDialect
)


if(DYNAMATIC_ENABLE_XLS)
  target_link_libraries(dynamatic-opt
    PRIVATE
    XlsDialect
    DynamaticHandshakeToXls
  )
endif()
