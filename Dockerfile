FROM quay.io/centos/centos:stream

MAINTAINER Bleddyn Williams "williamsjm14@Cardiff.ac.uk"

ENV DISPLAY=:1 \
    VNC_PORT=5901 \
    NO_VNC_PORT=6901
EXPOSE $VNC_PORT $NO_VNC_PORT

### Envrionment config
ENV HOME=/home/centos \
    TERM=xterm \
    STARTUPDIR=/dockerstartup \
    INST_SCRIPTS=/headless/install \
    NO_VNC_HOME=/headless/noVNC \
    NO_VNC_VERSION=v1.0.0 \
    WEBSOCKIFY_VERSION=v0.9.0 \
    VNC_COL_DEPTH=24 \
    VNC_RESOLUTION=1920x1080 \
    VNC_PW=novncpassword \
    VNC_VIEW_ONLY=false
WORKDIR $HOME


### Add all install scripts for further steps
ADD ./install_scripts/ $INST_SCRIPTS/
RUN find $INST_SCRIPTS -name '*.sh' -exec chmod a+x {} +

### Install some common tools
RUN dnf -y --enablerepo=extras install epel-release && \
    dnf -y update && \
    dnf -y install python39 python39-devel && \
    alternatives --set python /usr/bin/python3 && \
    dnf -y install \
        bzip2 \
        curl \
        environment-modules \
        https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm \
        gcc \
        gcc-gfortran \
        git \
        tar \
        libpng \
        libpng-devel \
        hostname \
        lmdb-libs \
        make \
        man \
        man-db \
        man-pages \
        mpich \
        mpich-devel \
        nano \
        net-tools \
        openmpi \
        openmpi-devel \
        passwd \
        python3-numpy \
        vim \
        wget \
        which && \
    dnf -y groupinstall "Development tools" && \
    dnf install -y \
    openssl-devel \
    libuuid-devel \
    libseccomp-devel \
    squashfs-tools && \
    dnf config-manager --set-enabled powertools && \
    dnf clean all && \
    rm -rf /var/cache/dnf

RUN touch /usr/share/Modules/init/.modulespath && chmod 666 /usr/share/Modules/init/.modulespath
RUN dnf group install -y "Development tools" && \
    dnf clean all && \
    rm -rf /var/dnf/cache

RUN wget https://dl.google.com/go/go1.13.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.13.linux-amd64.tar.gz && \
    echo 'export PATH=$PATH:/usr/local/go/bin'>> $HOME/.bashrc
RUN dnf install -y singularity-runtime singularity


#ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

### Install xvnc-server & noVNC - HTML5 based VNC viewer
#RUN $INST_SCRIPTS/tigervnc.sh
#RUN $INST_SCRIPTS/no_vnc.sh
RUN dnf -y install tigervnc-server tigervnc-server-minimal && \
    dnf clean all && \
    rm -rf /var/cache/dnf

RUN mkdir -p $NO_VNC_HOME/utils/websockify && \
    curl -L https://github.com/novnc/noVNC/archive/${NO_VNC_VERSION}.tar.gz | tar xz --strip 1 -C $NO_VNC_HOME  && \
    curl -L https://github.com/novnc/websockify/archive/${WEBSOCKIFY_VERSION}.tar.gz | tar xz --strip 1 -C $NO_VNC_HOME/utils/websockify && \
    chmod +x -v $NO_VNC_HOME/utils/*.sh && \
    ln -s $NO_VNC_HOME/vnc.html $NO_VNC_HOME/index.html


RUN dnf clean all

RUN dnf install -y chromium

#RUN $INST_SCRIPTS/xfce_ui.sh
RUN dnf install -y \
        gnome-keyring \
        Thunar \
        xfce4-panel \
        xfce4-session \
        xfce4-terminal \
        xfdesktop \
        xfwm4 && \
    dnf clean all && \
    rm -rf /var/cache/dnf && \
    rm -f /etc/xdg/autostart/xfce-polkit* && \
    /bin/dbus-uuidgen > /etc/machine-id
ADD ./xfce/ $HOME/

# allow execute as non-root
RUN dnf install -y \
        gettext \
        nss_wrapper && \
    dnf clean all && \
    rm -rf /var/cache/dnf


# modules
RUN echo 'source /etc/profile.d/modules.sh' >> $HOME/.bashrc

### configure startup
RUN $INST_SCRIPTS/libnss_wrapper.sh
ADD ./startupdir $STARTUPDIR

RUN chmod -R a+rw $HOME && \
    chmod -R a+rw $STARTUPDIR

RUN mkdir -p /home/LOCOEFA &&\
    cd /home/LOCOEFA &&\
    git clone https://bitbucket.org/mareelab/loco_efa.git

USER 1000

ENTRYPOINT ["/dockerstartup/vnc_startup.sh"]
CMD ["--wait"]
