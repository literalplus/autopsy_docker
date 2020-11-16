FROM adoptopenjdk:8-jdk-hotspot

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
        apt-utils \
        curl \
        dnsutils \
        libafflib0v5 \
        libafflib-dev \
        libboost-all-dev \
        libboost-dev \
        libc3p0-java \
        libewf2 \
        libewf-dev \
        libpostgresql-jdbc-java \
        libpq5 \
        libsqlite3-dev \
        libvhdi1 \
        libvhdi-dev \
        libvmdk1 \
        libvmdk-dev \
        openjfx \
        testdisk \
        unzip \
        wget \
        xauth \
        x11-apps \
        x11-utils \
        x11proto-core-dev \
        x11proto-dev \
        xkb-data \
        xorg-sgml-doctools \
        xtrans-dev \
    && rm -rf /var/lib/apt/lists/*

# Use older versions still on Java 8, apparently they upgraded
# but didn't change the docs? Java 11 does not work out of the box.
# Change to latest for latest versions.
ENV AUTOPSY_VERSION=tag/autopsy-4.16.0
ENV TSK_VERSION=tag/sleuthkit-4.10.0

RUN RELEASE_PATH=`curl -sL https://github.com/sleuthkit/autopsy/releases/$AUTOPSY_VERSION \
        | grep -Eo 'href=".*.zip' \
        | grep -v archive \
        | head -1 \
        | cut -d '"' -f 2` \
    && mkdir -p /opt \
    && cd /opt \
    && curl -L https://github.com/${RELEASE_PATH} > autopsy.zip \
    && mkdir autopsy \
    && unzip -d autopsy autopsy.zip \
    && mv autopsy/autopsy*/* autopsy/. \
    && rm autopsy.zip \
    && RELEASE_PATH=`curl -sL https://github.com/sleuthkit/sleuthkit/releases/$TSK_VERSION \
        | grep -Eo 'href=".*\.deb' \
        | grep -v archive \
        | head -1 \
        | cut -d '"' -f 2` \
    && curl -L https://github.com/${RELEASE_PATH} > tsk_java.deb \
    && dpkg -i tsk_java.deb \
        || apt-get install -fy \
    && cd /opt \
    && cd /opt/autopsy*/
RUN cd /opt/autopsy && \
    sh ./unix_setup.sh
ENV PATH /opt/autopsy/bin:/opt/java/openjdk/bin:$PATH

ENTRYPOINT ["autopsy"]
