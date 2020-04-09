#FROM alpine:3
FROM debian:buster

#RUN apk add --no-cache libc6-compat bash python3 make qemu-system-mipsel curl awk && \
RUN apt-get update && \
    apt-get install -y awk curl python3-pip make qemu-system-mips expect && \  
    pip3 install pyserial && \
    curl -sc /tmp/gcokie 'https://drive.google.com/uc?export=download&id=1Mo5hGcCg1zm8Ca0KQB-G5PNI3fXfAAmR' && \
    getcode="$(awk '/_warning_/ {print $NF}' /tmp/gcokie)" && \
    curl -s -C - -LOJb /tmp/gcokie "https://drive.google.com/uc?export=download&confirm=${getcode}&id=1Mo5hGcCg1zm8Ca0KQB-G5PNI3fXfAAmR" && \
    tar -xf Codescape.GNU.Tools.Package.2016.05-06.for.MIPS.MTI.Bare.Metal.CentOS-5.x86_64.tar.gz && \
    rm Codescape.GNU.Tools.Package.2016.05-06.for.MIPS.MTI.Bare.Metal.CentOS-5.x86_64.tar.gz

ENV PATH="${PWD}/mips-mti-elf/2016.05-06/bin:${PATH}"
