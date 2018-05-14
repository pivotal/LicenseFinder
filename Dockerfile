FROM ubuntu:trusty
RUN apt-get update && apt-get install -y curl git-core build-essential wget unzip

# Versioning
ENV PIP_INSTALL_VERSION 10.0.1
ENV GO_LANG_VERSION 1.10.2
ENV MAVEN_VERSION 3.5.3
ENV SBT_VERSION 1.1.1
ENV GRADLE_VERSION 4.2
ENV RUBY_VERSION 2.5.1
ENV MIX_VERSION 1.0

# nodejs seems to be required for the one of the gems
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash - && \
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
RUN cd /tmp && \
    wget --quiet --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/jdk-8u131-linux-x64.tar.gz -O jdk-8.tgz && \
    tar xf /tmp/jdk-8.tgz && \
    mkdir -p /usr/lib/jvm && \
    mv jdk1.8.0_131 /usr/lib/jvm/oracle_jdk8 && \
    rm /tmp/jdk-8.tgz

ENV J2SDKDIR=/usr/lib/jvm/oracle_jdk8
ENV J2REDIR=/usr/lib/jvm/oracle_jdk8/jre
ENV PATH=$PATH:/usr/lib/jvm/oracle_jdk8/bin:/usr/lib/jvm/oracle_jdk8/db/bin:/usr/lib/jvm/oracle_jdk8/jre/bin
ENV JAVA_HOME=/usr/lib/jvm/oracle_jdk8
ENV DERBY_HOME=/usr/lib/jvm/oracle_jdk8/db

RUN java -version

# install python and rebar
RUN apt-get install -y python rebar

# install and update python-pip
RUN apt-get install -y python-pip && \
    pip install --upgrade pip==$PIP_INSTALL_VERSION

# install maven
RUN curl -O http://www-us.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz && \
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
RUN wget https://storage.googleapis.com/golang/go$GO_LANG_VERSION.linux-amd64.tar.gz -O go.tar.gz && tar --strip-components=1 -xf go.tar.gz
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
  go get github.com/golang/dep/cmd/dep

# Fix the locale
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

#install rvm
RUN curl -sSL https://rvm.io/mpapis.asc | gpg --import && \
    curl -sSL https://get.rvm.io | sudo bash -s stable --ruby=$RUBY_VERSION
ENV PATH=/usr/local/rvm/bin:$PATH

#install mix
RUN wget https://packages.erlang-solutions.com/erlang-solutions_${MIX_VERSION}_all.deb && \
    sudo dpkg -i erlang-solutions_${MIX_VERSION}_all.deb && \
    sudo apt-get update && \
    sudo apt-get install -y esl-erlang && \
    sudo apt-get install -y elixir

# install bundler
RUN bash -lc "gem update --system && gem install bundler"

# install conan
RUN apt-get install -y python-dev && \
	pip install --ignore-installed six --ignore-installed colorama --ignore-installed requests --ignore-installed chardet --ignore-installed urllib3 --upgrade setuptools && \
	pip install conan

# install license_finder
COPY . /LicenseFinder
RUN bash -lc "cd /LicenseFinder && bundle install -j4 && rake install"

WORKDIR /
