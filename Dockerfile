FROM ubuntu:trusty
RUN apt-get update && apt-get install -y curl git-core

#install rvm
RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 && \
    curl -sSL https://get.rvm.io | bash -s stable --ruby
ENV PATH=/usr/local/rvm/bin:$PATH

# install build-essential wget unzip
RUN apt-get install -y build-essential wget unzip

# nodejs seems to be required for the one of the gems
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash - && \
    apt-get -y install nodejs

# install bower
RUN npm install -g bower && \
    echo '{ "allow_root": true }' > /root/.bowerrc

# install bundler
RUN bash -lc "rvm install 2.3.3 && rvm use 2.3.3 && gem install bundler"

#install java 8
#http://askubuntu.com/questions/521145/how-to-install-oracle-java-on-ubuntu-14-04
RUN cd /tmp && \
    wget --quiet --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u66-b17/jdk-8u66-linux-x64.tar.gz -O jdk-8.tgz && \
    tar xf /tmp/jdk-8.tgz && \
    mkdir -p /usr/lib/jvm && \
    mv jdk1.8.0_66 /usr/lib/jvm/oracle_jdk8 && \
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
RUN curl -O http://www-us.apache.org/dist/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz && \
    tar -xf apache-maven-3.3.9-bin.tar.gz; rm -rf apache-maven-3.3.9-bin.tar.gz && \
    mv apache-maven-3.3.9 /usr/local/lib/maven && \
    ln -s /usr/local/lib/maven/bin/mvn /usr/local/bin/mvn

# install gradle
WORKDIR /tmp
RUN curl -L -o gradle.zip http://services.gradle.org/distributions/gradle-2.4-bin.zip && \
    unzip -q gradle.zip && \
    rm gradle.zip && \
    mv gradle-2.4 /root/gradle
ENV PATH=/root/gradle/bin:$PATH

#install go
WORKDIR /go
RUN wget https://storage.googleapis.com/golang/go1.5.3.linux-amd64.tar.gz -O go.tar.gz && tar --strip-components=1 -xf go.tar.gz
ENV GOROOT /go
ENV PATH=$PATH:/go/bin

# godep is now required for license_finder to work for project that are still managed with GoDep
ENV GOROOT=/go
ENV GOPATH=/gopath
ENV PATH=$PATH:$GOPATH/bin
RUN mkdir /gopath && go get github.com/tools/godep

# Fix the locale
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# install license_finder
RUN bash -lc "git clone https://github.com/pivotal/LicenseFinder /LicenseFinder && cd /LicenseFinder && bundle install -j4 && rake install"

WORKDIR /