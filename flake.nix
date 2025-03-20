{
  description = "CUDA Quantum development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-cmake.url = "github:NixOS/nixpkgs?rev=c9eb8d14da4455de9f05ce9429324e5b1b2bc638";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, nixpkgs-cmake, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
            cudaSupport = true;
          };
        };
        pkgs-cmake = import nixpkgs-cmake {
          inherit system;
        };
        cmake_3_26 = pkgs-cmake.cmake;
        # We need to symlink cuda compiler and dev headers to find the toolkit
        # TODO (nvidia-dobri): Make the scattered install work with FindCUDAToolkit.cmake
        cudart = pkgs.lib.getDev pkgs.cudaPackages.cuda_cudart;
        symlinkedCuda = pkgs.symlinkJoin {
          name = "symlinked-cuda-${pkgs.cudaPackages.cudaVersion}";
          paths = with pkgs.cudaPackages; [
            cuda_nvcc
            cudart
          ];
        };
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            # CUDA
            symlinkedCuda
            cudaPackages.cuda_cudart
            cudaPackages.cuda_cccl
            cudaPackages.libcublas
            cudaPackages.libcusolver

            # Core build tools
            cmake_3_26
            ninja
            gcc11
            gfortran11
            gtest

            # Utils
            git
            gnupg

            # Dev tools
            pre-commit

            # Prerequisites
            pkgsStatic.openblas
            ncurses # TermInfo
          ];

          shellHook = ''
            # CUDA setup
            export CUDA_HOME="${symlinkedCuda}"

            # Prerequisites - nix-managed
            # TODO (nvidia-dobri): Move more deps from unmanaged to managed
            export BLAS_INSTALL_PREFIX="${pkgs.pkgsStatic.openblas}"

            # Prerequisites - unmanaged
            export ZLIB_INSTALL_PREFIX=/usr/local/zlib
            export LLVM_INSTALL_PREFIX=/usr/local/llvm
            export OPENSSL_INSTALL_PREFIX=/usr/local/openssl
            export CURL_INSTALL_PREFIX=/usr/local/curl
            export AWS_INSTALL_PREFIX=/usr/local/aws
            export CUQUANTUM_INSTALL_PREFIX=/usr/local/cuquantum
            export CUTENSOR_INSTALL_PREFIX=/usr/local/cutensor

            # Install location
            export CUDAQ_INSTALL_PREFIX=/usr/local/cudaq

            # Python setup - unsupported
            # TODO (nvidia-dobri): Figure out why fixup-linkage is not being built
            export CUDAQ_PYTHON_SUPPORT="FALSE"

            # Compiler setup
            export CC="${pkgs.gcc11}/bin/gcc"
            export CXX="${pkgs.gcc11}/bin/g++"
            export FC="${pkgs.gfortran11}/bin/gfortran"

            # LLVM setup
            export PATH="$PATH:$LLVM_INSTALL_PREFIX/bin/"
          '';

          LD_LIBRARY_PATH = with pkgs; lib.makeLibraryPath [
            cudaPackages.libcusolver
            cudaPackages.libcublas
          ];
        };
      });
}
