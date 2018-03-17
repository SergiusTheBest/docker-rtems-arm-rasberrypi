FROM ubuntu:17.10
MAINTAINER Sergey Podobry <sergey.podobry@gmail.com>
LABEL Description="rtems-arm-rasberrypi crosscompiler"

ENV DEBIAN_FRONTEND noninteractive
ENV TERM linux
ENV PATH="/opt/rtems/4.11/bin:${PATH}"
ENV RTEMS_MAKEFILE_PATH=/opt/rtems/4.11/arm-rtems4.11/raspberrypi

RUN echo == Installing dependencies... &&\
        apt-get update &&\
        apt-get install -y --no-install-recommends binutils make patch gcc g++ gdb pax python2.7-dev zlib1g-dev git bison flex texinfo bzip2 xz-utils unzip libtinfo-dev &&\
        ln -T /usr/bin/python2.7 /usr/bin/python &&\
    echo == Building crosscompiler... &&\
        mkdir -p $HOME/dev/rtems &&\
        cd $HOME/dev/rtems &&\
        git clone --branch 4.11.3 --depth 1 git://git.rtems.org/rtems-source-builder.git rsb &&\
        cd rsb &&\
        ./source-builder/sb-check &&\
        cd rtems &&\
        ../source-builder/sb-set-builder --prefix=/opt/rtems/4.11 4.11/rtems-arm &&\
    echo == Builing kernel... &&\
        cd $HOME/dev/rtems &&\
        git clone --branch 4.11.3 --depth 1 git://git.rtems.org/rtems.git kernel &&\
        cd kernel &&\
        ./bootstrap -c && ./bootstrap -p && ../rsb/source-builder/sb-bootstrap &&\
        cd .. && mkdir raspberrypi && cd raspberrypi &&\
        ../kernel/configure --prefix=/opt/rtems/4.11 --target=arm-rtems4.11 --enable-rtemsbsp=raspberrypi --enable-posix --enable-cxx &&\
        make -j && make install &&\
    echo == Cleaning up... &&\
        cd / &&\
        rm $HOME/dev -r &&\
        rm /opt/rtems/4.11/lib/gcc/arm-rtems4.11/4.9.3/thumb -r &&\
        rm /opt/rtems/4.11/lib/gcc/arm-rtems4.11/4.9.3/eb -r &&\
        rm /opt/rtems/4.11/arm-rtems4.11/lib/thumb -r &&\
        rm /opt/rtems/4.11/arm-rtems4.11/lib/eb -r &&\
    echo == Removing dependencies... &&\
        rm /usr/bin/python &&\
        apt-get --purge -y autoremove binutils make patch gcc g++ gdb pax python2.7-dev zlib1g-dev git bison flex texinfo bzip2 xz-utils unzip libtinfo-dev &&\
        rm -rf /var/lib/apt/lists/*
