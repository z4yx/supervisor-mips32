FROM debian:buster

# install qemu-system-mips expect python3-serial for testing  
RUN apt-get update && \
    apt-get install -y curl make && \
    curl -sc /tmp/gcokie 'https://drive.google.com/uc?export=download&id=1Mo5hGcCg1zm8Ca0KQB-G5PNI3fXfAAmR' && \
    getcode="$(awk '/_warning_/ {print $NF}' /tmp/gcokie)" && \
    curl -s -C - -LOJb /tmp/gcokie "https://drive.google.com/uc?export=download&confirm=${getcode}&id=1Mo5hGcCg1zm8Ca0KQB-G5PNI3fXfAAmR" && \
    tar -xf Codescape.GNU.Tools.Package.2016.05-06.for.MIPS.MTI.Bare.Metal.CentOS-5.x86_64.tar.gz && \
    rm Codescape.GNU.Tools.Package.2016.05-06.for.MIPS.MTI.Bare.Metal.CentOS-5.x86_64.tar.gz

ENV PATH="${PWD}/mips-mti-elf/2016.05-06/bin:${PATH}"
