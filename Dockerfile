FROM alpine:3.9

# Default to UTF-8 file.encoding
ENV LANG C.UTF-8

# add a simple script that can auto-detect the appropriate JAVA_HOME value
# based on whether the JDK or only the JRE is installed
RUN { \
		echo '#!/bin/sh'; \
		echo 'set -e'; \
		echo; \
		echo 'dirname "$(dirname "$(readlink -f "$(which javac || which java)")")"'; \
	} > /usr/local/bin/docker-java-home \
	&& chmod +x /usr/local/bin/docker-java-home
ENV JAVA_HOME /usr/lib/jvm/java-1.8-openjdk
ENV PATH $PATH:/usr/lib/jvm/java-1.8-openjdk/jre/bin:/usr/lib/jvm/java-1.8-openjdk/bin

ENV JAVA_VERSION 8u191
ENV JAVA_ALPINE_VERSION 8.191.12-r0
# Mule zip distribute finename without '.zip'
ENV MULE_ZIP_NAME mule-standalone-4.1.5

# add glibc and openjdk8
RUN set -x \
	&& apk add --no-cache \
		ca-certificates wget \
        openjdk8="$JAVA_ALPINE_VERSION" \
        unzip \
    && wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
	&& wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.29-r0/glibc-2.29-r0.apk \
	&& [ "$JAVA_HOME" = "$(docker-java-home)" ] \
    && apk add --no-cache glibc-2.29-r0.apk

RUN mkdir mule
ADD ${MULE_ZIP_NAME}.zip /mule
RUN cd mule \
    && unzip ${MULE_ZIP_NAME}.zip \
    && rm ${MULE_ZIP_NAME}.zip

RUN ln -s /mule/${MULE_ZIP_NAME}/apps /mule/apps
RUN ln -s /mule/${MULE_ZIP_NAME}/domains /mule/domains
WORKDIR /mule/${MULE_ZIP_NAME}/bin
CMD [ "./mule" ]