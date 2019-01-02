FROM       ubuntu:16.04
MAINTAINER hyungjoon.lee@subicura.com

RUN apt-get -y update
RUN apt-get install -y apt-utils
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

RUN apt-get install -y -qq git
RUN apt-get install -y -qq cmake
RUN apt-get install -y -qq vim
RUN apt-get install -y -qq g++
RUN apt-get install -y -qq libyajl-dev
RUN apt-get install -y -qq pkg-config
RUN apt-get install -y -qq glib2.0
RUN apt-get install -y -qq liburiparser-dev
RUN apt-get install -y -qq gperf
RUN apt-get install -y -qq lemon
RUN apt-get install -y -qq flex
RUN apt-get install -y -qq libboost-all-dev
RUN apt-get install -y -qq libgmp3-dev
RUN apt-get install -y -qq dh-autoreconf
RUN apt-get install -y -qq libjson-c-dev
RUN apt-get install -y -qq libcurl4-openssl-dev
RUN apt-get install -y -qq libgtest-dev
RUN apt-get install -y -qq libsqlite3-dev
RUN apt-get install -y -qq libssl-dev
RUN apt-get install -y -qq libgtest-dev
RUN apt-get install -y -qq openssh-server
RUN apt-get install -y -qq libc6-dbg gdb valgrind

COPY ./cmake-modules-webos /source/cmake-modules-webos
RUN cd /source/cmake-modules-webos && \
    mkdir build && \
    cd build && \
    cmake ../ && \
    make install

COPY ./libpbnjson  /source/libpbnjson
RUN cd /source/libpbnjson/ && \
    mkdir build && \
    cd build && \
    cmake ../ && \
    make && \
    make install

COPY ./pmloglib /source/pmloglib
RUN cd /source/pmloglib/ && \
    mkdir build && \
    cd build && \
    cmake ../ && \
    make && \
    make install

COPY ./luna-service2 /source/luna-service2
RUN cd /source/luna-service2/ && \
    mkdir build && \
    cd build && \
    cmake ../ && \
    make && \
    make install

COPY ./faultmanager /source/faultmanager
RUN cd /source/faultmanager/ && \
    mkdir build && \
    cd build && \
    cmake ../ -DCMAKE_EXE_LINKER_FLAGS='-lpbnjson_c' && \
    make && \
    make install

RUN mkdir -p /usr/local/webos/usr/src/gtest && \
    cp -r /usr/src/gtest/* /usr/local/webos/usr/src/gtest

RUN mkdir /var/run/sshd
RUN echo 'root:root' | chpasswd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

RUN echo '156.147.61.49 wall.lge.com' >> /etc/hosts
RUN ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa -C 'hyungjoon.lee@lge.com'

RUN echo 'export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/local/webos/usr/lib' >> /root/.bashrc

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
