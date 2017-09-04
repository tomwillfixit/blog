---
layout: post
comments: true
title: Docker Rexray/efs plugin outside of EC2 
---

> “What's EFS?" "It's a limitless hard drive in the sky"

― Anonymous 

![efs](../images/efs.png)

# Disclaimer 

This is my first blog post in a while so it may be a little rusty.  
ShipItCon has been and gone, now it's time for DockerCon.  

# Docker Plugins 101 

Docker plugins are incredibly useful. Easy to install, configure, update and remove.  Plugins run in containers and only access the parts of the filesystem/permissions required to work.
Check them out here : https://store.docker.com/

2 particular favorites are local-persist and rexray/efs.  This post is about an issue with rexray/efs when run outside of an EC2 instance.

# Persistent storage using rexray/efs plugin for Docker

![rex](../images/rex.png)

When running Docker in EC2 instances the rexray/efs plugin works like a charm. It does what it says on the tin. Persistent storage is made available to your containers.  
For more info on EFS check out : https://aws.amazon.com/efs/

When running a Docker host outside of EC2 things aren't quite so smooth.  According to a github issue back in Febuary 2017 the plugin only works from an EC2 instance. ( Add link later).  This may have changed since but installing the plugin on Docker 17.06.1 on an instance outside AWS failed with this error :

```
docker plugin install rexray/efs EFS_ACCESSKEY=AKA EFS_SECRETKEY=bK EFS_SECURITYGROUPS="sg-0 sg-6" EFS_REGION="us-west-2" REXRAY_LOGLEVEL=debug
Plugin "rexray/efs" is requesting the following privileges:
 - network: [host]
 - mount: [/dev]
 - allow-all-devices: [true]
 - capabilities: [CAP_SYS_ADMIN]
Do you grant the above permissions? [y/N] y
latest: Pulling from rexray/efs
5fa4398d663c: Download complete 
Digest: sha256:9d507174acf741b233c827d54778d1e8e4ce40c386edda085448a593cec58dcb
Status: Downloaded newer image for rexray/efs:latest
Error response from daemon: dial unix /run/docker/plugins/0a476ca462f421ff00dd09b21a081fbccc5ecdbe5916a573c419200d037a29a2/rexray.sock: connect: no such file or directory

``` 

This looked like it might be an auth issue.  It wasn't.  After poking around with the plugin I tried installing rexray on the host and creating a volume using the same EFS credentials.  

```
curl -sSL https://dl.bintray.com/emccode/rexray/install | sh -s -- stable

```

Storage config file :

```
libstorage:
  service: efs
  server:
    services:
      efs:
        driver: efs
        efs:
          accessKey: AK
          secretKey: bK 
          securityGroups:
          - sg-0 
          - sg-6 
          - sg-5 
          region:              us-west-2
          tag:                 test
          disableSessionCache: false
          statusMaxAttempts:  6
          statusInitialDelay: 1s
          statusTimeout:      2m

```

Things are looking good now.  Lot's of output and then this error :

```
args=[efs supported] cmd=/var/lib/libstorage/lsx-linux host=unix:///var/run/libstorage/274597856.sock server=stream-stallion-ye service=efs stderr=error: error getting supported: Head http://169.254.169.254/latest/meta-data/: dial tcp 169.254.169.254:80: getsockopt: connection refused
 storageDriver=libstorage time=1504524907263 txCR=1504524907 txID=0e2cb37c-af34-459c-4998-5b811457f93a

```

Rexray is trying to query the metadata service which is provided by EC2.  I'm not in EC2 ... brick wall.

# Fake it til you break it

Why does Rexray need to query the metadata service?  Is something being returned that is required to make rexray/efs work?  Doesn't look like it.  Using a fake metadata service, running in a container we can get past this.

```
git clone https://github.com/bpholt/fake-ec2-metadata-service
ifconfig lo:0 169.254.169.254 netmask 255.255.255.255 up

We need to edit ec2-metadata-service.rb and mock out a few endpoints to keep the rexray/efs plugin happy.

The edited file can be found [here](ec2-metadata-service.rb)

When you have ensured that the instanceID endpoint is correct then you can go ahead and build the image locally.
docker build -t fake-ec2-metadata-service .
Edit the docker-compose.yml and replace the image name and change port 8169 to 80
Run : docker-compose up -d

```

At this point you have a fake metadata service running.

You should be able to install the plugin now : 

```
docker plugin install rexray/efs EFS_ACCESSKEY=AKA EFS_SECRETKEY=bK EFS_SECURITYGROUPS="sg-0 sg-6" EFS_REGION="us-west-2" REXRAY_LOGLEVEL=debug

```

The plugin will query the fake metadata service and check that the instanceID exists.  I just used a preexisting t2.micro instanceID to get around this.
The plugin was installed successfully.

Test that it works.  

## Create a volume

```
docker volume create --driver rexray/efs --name test-vol-1
```

## Start a container and mount the volume
```
docker run -v test-vol-1:/data busybox mount | grep "/data"
```


# Summary

Plugins are awesome. Give them a try.  I really like EFS but I like optionality.  Having the option of running containers on hosts outside of EC2 is important. It's worth noting this is just a dirty great workaround and will likely be out of date by the time this is commited.


