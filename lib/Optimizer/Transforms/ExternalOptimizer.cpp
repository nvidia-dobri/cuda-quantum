/*******************************************************************************
 * Copyright (c) 2022 - 2024 NVIDIA Corporation & Affiliates.                  *
 * All rights reserved.                                                        *
 *                                                                             *
 * This source code and the accompanying materials are made available under    *
 * the terms of the Apache License 2.0 which accompanies this distribution.    *
 ******************************************************************************/

#include "PassDetails.h"
#include "cudaq/Frontend/nvqpp/AttributeNames.h"
#include "cudaq/Optimizer/Dialect/CC/CCOps.h"
#include "cudaq/Optimizer/Dialect/Quake/QuakeDialect.h"
#include "cudaq/Optimizer/Dialect/Quake/QuakeTypes.h"
#include "cudaq/Optimizer/Transforms/Passes.h"
#include "mlir/IR/IRMapping.h"
#include "mlir/Transforms/DialectConversion.h"
#include "mlir/Transforms/Passes.h"

#define DEBUG_TYPE "external-optimizer"

//===----------------------------------------------------------------------===//
// Generated logic
//===----------------------------------------------------------------------===//
namespace cudaq::opt {
#define GEN_PASS_DEF_EXTERNALOPTIMIZER
#include "cudaq/Optimizer/Transforms/Passes.h.inc"
} // namespace cudaq::opt

using namespace mlir;

namespace {

struct ExternalOptimizerPass
    : public cudaq::opt::impl::ExternalOptimizerBase<ExternalOptimizerPass> {
  using ExternalOptimizerBase::ExternalOptimizerBase;

  /// Convert the quake kernels to an intermediate representation that can be used by
  /// an external optimizer.
  void runOnOperation() override {
    auto mod = getOperation();

    for (auto &op : mod) {
      if (auto func = dyn_cast<func::FuncOp>(op)) {
        if (!func->hasAttr("cudaq-kernel"))
          continue;

        LLVM_DEBUG(llvm::dbgs() << "Optimizing kernel: " << func->getName() << "\n");

        // TODO: convert the quake kernels to an intermediate representation
        // that can be used by an external optimizer.
      }
    }
  }
};

} // namespace

std::unique_ptr<mlir::Pass> cudaq::opt::createExternalOptimizerPass() {
  return std::make_unique<ExternalOptimizerPass>();
}
