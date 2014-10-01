FROM ubuntu:trusty

MAINTAINER Joshua Gardner mellowcellofellow@gmail.com

# Set Locale

RUN locale-gen en_US.UTF-8  
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8

# Enable Universe and Multiverse and install dependencies.

RUN echo deb http://archive.ubuntu.com/ubuntu precise universe multiverse >> /etc/apt/sources.list; apt-get update; apt-get -y install autoconf automake build-essential git mercurial cmake libass-dev libgpac-dev libtheora-dev libtool libvdpau-dev libvorbis-dev pkg-config texi2html zlib1g-dev libmp3lame-dev wget yasm; apt-get clean

# Fetch Sources

RUN cd /usr/local/src; git clone --depth 1 git://git.videolan.org/x264.git
RUN cd /usr/local/src; hg clone https://bitbucket.org/multicoreware/x265
RUN cd /usr/local/src; git clone --depth 1 git://github.com/mstorsjo/fdk-aac.git
RUN cd /usr/local/src; git clone --depth 1 https://chromium.googlesource.com/webm/libvpx
RUN cd /usr/local/src; git clone --depth 1 git://source.ffmpeg.org/ffmpeg
RUN cd /usr/local/src; wget http://downloads.xiph.org/releases/opus/opus-1.1.tar.gz

# Build libx264

RUN cd /usr/local/src/x264; ./configure --enable-static; make -j 4; make install; make distclean

# Build libx265

RUN cd /usr/local/src/x265/build/linux; cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr ../../source; make -j 4; make install; make clean

# Build libfdk-aac

RUN cd /usr/local/src/fdk-aac; autoreconf -fiv; ./configure --disable-shared; make -j 4; make install; make distclean

# Build libvpx

RUN cd /usr/local/src/libvpx; ./configure --disable-examples; make -j 4; make install; make clean

# Build libopus

RUN cd /usr/local/src; tar zxvf opus-1.1.tar.gz; cd opus-1.1; ./configure --disable-shared; make -j 4; make install; make distclean

# Build ffmpeg.

RUN cd /usr/local/src/ffmpeg; ./configure --extra-libs="-ldl" --enable-gpl --enable-libass --enable-libfdk-aac --enable-libmp3lame --enable-libopus --enable-libtheora --enable-libvorbis --enable-libvpx --enable-libx264 --enable-libx265 --enable-nonfree; make -j 4; make install; make distclean; hash -r
