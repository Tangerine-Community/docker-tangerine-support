# Android development environment based on Ubuntu 14.04 LTS.
# version 0.0.1

# Start with Ubuntu 14.04 LTS.
FROM ubuntu:14.04

# Never ask for confirmations
ENV DEBIAN_FRONTEND noninteractive
RUN echo "debconf shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections
RUN echo "debconf shared/accepted-oracle-license-v1-1 seen true" | debconf-set-selections

# First, install add-apt-repository and bzip2
RUN apt-get update
RUN apt-get -y install software-properties-common python-software-properties bzip2 unzip openssh-client git lib32stdc++6 lib32z1

# Add oracle-jdk7 to repositories
RUN add-apt-repository ppa:webupd8team/java

# Update apt
RUN apt-get update

# Install curl
RUN sudo apt-get install curl -y

# Install Couchdb
RUN sudo apt-get install software-properties-common -y
RUN sudo apt-add-repository -y ppa:couchdb/stable
RUN sudo apt-get update
RUN sudo apt-get install couchdb -y
RUN sudo chown -R couchdb:couchdb /usr/lib/couchdb /usr/share/couchdb /etc/couchdb /usr/bin/couchdb
RUN sudo chmod -R 0770 /usr/lib/couchdb /usr/share/couchdb /etc/couchdb /usr/bin/couchdb
RUN sudo mkdir /var/run/couchdb
RUN sudo chown -R couchdb /var/run/couchdb
RUN couchdb -k
RUN couchdb -b

# create server admin
RUN sudo -E sh -c 'echo "$T_ADMIN = $T_PASS" >> /etc/couchdb/local.ini'
RUN couchdb -b

# Add the first user.
RUN curl -HContent-Type:application/json -vXPUT "http://$T_ADMIN:$T_PASS@$T_COUCH_HOST:$T_COUCH_PORT/_users/org.couchdb.user:user1" --data-binary '{"_id": "org.couchdb.user:user1","name": "user1","roles": [],"type": "user","password": "password"}'

# Install jdk7
# RUN apt-get -y install oracle-java7-installer
RUN apt-get -y install default-jdk


# Install android sdk
RUN wget http://dl.google.com/android/android-sdk_r24.4.1-linux.tgz
RUN tar -xvzf android-sdk_r24.4.1-linux.tgz
RUN mv android-sdk-linux /usr/local/bin/android-sdk
RUN rm android-sdk_r24.4.1-linux.tgz

# Install Android tools
#RUN echo y | /usr/local/android-sdk/tools/android update sdk --filter platform,tool,platform-tool,extra,addon-google_apis-google-19,addon-google_apis_x86-google-19,build-tools-19.1.0 --no-ui -a
RUN echo y | /usr/local/bin/android-sdk/tools/android update sdk --force --filter android-22,tools,platform-tools,build-tools-23.0.2 --no-ui -a

# Environment variables
ENV ANDROID_HOME /usr/local/bin/android-sdk
ENV ANDROID_SDK_HOME $ANDROID_HOME
ENV PATH $PATH:$ANDROID_SDK_HOME/tools
ENV PATH $PATH:$ANDROID_SDK_HOME/platform-tools
