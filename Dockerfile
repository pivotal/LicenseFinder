FROM ubuntu:xenial

# Versioning
ENV PIP_INSTALL_VERSION 19.0.2
ENV PIP3_INSTALL_VERSION 20.0.2
ENV GO_LANG_VERSION 1.14.3
ENV MAVEN_VERSION 3.6.0
ENV SBT_VERSION 1.3.3
ENV GRADLE_VERSION 5.6.4
ENV RUBY_VERSION 2.7.1
ENV MIX_VERSION 1.0
ENV COMPOSER_ALLOW_SUPERUSER 1

# programs needed for building
RUN apt-get update && apt-get install -y \
  build-essential \
  curl \
  sudo \
  unzip \
  wget \
  gnupg2 \ 
  software-properties-common \
  bzr

RUN add-apt-repository ppa:git-core/ppa && apt-get update && apt-get install -y git

# nodejs seems to be required for the one of the gems
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
    apt-get -y install nodejs

# install yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add - && \
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list && \
  apt-get update && \
  apt-get install yarn

# install bower
RUN npm install -g bower && \
    echo '{ "allow_root": true }' > /root/.bowerrc

# install jdk 12
RUN curl -L -o openjdk12.tar.gz https://download.java.net/java/GA/jdk12.0.2/e482c34c86bd4bf8b56c0b35558996b9/10/GPL/openjdk-12.0.2_linux-x64_bin.tar.gz && \
    tar xvf openjdk12.tar.gz && \
    rm openjdk12.tar.gz && \
    sudo mv jdk-12.0.2 /opt/ && \
    sudo rm /opt/jdk-12.0.2/lib/src.zip
ENV JAVA_HOME=/opt/jdk-12.0.2
ENV PATH=$PATH:$JAVA_HOME/bin
RUN java -version

# install rebar3
RUN curl -o rebar3 https://s3.amazonaws.com/rebar3/rebar3 && \
    sudo chmod +x rebar3 && \
    sudo mv rebar3 /usr/local/bin/rebar3

# install and update python and python-pip
RUN apt-get install -y python python-pip python3-pip && \
    python3 -m pip install pip==$PIP3_INSTALL_VERSION --upgrade && \
    python -m pip install pip==$PIP_INSTALL_VERSION --upgrade --force

# install maven
RUN curl -O https://archive.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz && \
    tar -xf apache-maven-$MAVEN_VERSION-bin.tar.gz; rm -rf apache-maven-$MAVEN_VERSION-bin.tar.gz && \
    mv apache-maven-$MAVEN_VERSION /usr/local/lib/maven && \
    ln -s /usr/local/lib/maven/bin/mvn /usr/local/bin/mvn

# install sbt
RUN mkdir -p /usr/local/share/sbt-launcher-packaging && \
    curl --progress \
    --retry 3 \
    --retry-delay 15 \
    --location "https://github.com/sbt/sbt/releases/download/v${SBT_VERSION}/sbt-${SBT_VERSION}.tgz" \
    --output "/tmp/sbt-${SBT_VERSION}.tgz" && \
    tar -xzf "/tmp/sbt-${SBT_VERSION}.tgz" -C /usr/local/share/sbt-launcher-packaging --strip-components=1 && \
    ln -s /usr/local/share/sbt-launcher-packaging/bin/sbt /usr/local/bin/sbt && \
    rm -f "/tmp/sbt-${SBT_VERSION}.tgz"

# install gradle
WORKDIR /tmp
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
  go get github.com/tools/godep && \
  go get github.com/FiloSottile/gvt && \
  go get github.com/Masterminds/glide && \
  go get github.com/kardianos/govendor && \
  go get github.com/golang/dep/cmd/dep && \
  go get -u github.com/rancher/trash && \
  go clean -cache

# Fix the locale
RUN apt-get install -y locales
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

#install rvm
RUN apt-add-repository -y ppa:rael-gc/rvm && \
    apt update && apt install -y rvm && \
    /usr/share/rvm/bin/rvm install --default $RUBY_VERSION
ENV PATH=/usr/share/rvm/bin:$PATH

#install mix
RUN wget https://packages.erlang-solutions.com/erlang-solutions_${MIX_VERSION}_all.deb && \
    sudo dpkg -i erlang-solutions_${MIX_VERSION}_all.deb && \
    sudo rm -f erlang-solutions_${MIX_VERSION}_all.deb && \
    sudo apt-get update && \
    sudo apt-get install -y esl-erlang && \
    sudo apt-get install -y elixir

# install bundler
RUN bash -lc "gem update --system && gem install bundler"

# install conan
RUN apt-get install -y python-dev && \
	pip install --no-cache-dir --ignore-installed six --ignore-installed colorama \
	    --ignore-installed requests --ignore-installed chardet \
	    --ignore-installed urllib3 \
	    --upgrade setuptools && \
    pip install --no-cache-dir -Iv conan==1.11.2

# install Cargo
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y --profile minimal

# install NuGet (w. mono)
# https://docs.microsoft.com/en-us/nuget/install-nuget-client-tools#macoslinux
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF &&\
  echo "deb https://download.mono-project.com/repo/ubuntu stable-xenial main" | sudo tee /etc/apt/sources.list.d/mono-official-stable.list &&\
  apt-get update &&\
  apt-get install -y mono-complete &&\
  curl -o "/usr/local/bin/nuget.exe" "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe" &&\
  curl -o "/usr/local/bin/nugetv3.5.0.exe" "https://dist.nuget.org/win-x86-commandline/v3.5.0/nuget.exe"

# install dotnet core
WORKDIR /tmp
RUN wget -q https://packages.microsoft.com/config/ubuntu/16.04/packages-microsoft-prod.deb &&\
  sudo dpkg -i packages-microsoft-prod.deb &&\
  rm packages-microsoft-prod.deb &&\
  sudo apt-get update &&\
  sudo apt-get install -y dotnet-runtime-2.1 dotnet-sdk-2.1 dotnet-sdk-2.2 dotnet-sdk-3.0 dotnet-sdk-3.1

# install Composer
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 4F4EA0AAE5267A6C &&\
    echo "deb http://ppa.launchpad.net/ondrej/php/ubuntu xenial main" | sudo tee /etc/apt/sources.list.d/php.list &&\
    apt-get update &&\
    apt-get install -y php7.4-cli &&\
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
WORKDIR /tmp
RUN  \
  conda_installer=Miniconda3-py38_4.9.2-Linux-x86_64.sh &&\
  ref='1314b90489f154602fd794accfc90446111514a5a72fe1f71ab83e07de9504a7' &&\
  wget -q https://repo.anaconda.com/miniconda/${conda_installer} &&\
  sha=`openssl sha256 "${conda_installer}" | cut -d' ' -f2` &&\
  ([ "$sha" = "${ref}" ] || (echo "Verification failed: ${sha} != ${ref}"; false)) &&\
  (echo; echo "yes") | sh "${conda_installer}"

# install license_finder
COPY . /LicenseFinder
RUN bash -lc "cd /LicenseFinder && bundle config set no-cache 'true' && bundle install -j4 && rake install"

WORKDIR /

CMD cd /scan && /bin/bash -l
