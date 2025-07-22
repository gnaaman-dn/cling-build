FROM ubuntu:24.04 AS base

RUN apt-get update && apt-get -y install libstdc++-14-dev g++ && apt-get clean

FROM base AS builder

RUN apt-get update && apt-get -y install ninja-build build-essential cmake python3

# We match the install dir to the build dir, because it is hardcoded in cling as "resource directory"
RUN --mount=type=bind,src=.,dst=/src --mount=type=cache,dst=/build \
    cd /build && \
    cmake -G Ninja \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="/build" \
        -DLLVM_ENABLE_DOXYGEN=OFF \
        -DLLVM_BUILD_TOOLS=Off \
        -DLLVM_EXTERNAL_PROJECTS=cling \
        -DLLVM_EXTERNAL_CLING_SOURCE_DIR=/src/cling \
        -DLLVM_ENABLE_PROJECTS=clang \
        -DLLVM_TARGETS_TO_BUILD="host;NVPTX" \
        -DLLVM_BUILD_DOCS=OFF \
        /src/llvm/llvm

RUN --mount=type=bind,src=.,dst=/src --mount=type=cache,dst=/build \
    DESTDIR=inst cmake --install /build

FROM base
COPY --from=builder /inst/build /build
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/build/bin
ENTRYPOINT ["/build/bin/cling"]
