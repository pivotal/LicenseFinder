FROM ubuntu:trusty
RUN apt-get update && apt-get install -y curl git-core build-essential wget unzip

# nodejs seems to be required for the one of the gems
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash - && \
    apt-get -y install nodejs

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
    pip install --upgrade pip

# install maven
RUN curl -O http://www-us.apache.org/dist/maven/maven-3/3.5.0/binaries/apache-maven-3.5.0-bin.tar.gz && \
    tar -xf apache-maven-3.5.0-bin.tar.gz; rm -rf apache-maven-3.5.0-bin.tar.gz && \
    mv apache-maven-3.5.0 /usr/local/lib/maven && \
    ln -s /usr/local/lib/maven/bin/mvn /usr/local/bin/mvn

# install gradle
WORKDIR /tmp
RUN curl -L -o gradle.zip http://services.gradle.org/distributions/gradle-2.9-bin.zip && \
    unzip -q gradle.zip && \
    rm gradle.zip && \
    mv gradle-2.9 /root/gradle
ENV PATH=/root/gradle/bin:$PATH

#install go
WORKDIR /go
RUN wget https://storage.googleapis.com/golang/go1.8.3.linux-amd64.tar.gz -O go.tar.gz && tar --strip-components=1 -xf go.tar.gz
ENV GOROOT /go
ENV PATH=$PATH:/go/bin

# godep is now required for license_finder to work for project that are still managed with GoDep
ENV GOROOT=/go
ENV GOPATH=/gopath
ENV PATH=$PATH:$GOPATH/bin
RUN mkdir /gopath && go get github.com/tools/godep && go get github.com/FiloSottile/gvt

# Fix the locale
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

#install rvm
RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 && \
    curl -sSL https://raw.githubusercontent.com/wayneeseguin/rvm/stable/binscripts/rvm-installer | sudo bash -s stable --ruby=2.4.1
ENV PATH=/usr/local/rvm/bin:$PATH

#install mix
RUN wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb && \
    sudo dpkg -i erlang-solutions_1.0_all.deb && \
    sudo apt-get update && \
    sudo apt-get install -y esl-erlang && \
    sudo apt-get install -y elixir

# install bundler
RUN bash -lc "gem update --system && gem install bundler"

# install license_finder
COPY . /LicenseFinder
RUN bash -lc "cd /LicenseFinder && bundle install -j4 && rake install"

WORKDIR /
