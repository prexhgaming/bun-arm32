# Bun ARM32 port

Experimental effort to port the [Bun](https://github.com/oven-sh/bun) JavaScript runtime to **Linux ARMv7 / ARMHF**.

> **Status: toolchain/feasibility pipeline, not a working Bun port.** Upstream Bun's documented Linux binary targets are x64 and ARM64; ARM32 requires source-level work in Bun, its build scripts, native dependencies, and JavaScriptCore/WebKit. This repository does not claim to produce a working runtime until those changes exist and the binary passes runtime tests.

## What GitHub Actions currently does

1. Installs an ARMHF cross compiler and QEMU user emulation.
2. Installs a host Bun bootstrap and Rust ARMv7 target.
3. Compiles a small 32-bit ARM program and executes it under QEMU.
4. Checks out the requested Bun revision and creates an architecture/build-configuration audit report.
5. Builds Bun only when `patches/arm32-port.patch` exists and that patch provides the target-aware `scripts/arm32/build-release.sh` build driver.
6. Verifies ELF32/ARM and runs smoke tests under QEMU if a runtime is produced.

The successful ABI probe proves only that the cross toolchain works. It does not prove that Bun supports ARM32.

## Run

Open **Actions → Bun ARM32 port pipeline → Run workflow**. The default source revision is the commit used during initial investigation; select another ref to test a different revision.

Download the `bun-arm32-linux-armv7` artifact to inspect `upstream-arm32-audit.md`, `arm32-diagnostics.txt`, and the ELF reports. No Bun executable is uploaded unless a real port patch builds it.

## Port requirements

- Add a coherent ARMv7 Linux target to the build system, Rust crates, native dependency build scripts, and packaging.
- Port/build the exact pinned WebKit JavaScriptCore version for 32-bit ARM. Verify its assembler/JIT configuration or implement a supported fallback; do not assume ARM64 support implies ARMv7 support.
- Resolve 32-bit pointer-size, atomics, ABI, linker, TLS, and system-library assumptions.
- Provide `patches/arm32-port.patch`, including executable `scripts/arm32/build-release.sh` that writes the resulting executable to the path argument.
- Verify the output is ELF32/ARM, run it under QEMU, and test on real ARMv7 hardware before calling the port usable.

## Scope

This target is **Linux ARMHF**, not Android/Termux. Android `armeabi-v7a` has a different ABI and linker environment and should be a separate follow-up target after the Linux port works.
