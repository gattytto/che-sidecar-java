# Copyright (c) 2019 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#
# Contributors:
#   Red Hat, Inc. - initial API and implementation

FROM alpine:3.12

ENV HOME=/home/theia
ENV GRADLE_HOME /opt/gradle
ENV GRADLE_VERSION 6.6.1

ARG GRADLE_DOWNLOAD_SHA256=7873ed5287f47ca03549ab8dcb6dc877ac7f0e3d7b1eb12685161d10080910ac

RUN set -o errexit -o nounset \
	&& echo "Installing dependencies" \
	&& apk add --no-cache \
		bash \
		libstdc++ \
	\
	&& echo "Installing build dependencies" \
	&& apk add --no-cache --virtual .build-deps \
		ca-certificates \
		openssl \
		unzip \
	\
	&& echo "Downloading Gradle" \
	&& wget -O gradle.zip "https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip" \
	\
	&& echo "Checking download hash" \
	&& echo "${GRADLE_DOWNLOAD_SHA256} *gradle.zip" | sha256sum -c - \
	\
	&& echo "Installing Gradle" \
	&& unzip gradle.zip \
	&& rm gradle.zip \
	&& mv "gradle-${GRADLE_VERSION}" "${GRADLE_HOME}/" \
	&& ln -s "${GRADLE_HOME}/bin/gradle" /usr/bin/gradle \
	\
	&& apk del .build-deps && \
	wget https://github.com/JetBrains/kotlin/releases/download/v1.4.10/kotlin-compiler-1.4.10.zip && \
	unzip kotlin-compiler-1.4.10.zip && cp kotlinc/bin/* /usr/bin/ && cp kotlinc/lib/* /opt/gradle/lib/ &&\
	rm -rf kotlin-compiler-1.4.10.zip kotlinc
	


RUN mkdir /projects ${HOME} ${HOME}/.gradle && \
    # Change permissions to let any arbitrary user
    for f in "${HOME}" "/etc/passwd" "/projects" "/opt"; do \
      echo "Changing permissions on ${f}" && chgrp -R 0 ${f} && \
      chmod -R g+rwX ${f}; \
    done

RUN apk --no-cache add openjdk11 --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community \
    && apk add procps nss
ENV JAVA_HOME /usr/lib/jvm/default-jvm/
ADD etc/before-start.sh /before-start.sh

WORKDIR /projects

ADD etc/entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
CMD ${PLUGIN_REMOTE_ENDPOINT_EXECUTABLE}

