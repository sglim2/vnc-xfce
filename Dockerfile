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
        bzip2-devel \
        dbus-x11 \
        cmake \
        curl \
        environment-modules \
        https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm \
        expat-devel \
        firefox \
        freeglut \
        freeglut-devel \
        glibc-common \
        glx-utils \
        gmp-devel \
        gnuplot \
        hostname \
        java \
        libmpc-devel \
        libpng \
        libpng-devel \
        libtool \
        libxml2-devel \
        lmdb-libs \
        #lmdb-devel \
        man \
        man-db \
        man-pages \
        mesa-dri-drivers \
        mpfr-devel \
        mpich \
        mpich-devel \
        ncurses-devel \
        net-tools \
        openmpi \
        openmpi-devel \
        openssh-server \
        parallel \
        passwd \
        pigz \
        python3-numpy \
        #R \
        stress-ng \
        syslog-ng \
        tree \
        unzip \
        xauth \
        #xeyes \
        xorg-x11-utils \
        xz-devel \
        zenity \
        zlib-devel \
        gcc \
        gcc-gfortran \
        git \
        tar \
        libpng \
        libpng-devel \
        hostname \
        lmdb-libs \
        make \
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

RUN cd ~ && \
    wget https://downloads.openmicroscopy.org/bio-formats/5.5.2/artifacts/bftools.zip && \
    unzip bftools.zip && \
    echo 'export PATH="$HOME/bftools:$PATH"'>> $HOME/.bashrc

RUN pip3 install xmltodict dicttoxml psutil snakemake







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
    
COPY github_key . 

COPY requirements.txt .

RUN chmod 600 github_key && \
    chmod 600 requirements.txt && \
    eval $(ssh-agent) && \
    ssh-add github_key && \
    ssh-keyscan -H github.com >> /etc/ssh/ssh_known_hosts && \
    git clone git@github.com:jbleddyn/misc_python.git /opt/misc_python
    
    
RUN wget -O /tmp/pycharm.tar.gz "https://download.jetbrains.com/python/pycharm-community-2022.2.tar.gz?_ga=2.203649815.689967100.1659698104-1332970678.1659698104&_gl=1*6pacqh*_ga*MTMzMjk3MDY3OC4xNjU5Njk4MTA0*_ga_9J976DJZ68*MTY1OTY5ODEwNC4xLjEuMTY1OTcwMDg0MC4w" && \
    cd /tmp && \
    tar fvxz pycharm.tar.gz -C /opt && \
    pip3 install -r requirements.txt 
    
    
    



# USER 1000

ENTRYPOINT ["/dockerstartup/vnc_startup.sh"]
CMD ["--wait"]
