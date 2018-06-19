FROM phusion/baseimage:0.10.0
CMD ["/sbin/my_init"]

# RISC-V 
# 9a8a0aa9 march 8 2015
RUN apt-get update \
 && apt-get install -y \
    autoconf \
    automake \
    autotools-dev \
    curl \
    libmpc-dev \
    libmpfr-dev \
    libgmp-dev \
    libusb-1.0-0-dev \
    gawk \
    build-essential \
    bison \
    flex \
    texinfo \
    gperf \
    libtool \
    patchutils \
    bc \
    zlib1g-dev \
    device-tree-compiler \
    pkg-config \
    unzip \
 && rm -rf /var/lib/apt/lists/*

ARG RISCV_HASH=9a8a0aa98571c97291702e2e283fc1056f3ce2e2
WORKDIR /tmp
RUN curl -LO https://github.com/riscv/riscv-gnu-toolchain/archive/$RISCV_HASH.zip \
 && unzip $RISCV_HASH.zip \
 && cd riscv-gnu-toolchain-$RISCV_HASH \
 && ./configure --prefix=/opt/riscv-$RISCV_HASH \
 && make \
 && cd .. \
 && rm -rf riscv-gnu-toolchain-$RISCV_HASH $RISCV_HASH.zip

RUN apt-get update \
 && apt-get install -y \
    cmake \
    cmake-doc \
    openjdk-8-jre \
    openjdk-8-jdk \
    vim \
    python \
    python3 \
    bsdmainutils \
 && rm -rf /var/lib/apt/lists/*

ENV PATH="${PATH}:/opt/riscv-$RISCV_HASH/bin"

WORKDIR /opt/
RUN curl -LO https://github.com/pretis/flexpret/archive/master.zip \
 && unzip master.zip \
 && rm master.zip \
 && cd flexpret-master \
 && echo $PATH \
 && make run 

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
