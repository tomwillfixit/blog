---
layout: post
title: Build Infrastructure 
---

## What is Build Infrastructure (BI)?

BI consists of the services and environments required to create a deployable artifact from source.

Core components of BI include: a source controlled repository, a build environment and a destination repository/registry.  A "service" or "application" can be built and deployed using these 3 components.  The CI server has intentionally been ommited.  While the CI server is the preferred path for builds to take, we can still build and deploy a service without the CI server in the case of an outage.

BI is essentially a factory which creates, labels and moves code from source to a destination.  BI is not responsible for the quality of the source it is building from or the quality of the artifact produced.  

Some of the key characteristics of BI are reproducibility, availability, visibility, predictable and portability.  

- Reproducibility

The environment, services and build dependencies need to be available to allow builds to be re-built byte-for-byte in the future.

- Availability

The source control repository is critical. This may sound obvious but from past experience many source control tooling is not highly available due to additional cost, complexity or the feeling that "It'll be grand".  The build environments are also important but should be defined in code and can re-built within minutes if required.  Similarly the destination repository/registry should be defined in code and data recoverable from regular backups within minutes.

- Visibility

There should be no black boxes, hacks or workarounds within BI.  The structure, status and origin of BI should be available to every user.  Each user should have the ability to trace their build from source through the build process to the artifacts destination. 

- Predictable

This is a combination of reproducibility and availability.  The user should recieve a predictable and consistent experience during the build process regardless of when a build is running or where the build runs.  This is particularly challenging if builds rely on 3rd party tooling and libraries which may change upstream.  

- Portability

Developer : "Where are the builds running?"  Build Engineer : "No idea"  

Using tools such as Docker and Ansible the entire BI should be portable.  This portability should be exercised as regularly as checking the integrity of backups.  Change is the only constant after all.  Using pipelines to deploy services nightly and to test build environments helps to protect from code rot.


Change is coming ... (Opinions are my own)

Build functions previously performed using CI/CD services such as Bamboo and Jenkins are being integrated into source control systems. Gitlab and Bitbucket are offering built-in CI/CD functions.  Github is likely to follow.  

What will this mean for tooling such as Bamboo and Jenkins?  Bamboo will likely be replaced by Bitbucket Pipelines in the coming years.  Jenkins, which many treat as an automation engine, as well as a CI server will continue to evolve.  Work being done by Cloudbees, in particular BlueOcean, will make the Jenkins UX beautiful and a joy to use.  Hosted CI/CD solutions such as CodeShip, CircleCI, Travis and Drone will continue to thrive and reduce the cost of building.  

## Summary

The purpose of this post was to highlight the importance of separating Build Infrastructure from Test Infrastructure (TI).  This was touched on earlier. BI does not care about quality. Garbage in, Garbage out.  As long as the resulting artefacts are built in a predictable and reproducible manner then the purpose of BI has been fulfilled.

