# An environment to run sgx applications (DCAP drivers)

FROM ubuntu:20.04

RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# replace apt repo to a local one http://archive.ubuntu.com/ubuntu/ -> http://mirror.xtom.com.hk/ubuntu/
RUN sed -i 's/http:\/\/archive.ubuntu.com\/ubuntu/http:\/\/mirror.xtom.com.hk\/ubuntu/g' /etc/apt/sources.list

# install prerequisites
RUN DEBIAN_FRONTEND=noninteractive apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y software-properties-common && \
    DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y git build-essential ocaml ocamlbuild automake autoconf libtool wget python-is-python3 libssl-dev git cmake perl vim libelf-dev libssl-dev libcurl4-openssl-dev protobuf-compiler libprotobuf-dev debhelper cmake reprepro unzip

# from linux kernel 5.11, sgx-driver is enabled in-kernel    

#Install SGX PSW/SDK
WORKDIR /home/sgx/
RUN git clone https://github.com/intel/linux-sgx.git

WORKDIR /home/sgx/linux-sgx/
RUN make preparation && \
    cp external/toolset/ubuntu20.04/{as,ld,ld.gold,objdump} /usr/local/bin/ && \
    make sdk_install_pkg DEBUG=1 && \
    echo -e "no\n/opt/intel/" |  linux/installer/bin/sgx_linux_x64_sdk_2.14.100.2.bin && \
    export DEB_BUILD_OPTIONS="nostrip" && \
    make deb_psw_pkg DEBUG=1

WORKDIR /home/sgx/linux-sgx/linux/installer/deb/
RUN dpkg -i libsgx-headers/libsgx-headers_2.14.100.2-focal1_amd64.deb && \
    dpkg -i libsgx-enclave-common/libsgx-enclave-common_2.14.100.2-focal1_amd64.deb && \
    dpkg -i libsgx-enclave-common/libsgx-enclave-common-dev_2.14.100.2-focal1_amd64.deb && \
    dpkg -i libsgx-urts/libsgx-urts_2.14.100.2-focal1_amd64.deb && \
    dpkg -i libsgx-launch/libsgx-launch_2.14.100.2-focal1_amd64.deb && \
    dpkg -i libsgx-launch/libsgx-launch-dev_2.14.100.2-focal1_amd64.deb

WORKDIR /home/sgx/

RUN source /opt/intel/sgxsdk/environment

CMD [ "/bin/bash" ]