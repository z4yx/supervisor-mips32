#FROM alpine:3
FROM debian:buster

#RUN apk add --no-cache libc6-compat bash python3 make qemu-system-mipsel wget && \
RUN apt-get update && \
    apt-get install -y wget python3-pip make qemu-system-mips expect && \  
    pip3 install pyserial && \
    wget -O MIPS.MTI.Bare.Metal.x86_64.tar.gz 'https://cloud.tsinghua.edu.cn/f/16dde018b00749a4a4de/?dl=1' && \
    tar -xf MIPS.MTI.Bare.Metal.x86_64.tar.gz && \
    rm MIPS.MTI.Bare.Metal.x86_64.tar.gz

ENV PATH="${PWD}/mips-mti-elf/2016.05-06/bin:${PATH}"
