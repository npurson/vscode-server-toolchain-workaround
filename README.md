# VS Code Server Toolchain Workaround

Starting with VS Code release 1.86, the minimum requirements for the build toolchain of the remote server were raised. The prebuilt servers distributed by VS Code are compatible with Linux distributions based on glibc 2.28 or later.

This toolkit provides a workaround for whose setup does not meet these requirements and you are unable to upgrade the Linux distribution but still want to update VS Code. It ensembles glibc, libstdc++ and patchelf.

## Usage

The following steps have to be executed each time VS Code is updated.

1. Update the VS Code on local.
2. Connect to the remote server and await the download’s completion until the error regarding unsatisfied prerequisites is encountered.
3. Execute the `run.sh` script.

## Prerequisites for VS Code

kernel >= 4.18, glibc >=2.28, libstdc++ >= 3.4.25 (gcc 8.1.0), Python 2.6 or 2.7, tar

## References

https://code.visualstudio.com/docs/remote/linux#_remote-host-container-wsl-linux-prerequisites
https://code.visualstudio.com/docs/remote/faq#_can-i-run-vs-code-server-on-older-linux-distributions

## Workings

### 1. Bypassing the requirements check of VS Code

The following excerpt is from `~/.vscode-server/bin/05047486b6df5eb8d44b2ecd70ea3bdf775fd937/bin/helpers/check-requirements.sh`:

```bash
if [ -f "/tmp/vscode-skip-server-requirements-check" ]; then
        echo "!!! WARNING: Skipping server pre-requisite check !!!"
        echo "!!! Server stability is not guaranteed. Proceed at your own risk. !!!"
        exit 0
fi
```

Hence, creating the file `/tmp/vscode-skip-server-requirements-check` can skip the requirements check.

### 2. Upgrading glibc and libstdc++ for VS Code

Utilize PatchELF to modify the dynamic linker and RPATH of ELF executables.

Note: The loading priority of the dynamic linker is as follows:

1. RPATH within the ELF
2. LD_LIBRARY_PATH environment variables
3. RUNPATH within the ELF
4. Cache in /etc/ld.so.cache
5. /lib and /usr/lib
