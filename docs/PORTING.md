# ARMv7 porting notes

## Why a cross compiler is not enough

Bun's supported release targets do not currently include 32-bit ARM. Bun's build graph includes Rust, C/C++ bindings, generated JavaScript modules, and a pinned WebKit/JavaScriptCore build. A target triple changes compiler output only where all code and dependencies already support that target.

## Required work order

1. Use the generated `upstream-arm32-audit.md` to inventory target checks and dependency scripts for the pinned commit.
2. Determine whether the pinned WebKit fork can compile JavaScriptCore for `armv7-unknown-linux-gnueabihf`. Fix target configuration and architecture-specific code where required.
3. Add the Rust target and resolve crates/build scripts that assume 64-bit pointers or supported architectures only.
4. Cross-compile and link every native dependency for ARMHF; do not reuse x86_64/ARM64 prebuilt archives.
5. Add a target-aware build driver at `upstream/scripts/arm32/build-release.sh` through the maintained patch. It must fail on any unsupported dependency and must write the actual binary to its first argument.
6. Run ELF verification, QEMU smoke tests, and real-device integration tests.

## ABI probe

`scripts/test-armhf-toolchain.sh` is a real compiler/emulator test. It checks that the produced binary is ELF32/ARM and that it runs with a 32-bit pointer size. This is a prerequisite, not a substitute for Bun compilation.
