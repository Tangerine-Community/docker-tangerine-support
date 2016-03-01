# Android development environment based on Ubuntu 14.04 LTS.
# version 0.0.1

# Start with Ubuntu 14.04 LTS.
FROM ubuntu:14.04

# Never ask for confirmations
ENV DEBIAN_FRONTEND noninteractive
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# Setup Tangerine environment for Couch
ENV T_HOSTNAME local.tangerinecentral.org
ENV T_ADMIN admin
ENV T_PASS password
ENV T_COUCH_HOST localhost
ENV T_COUCH_PORT 5984
ENV T_ROBBERT_PORT 4444
ENV T_TREE_PORT 4445
ENV T_BROCKMAN_PORT 4446
ENV T_DECOMPRESSOR_PORT 4447

# Update apt
RUN apt-get update

# Install some core utilities
RUN sudo apt-get -y install software-properties-common python-software-properties bzip2 unzip openssh-client git lib32stdc++6 lib32z1 curl wget

# required on 64-bit ubuntu
# RUN sudo dpkg --add-architecture i386
# RUN sudo apt-get -qqy install libncurses5:i386 libstdc++6:i386 zlib1g:i386

# install nodejs
RUN curl -sL https://deb.nodesource.com/setup_4.x | sudo -E bash -
RUN sudo apt-get -y install nodejs

# install nginx
RUN sudo apt-get -y install nginx

# nginx config
CMD sudo sed 's/T_HOSTNAME/$T_HOSTNAME/g\
    s/T_COUCH_HOST/$T_COUCH_HOST/g\
    s/T_COUCH_PORT/$T_COUCH_PORT/g\
    s/T_ROBBERT_PORT/$T_ROBBERT_PORT/g\
    s/T_TREE_PORT/$T_TREE_PORT/g\
    s/T_BROCKMAN_PORT/$T_BROCKMAN_PORT/g\
    s/T_DECOMPRESSOR_PORT/$T_DECOMPRESSOR_PORT/g' tangerine-nginx.template > /etc/nginx/sites-available/tangerine.conf
RUN sudo ln -s /etc/nginx/sites-available/tangerine.conf /etc/nginx/sites-enabled/tangerine.conf
RUN sudo rm /etc/nginx/sites-enabled/default
  # increase the size limit of posts
CMD sudo sed -i "s/sendfile on;/sendfile off;\n\tclient_max_body_size 128M;/" /etc/nginx/nginx.conf
RUN sudo service nginx restart

ADD ./ /root/Tangerine-server
COPY tangerine-env-vars.sh.defaults /root/Tangerine-server/tangerine-env-vars.sh
# RUN dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
RUN sudo cp /root/Tangerine-server/tangerine-env-vars.sh /etc/profile.d/
# RUN source /etc/profile

# Install Couchdb
RUN sudo apt-get -y install software-properties-common
RUN sudo apt-add-repository -y ppa:couchdb/stable
RUN sudo apt-get update
RUN sudo apt-get -y install couchdb
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
# RUN curl -HContent-Type:application/json -vXPUT "http://$T_ADMIN:$T_PASS@$T_COUCH_HOST:$T_COUCH_PORT/_users/org.couchdb.user:user1" --data-binary '{"_id": "org.couchdb.user:user1","name": "user1","roles": [],"type": "user","password": "password"}'
# RUN curl -HContent-Type:application/json -vXPUT "http://admin:password@localhost:5984/_users/org.couchdb.user:user1" --data-binary '{"_id": "org.couchdb.user:user1","name": "user1","roles": [],"type": "user","password": "password"}'

# Install jdk7
# RUN apt-get -y install oracle-java7-installer
RUN apt-get -y install default-jdk

# Install android sdk
RUN wget http://dl.google.com/android/android-sdk_r24.4.1-linux.tgz
RUN tar -xvzf android-sdk_r24.4.1-linux.tgz
RUN mv android-sdk-linux /usr/local/bin/android-sdk
RUN rm android-sdk_r24.4.1-linux.tgz

# RUN sudo chown -R $USER:$USER /usr/local/bin/android-sdk
# RUN sudo chmod a+x /usr/local/bin/android-sdk/tools/android
# RUN PATH=$PATH:/usr/local/bin/android-sdk/tools:/usr/local/bin/android-sdk/build-tools
# RUN sudo sh -c "echo \"export PATH=$PATH:/usr/local/bin/android-sdk/tools:/usr/local/bin/android-sdk/build-tools \nexport ANDROID_HOME=/usr/local/bin/android-sdk\" > /etc/profile.d/android-sdk-path.sh"

# Install Android tools
#RUN echo y | /usr/local/android-sdk/tools/android update sdk --filter platform,tool,platform-tool,extra,addon-google_apis-google-19,addon-google_apis_x86-google-19,build-tools-19.1.0 --no-ui -a
RUN echo y | /usr/local/bin/android-sdk/tools/android update sdk --force --filter android-22,tool,platform-tools,build-tools-23.0.2 --no-ui -a

# Environment variables
ENV ANDROID_HOME /usr/local/bin/android-sdk
ENV ANDROID_SDK_HOME $ANDROID_HOME
ENV PATH $PATH:$ANDROID_SDK_HOME/tools
ENV PATH $PATH:$ANDROID_SDK_HOME/platform-tools

EXPOSE 80
