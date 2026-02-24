FROM i386/debian:bookworm-slim

WORKDIR /root/build
ENV DEBIAN_FRONTEND=noninteractive

# 1. Base Setup
RUN rm -f /etc/apt/sources.list.d/* && \
    echo "deb http://mirrors.ustc.edu.cn/debian/ bookworm main contrib non-free non-free-firmware\n\
    deb http://mirrors.ustc.edu.cn/debian/ bookworm-updates main contrib non-free non-free-firmware\n\
    deb http://mirrors.ustc.edu.cn/debian/ bookworm-backports main contrib non-free non-free-firmware\n\
    deb http://security.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware" > /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    linux-image-686 \
    systemd-sysv \
    locales \
    libterm-readline-perl-perl \
    && rm -rf /var/lib/apt/lists/*

# 2. Configure Locales & Shell
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
    locale-gen && \
    echo 'LANG="en_US.UTF-8"' > /etc/default/locale && \
    chsh -s /bin/bash root  

# 3. Install Minimal X11, XFCE4 Desktop, Input Drivers, Fonts, and Networking
# MODIFICATION: Added sed command to revert to official Debian repos after installation
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    xserver-xorg-core xserver-xorg-video-fbdev xinit \
    xfce4 xfce4-terminal \
    xserver-xorg-input-mouse xserver-xorg-input-kbd xserver-xorg-input-evdev \
    libxext6 libxrender1 libxtst6 libxi6 libx11-xcb1 libxrender-dev \
    libfontconfig1 fonts-dejavu-core adwaita-icon-theme fonts-wqy-microhei fonts-symbola \
    wget tar unzip ca-certificates xterm \
    xdg-utils shared-mime-info dbus-x11 desktop-base \
    thunar-archive-plugin xfce4-taskmanager ristretto \
    gvfs fonts-liberation xfce4-notifyd gvfs-backends \
    isc-dhcp-client iproute2 iputils-ping sudo netsurf-gtk \
    # Biology
    seaview jemboss bedtools critterding neuron samtools bcftools bwa cd-hit \
    # Chemistry
    xdrawchem quantum-espresso nwchem avogadro pymol ghemical bkchem adun.app garlic jmol apbs atomes chemtool cp2k drawxtl mopac7-bin mpqc openbabel-gui pdb2pqr tandem-mass \
    # Electronics
    kicad fritzing simulide \
    # Engineering
    freecad librecad calculix-cgx calculix-ccx gmsh sumo openfoam \
    # Geography
    qgis grass-gui \
    # Geometry
    geogebra polymake carmetal \
    # Image Analysis
    imagej gwyddion \
    # Logic
    coq z3 tkgate gprolog \
    # Machine Learning
    weka \
    # Mathematics
    sagemath wxmaxima gap macaulay2 singular pari-gp 4ti2 coinor-cbc coinor-csdp \
    # Meteorology
    cdo ferret \
    # Numerical Computation
    octave gnudatalanguage jupyter-notebook \
    # Physics
    yade opticalraytracer abinit cadabra2 gerris v-sim liggghts lammps getdp esys-particle z88 \
    # Statistics
    rkward pspp jags fityk \
    # Typesetting
    texlive-base texlive-science texlive-pictures texstudio lyx ipe jabref \
    # Viewing
    paraview grace veusz gnuplot-qt mathgl labplot udav geomview xyscan povray \
    # Utilities
    xournal planner abiword gnumeric pandoc cmake git tmux mc htop vim nano p7zip-full geany mousepad atril engrampa artha openmpi-bin python3-pip curl build-essential ffmpeg \
    && sed -i 's|http://mirrors.ustc.edu.cn/debian/|http://deb.debian.org/debian/|g' /etc/apt/sources.list \
    && rm -rf /var/lib/apt/lists/*

# 4. Configure Root and Standard User ('username')
RUN passwd -d root && \
    sed -i 's/nullok_secure/nullok/' /etc/pam.d/common-auth && \
    useradd -m -s /bin/bash username && \
    passwd -d username && \
    usermod -aG sudo,video,tty,input,dialout username && \
    echo "username ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# 5. Configure Serial Console Auto-login
COPY getty-noclear.conf getty-override.conf /etc/systemd/system/getty@tty1.service.d/
COPY getty-autologin-serial.conf /etc/systemd/system/serial-getty@ttyS0.service.d/

# Swap 'root' for 'username' in the copied serial login configurations
RUN sed -i 's/autologin root/autologin username/g' /etc/systemd/system/serial-getty@ttyS0.service.d/getty-autologin-serial.conf && \
    sed -i 's/autologin root/autologin username/g' /etc/systemd/system/getty@tty1.service.d/getty-override.conf || true

# 6. Disable Unnecessary Services
RUN systemctl disable systemd-timesyncd.service && \
    systemctl disable apt-daily.timer && \
    systemctl disable apt-daily-upgrade.timer

# ------------------------------------------------------------------------------
# 7. 9p Filesystem Boot Configuration
# ------------------------------------------------------------------------------
RUN printf '%s\n' 9p 9pnet 9pnet_virtio virtio virtio_ring virtio_pci | tee -a /etc/initramfs-tools/modules

RUN echo '#!/bin/sh' > /etc/initramfs-tools/scripts/boot-9p && \
    echo 'case $1 in prereqs) exit 0;; esac' >> /etc/initramfs-tools/scripts/boot-9p && \
    echo '. /scripts/functions' >> /etc/initramfs-tools/scripts/boot-9p && \
    echo 'mkdir -p ${rootmnt}' >> /etc/initramfs-tools/scripts/boot-9p && \
    echo 'mount -n -t 9p -o trans=virtio,version=9p2000.L,cache=loose,rw host9p ${rootmnt}' >> /etc/initramfs-tools/scripts/boot-9p && \
    chmod +x /etc/initramfs-tools/scripts/boot-9p

RUN echo 'BOOT=boot-9p' | tee -a /etc/initramfs-tools/initramfs.conf
RUN update-initramfs -u

# 8. Configure X11, Networking, and Auto-start for 'username'
RUN echo '(sleep 5 && sudo bash -c "printf \"\\n\\nGUI_READY\\n\" > /dev/ttyS0") & \n\
exec startxfce4' > /home/username/.xinitrc

RUN { \
    echo 'if [ -z "$DISPLAY" ]; then'; \
    echo '  sudo bash -c "echo 127.0.0.1 localhost > /etc/hosts"'; \
    echo '  sudo bash -c "echo localhost > /etc/hostname"'; \
    echo '  sudo hostname localhost'; \
    echo '  startx -- -ac'; \
    echo 'fi'; \
} >> /home/username/.bashrc

RUN chown username:username /home/username/.xinitrc /home/username/.bashrc

# 9. Force Xorg to use the FBDEV driver
RUN mkdir -p /etc/X11/xorg.conf.d && \
    echo 'Section "Device"\n\
    Identifier "Card0"\n\
    Driver "fbdev"\n\
EndSection' > /etc/X11/xorg.conf.d/10-fbdev.conf

WORKDIR /home/username