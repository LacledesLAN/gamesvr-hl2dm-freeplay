FROM lacledeslan/steamcmd AS ll-content-fetcher

ARG CONTENT_SERVER=content.lacledeslan.net

RUN echo $'\n\nDownloading LL custom content from content server' && \
        mkdir --parents /tmp/maps/ && \
        cd /tmp/maps/ && \
        wget -rkpN -l 1 -nH  --no-verbose --cut-dirs=3 -R "*.htm*" -e robots=off "http://"$CONTENT_SERVER"/fastDownloads/hl2dm/maps/" && \
    echo "Decompressing downloaded content" && \
        bzip2 --decompress /tmp/maps/*.bz2 && \
    echo "Moving uncompressed files to destination" && \
        mkdir /output/hl2mp/maps --parents && \
        mv -n *.bsp /output/hl2mp/maps;


# Metamod:Source (from https://www.metamodsource.net/)
COPY ./dist/mmsource-1.12.0-git1224-linux /output/hl2mp/

RUN true

# Sourcemod (from https://www.sourcemod.net/)
COPY ./dist/sourcemod-1.13.0-git7379-linux /output/hl2mp/

RUN true

# Sourcemod Simple Admins for LL IRL LAN Parties
COPY dist/sourcemod-custom-assets/sourcemod/configs/ll_lan_admins/admins_simple.ini /output/hl2mp/addons/sourcemod/configs/admins_simple.ini

RUN true

# Sourcemod Custom plugin - log connections
COPY dist/sourcemod-custom-assets/sourcemod/plugins/logconnections/logconnections-ll.smx /output/hl2mp/addons/sourcemod/plugins

RUN true

# Sourcemod Custom plugin - server status
COPY dist/sourcemod-custom-assets/sourcemod/plugins/serverstatus/serverstatus-ll.smx /output/hl2mp/addons/sourcemod/plugins

# Game content and configs
COPY ./dist/hl2mp /output/hl2mp/

RUN true


#---------------------------------
FROM lacledeslan/gamesvr-hl2dm

HEALTHCHECK NONE

ARG BUILD_DATE=unspecified \
    BUILD_NODE=unspecified \
    GIT_REVISION=unspecified

LABEL architecture="amd64" \
      com.lacledeslan.build-node="$BUILD_NODE" \
      maintainer="Laclede's LAN <contact@lacledeslan.com>" \
      org.opencontainers.image.created="$BUILD_DATE" \
      org.opencontainers.image.description="LL Half-Life 2 Deathmatch Dedicated Freeplay Server" \
      org.opencontainers.image.revision="$GIT_REVISION" \
      org.opencontainers.image.source="https://github.com/LacledesLAN/gamesvr-hl2dm-freeplay" \
      org.opencontainers.image.vendor="Laclede's LAN"

COPY --chown=HL2DM:root --from=ll-content-fetcher /output /app

# UPDATE USERNAME & ensure permissions
RUN usermod -l HL2DMFreeplay HL2DM;

USER HL2DMFreeplay

WORKDIR /app

CMD ["/bin/bash"]
