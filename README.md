# Tangerine support anvironment  

It installs some utilities for fetching files on top of ubuntu 14.04, 
sets Tangerine env. vars., and then the core applications used by Tangerine. 

The JDK/Android part of this dockerfile is based on bprodoehl/android-dev. Kudos!

A default Couchdb admin is created using the environment vars in the dockerfile.

Features:

- ubuntu 14.04 LTS
- Nodejs (Node.js v4.2.0 "Argon")
- nginx
- Ubuntu default-jdk JDK 7 (openjdk)
- Android SDK r24.4.1
- Android tools - android-22
- Couchdb (from ppa:couchdb/stable)

## Install

You can either pull from `tangerine/docker-tangerine-support`:

```
docker pull tangerine/docker-tangerine-support
```

```
docker run -i -t tangerine/docker-tangerine-support /bin/bash
```

or add it to your Dockerfile:

```
FROM tangerine/docker-tangerine-support
```

## TODO:

- https support - from https://letsencrypt.org/ or http://aws.amazon.com/certificate-manager/
- improve nginx configuration

