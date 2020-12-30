
FROM debian:buster AS base

USER root


ENV USER aaeon
ENV PASS aaeon
ENV HOME /home/aaeon

# setting proxy for apt
RUN bash -c 'if test -n "$http_proxy"; then\
               echo "Acquire::http::proxy\"$http_proxy\";"\
                > /etc/apt/apt.conf.d/99proxy; \
             fi'

RUN apt update && apt upgrade -y && apt install -y --no-install-recommends \
	binfmt-support qemu qemu-user-static debootstrap kpartx \
	lvm2 dosfstools gpart binutils git git-core sudo ca-certificates \
	lib32ncurses5-dev python-m2crypto gawk wget diffstat unzip \
	gcc-multilib build-essential chrpath socat libsdl1.2-dev \
	autoconf automake sed cvs subversion make gcc g++ \
	libtool libglib2.0-dev libarchive-dev python-git xterm \
	coreutils libglu1-mesa-dev mercurial groff asciidoc \
	u-boot-tools mtd-utils curl lzop texinfo texi2html \
	docbook-utils python-pysqlite2 help2man \
	desktop-file-utils libgl1-mesa-dev kmod \
	bc libssl-dev bison flex device-tree-compiler asciidoc \
	python3 python3-pip vim locales \
  	$( \
      		if apt-cache show 'iproute' 2>/dev/null | grep -q '^Version:'; then \
        	echo 'iproute'; \
      		else \
        	echo 'iproute2'; \
      		fi \
  	) \
  	&& rm -rf /var/lib/apt/lists/* \
  	&& c_rehash \
  	&& echo '#!/bin/sh\n\
		set -e\n\
		set -u\n\
		export DEBIAN_FRONTEND=noninteractive\n\
		n=0\n\
		max=2\n\
		until [ $n -gt $max ]; do\n\
  			set +e\n\
  			(\n\
    				apt-get update -qq &&\n\
    			apt-get install -y --no-install-recommends "$@"\n\
  			)\n\
  			CODE=$?\n\
  			set -e\n\
  			if [ $CODE -eq 0 ]; then\n\
    				break\n\
  			fi\n\
  			if [ $n -eq $max ]; then\n\
    				exit $CODE\n\
  			fi\n\
  			echo "apt failed, retrying"\n\
  			n=$(($n + 1))\n\
		done\n\
		rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*' > /usr/sbin/install_packages \
  	&& chmod 0755 "/usr/sbin/install_packages"

# Set the locale
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
ENV DEBIAN_FRONTEND noninteractive
ENV UDEV off

ARG USER_ID=1000
ARG GROUP_ID=1000
ARG SHELL=/bin/bash
ARG WORK_DIR=/home/aaeon/works

RUN groupadd --gid $GROUP_ID $USER && useradd -s $SHELL --gid $GROUP_ID --uid $USER_ID --create-home $USER && usermod -a -G sudo $USER
RUN echo "$USER:$PASS" | chpasswd && echo "%$USER  ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/aaeongrp
RUN chmod 0440 /etc/sudoers.d/aaeongrp

ADD gitproxy /usr/bin
RUN chmod +x /usr/bin/gitproxy
RUN bash -c 'if test -n "$http_proxy"; then\
               sed -i -e "s#\(http_proxy=\"\).*#\1$http_proxy\"#"/usr/bin/gitproxy;\
             fi'

# change user
USER $USER
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# setting git proxy if need
RUN bash -c 'if test -n "$http_proxy"; then\
              git config --global http.proxy "$http_proxy";\
              git config --global core.gitproxy gitproxy;\
             fi'

RUN bash -c 'if test -n "$https_proxy"; then\
              git config --global https.proxy "$https_proxy";\
             fi'

RUN bash -c 'if test -n "$no_proxy"; then\
              git config --global core.noproxy "$no_proxy";\
             fi'

WORKDIR $WORK_DIR

