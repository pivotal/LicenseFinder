FROM ubuntu:jammy

WORKDIR /tmp

# Versioning
ENV PIP3_INSTALL_VERSION 20.0.2
ENV GO_LANG_VERSION 1.17.13
ENV SBT_VERSION 1.3.3
ENV GRADLE_VERSION 5.6.4
ENV RUBY_VERSION 3.2.2
ENV COMPOSER_ALLOW_SUPERUSER 1

# programs needed for building
RUN apt -q update && apt install -y \
    build-essential \
    curl \
    unzip \
    wget \
    gnupg2 \
    apt-utils \
    software-properties-common \
    bzr && \
    rm -rf /var/lib/apt/lists/*

RUN add-apt-repository ppa:git-core/ppa && \
    apt -q update && apt install -y git && rm -rf /var/lib/apt/lists/*

# install nodejs
RUN curl -sL https://deb.nodesource.com/setup_18.x | bash - && \
    apt -q update && apt install -y nodejs && rm -rf /var/lib/apt/lists/*

# install yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt -q update && apt install -y yarn && rm -rf /var/lib/apt/lists/*

# install bower
RUN npm install -g bower && \
    echo '{ "allow_root": true }' > /root/.bowerrc

# install pnpm
RUN npm install -g pnpm && \
    pnpm version

# install jdk 12
RUN curl -L -o openjdk12.tar.gz https://download.java.net/java/GA/jdk12.0.2/e482c34c86bd4bf8b56c0b35558996b9/10/GPL/openjdk-12.0.2_linux-x64_bin.tar.gz && \
    tar xvf openjdk12.tar.gz && \
    rm openjdk12.tar.gz && \
    mv jdk-12.0.2 /opt/ && \
    rm /opt/jdk-12.0.2/lib/src.zip
ENV JAVA_HOME=/opt/jdk-12.0.2
ENV PATH=$PATH:$JAVA_HOME/bin
RUN java -version

# install rebar3
RUN curl -o rebar3 https://s3.amazonaws.com/rebar3/rebar3 && \
    chmod +x rebar3 && \
    mv rebar3 /usr/local/bin/rebar3

# install and update python and python-pip
RUN apt -q update && apt install -y python3-pip && \
    rm -rf /var/lib/apt/lists/* && \
    python3 -m pip install pip==$PIP3_INSTALL_VERSION --upgrade

# install maven
RUN apt -q update && apt install -y maven && \
    rm -rf /var/lib/apt/lists/*

# install sbt
RUN mkdir -p /usr/local/share/sbt-launcher-packaging && \
    curl \
    --retry 3 \
    --retry-delay 15 \
    --location "https://github.com/sbt/sbt/releases/download/v${SBT_VERSION}/sbt-${SBT_VERSION}.tgz" \
    --output "/tmp/sbt-${SBT_VERSION}.tgz" && \
    tar -xzf "/tmp/sbt-${SBT_VERSION}.tgz" -C /usr/local/share/sbt-launcher-packaging --strip-components=1 && \
    ln -s /usr/local/share/sbt-launcher-packaging/bin/sbt /usr/local/bin/sbt && \
    rm -f "/tmp/sbt-${SBT_VERSION}.tgz"

# install gradle
RUN curl -L -o gradle.zip https://services.gradle.org/distributions/gradle-$GRADLE_VERSION-bin.zip && \
    unzip -q gradle.zip && \
    rm gradle.zip && \
    mv gradle-$GRADLE_VERSION /root/gradle
ENV PATH=/root/gradle/bin:$PATH

#install go
WORKDIR /go
RUN wget https://storage.googleapis.com/golang/go$GO_LANG_VERSION.linux-amd64.tar.gz -O go.tar.gz && tar --strip-components=1 -xf go.tar.gz && rm -f go.tar.gz
ENV GOROOT /go
ENV PATH=$PATH:/go/bin

# godep is now required for license_finder to work for project that are still managed with GoDep
ENV GOROOT=/go
ENV GOPATH=/gopath
ENV PATH=$PATH:$GOPATH/bin

RUN mkdir /gopath && \
    go install github.com/tools/godep@latest && \
    go install github.com/FiloSottile/gvt@latest && \
    go install github.com/kardianos/govendor@latest && \
    go clean -cache

#install rvm and glide
RUN apt-add-repository -y ppa:rael-gc/rvm && \
    apt -q update && apt install -y rvm && \
    /usr/share/rvm/bin/rvm install --default $RUBY_VERSION && \
    apt install -y golang-glide && \
    rm -rf /var/lib/apt/lists/*

# install trash
RUN curl -Lo trash.tar.gz https://github.com/rancher/trash/releases/download/v0.2.7/trash-linux_amd64.tar.gz && \
    tar xvf trash.tar.gz && \
    rm trash.tar.gz && \
    mv trash /usr/local/bin/

# install bundler
RUN bash -lc "gem update --system && gem install bundler"

WORKDIR /tmp
# Fix the locale
RUN apt -q update && apt install -y locales && rm -rf /var/lib/apt/lists/*
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# install Cargo
RUN curl https://sh.rustup.rs -sSf | bash -ls -- -y --profile minimal

#install mix
RUN curl -1sLf 'https://dl.cloudsmith.io/public/rabbitmq/rabbitmq-erlang/setup.deb.sh' | bash
RUN apt -q update && apt install -y erlang && rm -rf /var/lib/apt/lists/*
# Install Elixir
WORKDIR /tmp/elixir-build
RUN git clone https://github.com/elixir-lang/elixir.git
WORKDIR elixir
RUN make && make install
WORKDIR /

# install conan
RUN apt -q update && apt install -y python3-dev && rm -rf /var/lib/apt/lists/* && \
    pip install --no-cache-dir --ignore-installed six --ignore-installed colorama \
    --ignore-installed requests --ignore-installed chardet \
    --ignore-installed urllib3 \
    --upgrade setuptools && \
    pip3 install --no-cache-dir -Iv conan==1.51.3 && \
    conan config install https://github.com/conan-io/conanclientcert.git

# install NuGet (w. mono)
# https://docs.microsoft.com/en-us/nuget/install-nuget-client-tools#macoslinux
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF &&\
    echo "deb https://download.mono-project.com/repo/ubuntu stable-focal main" | tee /etc/apt/sources.list.d/mono-official-stable.list &&\
    apt -q update && apt install -y mono-complete && rm -rf /var/lib/apt/lists/* &&\
    curl -o "/usr/local/bin/nuget.exe" "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe" &&\
    curl -o "/usr/local/bin/nugetv3.5.0.exe" "https://dist.nuget.org/win-x86-commandline/v3.5.0/nuget.exe"

# install dotnet core
RUN wget -q https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb &&\
    dpkg -i packages-microsoft-prod.deb &&\
    rm packages-microsoft-prod.deb &&\
    apt -q update &&\
    apt install -y dotnet-sdk-6.0 dotnet-sdk-7.0 &&\
    rm -rf /var/lib/apt/lists/*

# install Composer
# The ARG and ENV are for installing tzdata which is part of this installaion.
# https://serverfault.com/questions/949991/how-to-install-tzdata-on-a-ubuntu-docker-image
ENV TZ=GMT
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 4F4EA0AAE5267A6C &&\
    echo "deb http://ppa.launchpad.net/ondrej/php/ubuntu jammy main" | tee /etc/apt/sources.list.d/php.list &&\
    export DEBIAN_FRONTEND=noninteractive &&\
    apt -q update && apt install -y php7.4-cli && rm -rf /var/lib/apt/lists/* &&\
    EXPECTED_COMPOSER_INSTALLER_CHECKSUM="$(curl --silent https://composer.github.io/installer.sig)" &&\
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" &&\
    ACTUAL_COMPOSER_INSTALLER_CHECKSUM="$(php -r "echo hash_file('sha384', 'composer-setup.php');")" &&\
    test "${ACTUAL_COMPOSER_INSTALLER_CHECKSUM}" = "${EXPECTED_COMPOSER_INSTALLER_CHECKSUM}" || (echo "ERROR: Invalid installer checksum" >&2; false) &&\
    php composer-setup.php &&\
    php -r "unlink('composer-setup.php');" &&\
    mv composer.phar /usr/bin/composer

# install miniconda
# See https://docs.conda.io/en/latest/miniconda_hashes.html
# for latest versions and SHAs.
RUN  \
    conda_installer=Miniconda3-py38_4.9.2-Linux-x86_64.sh &&\
    ref='1314b90489f154602fd794accfc90446111514a5a72fe1f71ab83e07de9504a7' &&\
    wget -q https://repo.anaconda.com/miniconda/${conda_installer} &&\
    sha=`openssl sha256 "${conda_installer}" | cut -d' ' -f2` &&\
    ([ "$sha" = "${ref}" ] || (echo "Verification failed: ${sha} != ${ref}"; false)) &&\
    (echo; echo "yes") | sh "${conda_installer}"

# install Swift Package Manager
# Based on https://github.com/apple/swift-docker/blob/main/5.8/ubuntu/22.04/Dockerfile
# The GPG download steps has been modified. Keys are now on LF repo and copied instaad of downloaded.
# Refer to https://swift.org/download/#using-downloads in the Linux section on how to download the keys
RUN apt -q update && apt -q install -y \
    binutils \
    git \
    gnupg2 \
    libc6-dev \
    libedit2 \
    libgcc-9-dev \
    libcurl4-openssl-dev \
    libpython3-dev \
    libsqlite3-0 \
    libstdc++-9-dev \
    libxml2-dev \
    libz3-dev \
    pkg-config \
    python3-lldb-13 \
    tzdata \
    zlib1g-dev \
    && rm -r /var/lib/apt/lists/*

# pub   4096R/ED3D1561 2019-03-22 [SC] [expires: 2023-03-23]
#       Key fingerprint = A62A E125 BBBF BB96 A6E0  42EC 925C C1CC ED3D 1561
# uid                  Swift 5.x Release Signing Key <swift-infrastructure@swift.org
ARG SWIFT_SIGNING_KEY=A62AE125BBBFBB96A6E042EC925CC1CCED3D1561
ARG SWIFT_PLATFORM=ubuntu22.04
ARG SWIFT_BRANCH=swift-5.8-release
ARG SWIFT_VERSION=swift-5.8-RELEASE
ARG SWIFT_WEBROOT=https://download.swift.org

ENV SWIFT_SIGNING_KEY=$SWIFT_SIGNING_KEY \
    SWIFT_PLATFORM=$SWIFT_PLATFORM \
    SWIFT_BRANCH=$SWIFT_BRANCH \
    SWIFT_VERSION=$SWIFT_VERSION \
    SWIFT_WEBROOT=$SWIFT_WEBROOT

COPY swift-all-keys.asc .
RUN set -e; \
    SWIFT_WEBDIR="$SWIFT_WEBROOT/$SWIFT_BRANCH/$(echo $SWIFT_PLATFORM | tr -d .)" \
    && SWIFT_BIN_URL="$SWIFT_WEBDIR/$SWIFT_VERSION/$SWIFT_VERSION-$SWIFT_PLATFORM.tar.gz" \
    && SWIFT_SIG_URL="$SWIFT_BIN_URL.sig" \
    # - Grab curl here so we cache better up above
    && export DEBIAN_FRONTEND=noninteractive \
    && apt -q update && apt -q install -y curl && rm -rf /var/lib/apt/lists/* \
    # - Download the GPG keys, Swift toolchain, and toolchain signature, and verify.
    && export GNUPGHOME="$(mktemp -d)" \
    && curl -fsSL "$SWIFT_BIN_URL" -o swift.tar.gz "$SWIFT_SIG_URL" -o swift.tar.gz.sig \
    && gpg --import swift-all-keys.asc \
    && gpg --batch --verify swift.tar.gz.sig swift.tar.gz \
    # - Unpack the toolchain, set libs permissions, and clean up.
    && tar -xzf swift.tar.gz --directory / --strip-components=1 \
    && chmod -R o+r /usr/lib/swift \
    && rm -rf "$GNUPGHOME" swift.tar.gz.sig swift.tar.gz \
    set +e

# install flutter
ENV FLUTTER_HOME=/root/flutter
RUN git config --global --add safe.directory /root/flutter
RUN curl -o flutter_linux_2.8.1-stable.tar.xz https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_2.8.1-stable.tar.xz \
    && tar xf flutter_linux_2.8.1-stable.tar.xz \
    && mv flutter ${FLUTTER_HOME} \
    && rm flutter_linux_2.8.1-stable.tar.xz

ENV PATH=$PATH:${FLUTTER_HOME}/bin:${FLUTTER_HOME}/bin/cache/dart-sdk/bin
RUN flutter doctor -v \
    && flutter update-packages \
    && flutter precache
# Accepting all licences
RUN yes | flutter doctor --android-licenses -v
# Creating Flutter sample projects to put binaries in cache fore each template type
RUN flutter create --template=app ${TEMP}/app_sample \
    && flutter create --template=package ${TEMP}/package_sample \
    && flutter create --template=plugin ${TEMP}/plugin_sample

# install license_finder
COPY . /LicenseFinder
RUN bash -lc "cd /LicenseFinder && bundle config set no-cache 'true' && bundle install -j4 && bundle pristine && rake install"

WORKDIR /

CMD cd /scan && /bin/bash -l
