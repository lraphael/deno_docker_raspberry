# build stage
FROM ubuntu:20.10 as build-stage
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get upgrade -y --no-install-recommends && \
    apt-get install -y git curl build-essential python2 && \
    rm -rf /var/lib/apt/lists/* && apt-get clean

RUN git clone --recurse-submodules https://github.com/denoland/deno.git
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
RUN . /root/.cargo/env && cd deno && rustup target add wasm32-unknown-unknown && rustup target add wasm32-wasi

# RUN . /root/.cargo/env && cd deno && cargo build --release --locked -vv
RUN . /root/.cargo/env && cd deno && cargo build -vv

# production stage
FROM ubuntu:20.10 as production-stage
COPY --from=build-stage deno/target/debug/deno /usr/bin/deno
CMD ["deno", "run", "https://deno.land/std/examples/welcome.ts"]
