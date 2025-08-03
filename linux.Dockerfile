# escape=`
FROM lacledeslan/steamcmd AS ll-content-fetcher

ARG contentServer=content.lacledeslan.net

RUN echo $'\n\nDownloading LL custom content from content server' &&`
        mkdir --parents /tmp/maps/ &&`
        cd /tmp/maps/ &&`
        wget -rkpN -l 1 -nH  --no-verbose --cut-dirs=3 -R "*.htm*" -e robots=off "http://"$contentServer"/fastDownloads/hl2dm/maps/" &&`
    echo "Decompressing downloaded content" &&`
        bzip2 --decompress /tmp/maps/*.bz2 &&`
    echo "Moving uncompressed files to destination" &&`
        mkdir /output/hl2mp/maps --parents &&`
        mv -n *.bsp /output/hl2mp/maps;

COPY ./sourcemod.linux /output/hl2mp/

COPY ./sourcemod-configs /output/hl2mp/

COPY ./dist /output/

#=======================================================================

FROM lacledeslan/gamesvr-hl2dm

HEALTHCHECK NONE

ARG BUILDNODE="unspecified"
ARG SOURCE_COMMIT

LABEL com.lacledeslan.build-node=$BUILDNODE `
      org.label-schema.schema-version="1.0" `
      org.label-schema.url="https://github.com/LacledesLAN/README.1ST" `
      org.label-schema.vcs-ref=$SOURCE_COMMIT `
      org.label-schema.vendor="Laclede's LAN" `
      org.label-schema.description="LL Half-Life 2 Deathmatch Dedicated Freeplay Server" `
      org.label-schema.vcs-url="https://github.com/LacledesLAN/gamesvr-hl2dm"

COPY --chown=HL2DM:root --from=ll-content-fetcher /output /app

# UPDATE USERNAME & ensure permissions
RUN usermod -l HL2DMFreeplay HL2DM &&`
    chmod +x /app/ll-tests/*.sh;

USER HL2DMFreeplay

WORKDIR /app

CMD ["/bin/bash"]

ONBUILD USER root
