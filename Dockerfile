FROM ubuntu:xenial

# Versioning
ENV PIP_INSTALL_VERSION 19.0.2
ENV GO_LANG_VERSION 1.11.5
ENV MAVEN_VERSION 3.6.0
ENV SBT_VERSION 1.1.1
ENV GRADLE_VERSION 4.10.3
ENV RUBY_VERSION 2.6.1
ENV MIX_VERSION 1.0
ENV JDK_VERISON 8u211
ENV COMPOSER_ALLOW_SUPERUSER 1

# programs needed for building
RUN apt-get update && apt-get install -y \
  build-essential \
  curl \
  git-core \
  sudo \
  unzip \
  wget \
  gnupg2 \ 
  software-properties-common

# nodejs seems to be required for the one of the gems
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash - && \
    apt-get -y install nodejs

# install yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add - && \
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list && \
  apt-get update && \
  apt-get install yarn

# install bower
RUN npm install -g bower && \
    echo '{ "allow_root": true }' > /root/.bowerrc

#install java 8
#http://askubuntu.com/questions/521145/how-to-install-oracle-java-on-ubuntu-14-04
RUN apt-get install -y openjdk-8-jdk
RUN JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64

ENV J2SDKDIR=/usr/lib/jvm/java-8-openjdk-amd64
ENV J2REDIR=/usr/lib/jvm/java-8-openjdk-amd64/jre
ENV PATH=$PATH:/usr/lib/jvm/java-8-openjdk-amd64/bin:/usr/lib/jvm/java-8-openjdk-amd64/jre/bin
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64

RUN java -version

# install python and rebar
RUN apt-get install -y python rebar

# install and update python-pip
RUN apt-get install -y python-pip && \
    pip install --upgrade pip==$PIP_INSTALL_VERSION

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
RUN curl -L -o gradle.zip http://services.gradle.org/distributions/gradle-$GRADLE_VERSION-bin.zip && \
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
  go get -u github.com/rancher/trash

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
	pip install --ignore-installed six --ignore-installed colorama --ignore-installed requests --ignore-installed chardet --ignore-installed urllib3 --upgrade setuptools && \
    pip install -Iv conan==1.11.2

# install Cargo
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y

# install NuGet (w. mono)
# https://docs.microsoft.com/en-us/nuget/install-nuget-client-tools#macoslinux
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF &&\
  echo "deb https://download.mono-project.com/repo/ubuntu stable-xenial main" | sudo tee /etc/apt/sources.list.d/mono-official-stable.list &&\
  apt-get update &&\
  apt-get install -y mono-complete &&\
  curl -o /usr/local/bin/nuget.exe https://dist.nuget.org/win-x86-commandline/latest/nuget.exe &&\
  echo "alias nuget=\"mono /usr/local/bin/nuget.exe\"" >> ~/.bash_aliases

# install dotnet core
RUN wget -q https://packages.microsoft.com/config/ubuntu/16.04/packages-microsoft-prod.deb &&\
  sudo dpkg -i packages-microsoft-prod.deb &&\
  sudo apt-get update &&\
  sudo apt-get install -y dotnet-runtime-2.1 dotnet-sdk-2.1

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 4F4EA0AAE5267A6C &&\
    echo "deb http://ppa.launchpad.net/ondrej/php/ubuntu xenial main" | sudo tee /etc/apt/sources.list.d/php.list &&\
    apt-get update &&\
    apt-get install -y php7.1-cli &&\
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" &&\
    php -r "if (hash_file('sha384', 'composer-setup.php') === '48e3236262b34d30969dca3c37281b3b4bbe3221bda826ac6a9a62d6444cdb0dcd0615698a5cbe587c3f0fe57a54d8f5') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" &&\
    php composer-setup.php &&\
    php -r "unlink('composer-setup.php');" &&\
    mv composer.phar /usr/bin/composer

# install license_finder
COPY . /LicenseFinder
RUN bash -lc "cd /LicenseFinder && bundle install -j4 && rake install"

WORKDIR /

CMD cd /scan && /bin/bash -l
