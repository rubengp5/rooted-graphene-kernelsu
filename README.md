# Rooted GrapheneOS Kernel Builder

An automated build environment to compile the GrapheneOS kernel with **KernelSU-Next** and **SUSFS** seamlessly integrated.

This project pulls the official GrapheneOS kernel sources, dynamically patches them with the `dev-susfs` branch of [pershoot/KernelSU-Next ](https://github.com/pershoot/KernelSU-Next) and [simonpunk/SUSFS](https://gitlab.com/simonpunk/susfs4ksu), and compiles the kernel using the GKI Bazel build system.

> [!WARNING]
> I am not responsible for bricked devices, damaged hardware, or any issues that arise from using this kernel.

## Dependencies

- Docker / Podman
- Python 3
- `lz4`
- Optional (for full OTA signing): `avbroot`, `custota`

## Configuration

### Device Configuration (JSON)

Each device is configured via a JSON file in the `devices/` directory. You can customize the source repos and branches for both KernelSU and SUSFS.

### avbroot Configuration (Optional)

If you are using this to build signed OTAs:
- `avbroot` passwords should be stored in `~/.avbroot/passwords.sh`:
  ```sh
  AVB_PASSWORD="PASSWORD_HERE"
  OTA_PASSWORD="PASSWORD_HERE"
  export AVB_PASSWORD OTA_PASSWORD
  ```
- Keys and certs must be stored in `~/.avbroot/`.

## Usage

To compile the kernel, use the `make` command. 

- `DEVICE` is the device codename (e.g., `panther`, `comet`).
- `OUTPUT` is the path to your web directory for OTA updates, or simply a local folder for the output artifacts.

```sh
# Clean the workspace before a fresh build
make clean

# Start the kernel build
make -e DEVICE=panther -e OUTPUT=./output
```

### Output Artifacts

Once the build completes successfully:
- **Flashable Zip**: A flashable kernel zip will be generated in `build_output/`.
- **Raw Artifacts**: The raw kernel components (`Image`, `Image.lz4`, `dtb.img`, `dtbo.img`, and `.ko` modules) will be available in `kernel_out/`. These can be used to replace the prebuilt kernel files in a GrapheneOS source tree for a full OS build.
