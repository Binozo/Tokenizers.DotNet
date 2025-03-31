﻿# https://github.com/mstorsjo/llvm-mingw
ARG RUST_VERSION=1.85.0

FROM rust:${RUST_VERSION}-bookworm AS rust

# Win X64
FROM rust AS winx64

RUN apt-get update && \
    apt-get install -qqy --no-install-recommends mingw-w64

RUN rustup target add x86_64-pc-windows-gnu

WORKDIR /src

COPY . .

WORKDIR /src/rust

RUN cargo build --target x86_64-pc-windows-gnu --release

# Win ARM64
FROM mstorsjo/llvm-mingw:20250319 AS winarm64

RUN apt-get update && \
    apt-get install -qqy --no-install-recommends g++ mingw-w64

# Install Rust
COPY --from=rust /usr/local/cargo /usr/local/cargo
COPY --from=rust /usr/local/rustup /usr/local/rustup
ENV PATH="$PATH:/usr/local/cargo/bin"

RUN rustup default stable
RUN rustup target add aarch64-pc-windows-gnullvm

WORKDIR /src

COPY . .

WORKDIR /src/rust

ENV CXXFLAGS="--stdlib=libc++"
RUN cargo build --target aarch64-pc-windows-gnullvm --release

# Linux X64
FROM rust AS linuxx64

RUN rustup target add x86_64-unknown-linux-gnu

WORKDIR /src

COPY . .

WORKDIR /src/rust
RUN cargo build --target x86_64-unknown-linux-gnu --release

# Linux ARM64
FROM rust AS linuxarm64

RUN apt-get update && \
    apt-get purge -y g++ && \
    apt-get install -qqy --no-install-recommends g++-aarch64-linux-gnu libc6-dev-arm64-cross

RUN rustup target add aarch64-unknown-linux-gnu
#RUN rustup toolchain install stable-aarch64-unknown-linux-gnu

WORKDIR /src

COPY . .

WORKDIR /src/rust
ENV CARGO_TARGET_AARCH64_UNKNOWN_LINUX_GNU_LINKER=aarch64-linux-gnu-gcc \
    CC_aarch64_unknown_linux_gnu=aarch64-linux-gnu-gcc \
    CXX_aarch64_unknown_linux_gnu=aarch64-linux-gnu-g++
RUN cargo build --target aarch64-unknown-linux-gnu --release

FROM rust

WORKDIR /src

# Prepare powershell
SHELL ["/bin/bash", "-c"]
RUN apt-get update && \
    apt-get install -y wget && \
    source /etc/os-release && \
    wget -q https://packages.microsoft.com/config/debian/$VERSION_ID/packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb && \
    rm packages-microsoft-prod.deb

# Install nuget + dotnet and powershell
RUN apt-get update && \
    apt-get install -y nuget mono-complete dos2unix powershell && \
    wget https://dot.net/v1/dotnet-install.sh -O dotnet-install.sh && \
    chmod +x ./dotnet-install.sh && \
    ./dotnet-install.sh --channel 9.0 && \
    nuget update -self

ENV PATH=$PATH:/root/.dotnet

COPY . .

COPY --from=winx64 /src/rust/target/x86_64-pc-windows-gnu/release/hf_tokenizers.dll /src/nuget/win-x64/hf_tokenizers.dll
COPY --from=winarm64 /src/rust/target/aarch64-pc-windows-gnullvm/release/hf_tokenizers.dll /src/nuget/win-arm64/hf_tokenizers.dll
COPY --from=linuxx64 /src/rust/target/x86_64-unknown-linux-gnu/release/libhf_tokenizers.so /src/nuget/linux-x64/libhf_tokenizers.so
COPY --from=linuxarm64 /src/rust/target/aarch64-unknown-linux-gnu/release/libhf_tokenizers.so /src/nuget/linux-arm64/libhf_tokenizers.so

# Clean
RUN dos2unix clear_all.ps1
RUN pwsh -File clear_all.ps1

# Build
RUN dos2unix build_dotnet.ps1
RUN pwsh -File build_dotnet.ps1

CMD ["cp", "-a", "/src/nuget/.", "/out/"]