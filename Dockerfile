FROM ubuntu:latest

ARG hlds_build=7882
ARG metamod_version=1.21p38
ARG amxmod_version=1.8.2
ARG steamcmd_url=https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
ARG hlds_url="https://github.com/DevilBoy-eXe/hlds/releases/download/$hlds_build/hlds_build_$hlds_build.zip"
ARG metamod_url="https://github.com/Bots-United/metamod-p/releases/download/v$metamod_version/metamod_i686_linux_win32-$metamod_version.tar.xz"
ARG amxmod_url="http://www.amxmodx.org/release/amxmodx-$amxmod_version-base-linux.tar.gz"

# Fix warning:
# WARNING: setlocale('en_US.UTF-8') failed, using locale: 'C'.
# International characters may not work.
RUN apt-get update && apt-get install -y --no-install-recommends \
    locales \
 && rm -rf /var/lib/apt/lists/* \
 && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8
ENV LC_ALL en_US.UTF-8

RUN groupadd -r steam && useradd -r -g steam -m -d /opt/steam steam

RUN apt-get -y update && apt-get install -y software-properties-common
RUN add-apt-repository multiverse
RUN dpkg --add-architecture i386
RUN apt-get -y update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    lib32gcc-s1 \
    unzip \
    xz-utils \
    zip \
    iproute2 \
 && apt-get -y autoremove \
 && rm -rf /var/lib/apt/lists/*

USER steam
WORKDIR /opt/steam
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
COPY ./lib/hlds.install /opt/steam

RUN curl -sL "$steamcmd_url" | tar xzvf - \
    && ./steamcmd.sh +runscript hlds.install

RUN curl -sLJO "$hlds_url" \
    && unzip "hlds_build_$hlds_build.zip" -d "/opt/steam" \
    && cp -R "hlds_build_$hlds_build"/* hlds/ \
    && rm -rf "hlds_build_$hlds_build" "hlds_build_$hlds_build.zip"

# Fix error that steamclient.so is missing
RUN mkdir -p "$HOME/.steam" \
    && ln -s /opt/steam/linux32 "$HOME/.steam/sdk32"


WORKDIR /opt/steam/hlds

# Copy default config
ADD --chown=steam files/steam_appid.txt steam_appid.txt
COPY --chown=steam cstrike cstrike
COPY --chown=steam cstrike /mnt/cstrike
ADD --chown=steam files/mapcycle.txt cstrike/mapcycle.txt
ADD --chown=steam files/server.cfg cstrike/server.cfg
ADD --chown=steam lib/dproto/dproto.cfg cstrike/dproto.cfg
RUN cp -r valve/media cstrike/media

# Make changes on files
# Add admins
# RUN echo "STEAM_0:0:76561198001098515" "" "abcdefghijklmnopqrstu" "ce" >> /opt/steam/hlds/cstrike/addons/amxmodx/configs/users.ini

RUN chmod +x hlds_run hlds_linux
EXPOSE 27015
EXPOSE 27015/udp
EXPOSE 80/tcp

ADD hlds_run.sh /bin/hlds_run.sh

# Start server
ENTRYPOINT ["/bin/bash", "/bin/hlds_run.sh"]