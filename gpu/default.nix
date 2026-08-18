{ pkgs, python }:

# NVIDIA GPU support for the RSM-MSBA environment.
#
# The short version of why this module is only ~30 lines of shell: a CUDA
# workload needs exactly ONE thing from the host, and everything else ships
# inside the Python wheels.
#
#   * libcuda.so.1 -- the userspace half of the kernel driver. It MUST come
#     from the host and MUST match the running kernel module. It cannot be
#     pip-installed, vendored, or substituted.
#
#   * The CUDA runtime, cuBLAS, cuDNN, NCCL -- all bundled inside the PyTorch
#     wheel (`torch==2.13.0+cu130` carries its own). Nothing to do here.
#
# On a normal distro libcuda.so.1 sits in /usr/lib and the loader finds it. On
# NixOS it does not: the driver is installed to /run/opengl-driver/lib, which is
# deliberately NOT on the default loader path. `ldconfig -p | grep libcuda`
# returns nothing on a working GPU machine. That single omission is the entire
# difference between a working and a non-working PyTorch, measured on
# rsm-compute-01:
#
#     plain uv venv                            -> torch.cuda.is_available() False, 0 devices
#     + LD_LIBRARY_PATH=/run/opengl-driver/lib -> torch.cuda.is_available() True,  4 devices
#
# This is also why Docker + nvidia-container-toolkit is NOT required. That stack
# solves the same problem by bind-mounting the host driver into a container; if
# the code runs natively there is no container to inject anything into, and
# pointing the loader at the driver is sufficient.
let
  # Where the NixOS nvidia module installs the userspace driver. Same path on
  # every NixOS host regardless of driver version, so it can be a constant.
  driverLib = "/run/opengl-driver/lib";

  # Shared by the devShell hook and the standalone proof app so the two cannot
  # drift -- same arrangement spark-hadoop uses.
  #
  # Guarded on the library actually existing, NOT on being Linux: students run
  # this flake on macOS laptops, on CPU-only Linux boxes, and on the GPU
  # servers, from the same commit. RSM_GPU lets later steps (and the proof)
  # branch on GPU availability without re-testing the path.
  envHook = ''
    if [ -e "${driverLib}/libcuda.so.1" ]; then
      export LD_LIBRARY_PATH="${driverLib}''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
      export RSM_GPU=1
    else
      export RSM_GPU=0
    fi
  '';

  proof = pkgs.writeShellApplication {
    name = "rsm-gpu-proof";
    runtimeInputs = [ pkgs.coreutils pkgs.gnugrep python ];
    excludeShellChecks = [ "SC1090" "SC1091" ];
    text = ''
      ${envHook}

      echo "== host driver =="
      if [ "$RSM_GPU" != "1" ]; then
        echo "  no ${driverLib}/libcuda.so.1 -- this machine has no NVIDIA driver."
        echo "  That is expected on a laptop. PyTorch will run on CPU."
        exit 0
      fi
      echo "  libcuda: ${driverLib}/libcuda.so.1"
      if command -v nvidia-smi >/dev/null 2>&1; then
        nvidia-smi --query-gpu=index,name,driver_version,memory.total \
          --format=csv,noheader | sed 's/^/  gpu /'
      fi

      # Talk to the driver directly, with no PyTorch in the picture. This
      # separates "the host is set up" from "this venv can use it" -- the two
      # fail for completely different reasons and are worth reporting apart.
      echo "== driver reachable from Python (ctypes, no torch) =="
      python3 - <<'PY'
      import ctypes
      lib = ctypes.CDLL("libcuda.so.1")
      n = ctypes.c_int()
      if lib.cuInit(0) != 0:
          raise SystemExit("  cuInit failed")
      lib.cuDeviceGetCount(ctypes.byref(n))
      print(f"  cuInit OK, driver reports {n.value} device(s)")
      PY

      # Only meaningful inside a venv that actually has torch. Absent torch is
      # not a failure of the GPU setup, so say so and exit clean.
      echo "== PyTorch =="
      if ! python3 -c "import torch" 2>/dev/null; then
        echo "  torch not importable in the active environment."
        echo "  Create a GPU course env with:  rsm-gpu-init <folder>"
        exit 0
      fi
      python3 - <<'PY'
      import torch
      print(f"  torch {torch.__version__}")
      print(f"  cuda available : {torch.cuda.is_available()}")
      print(f"  device count   : {torch.cuda.device_count()}")
      for i in range(torch.cuda.device_count()):
          print(f"    cuda:{i} {torch.cuda.get_device_name(i)}")
      if torch.cuda.is_available():
          # Detection is not proof. Run real work and verify the result came
          # back off the device.
          a = torch.randn(2048, 2048, device="cuda:0")
          c = a @ a
          torch.cuda.synchronize()
          assert c.device.type == "cuda", c.device
          print(f"  matmul on {c.device}: OK ({torch.cuda.memory_allocated()/2**20:.0f} MiB allocated)")
      PY
    '';
  };
in
{
  inherit driverLib envHook proof;
}
