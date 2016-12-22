---
layout: post
title: Build and Test Infrastructure (Part 1)
---

![factory](images/factory.jpg)

This the first of three blog posts which will look at Build Infrastructure, Test Infrastructure and the benefits of separating the two.

## What is Build Infrastructure?

Build Infrastructure (BI) consists of the tooling, services and environments required to create a deployable artifact from source.

The core components of BI are : 

* Source Control repository 

* Build environment 

* Destination repository/registry.  

A "service" or "application" can be built and deployed using the core components listed above.  The CI server has intentionally been ommited.  While the CI server is the preferred path for builds to take, we should still be able to build and deploy a service without the CI server in the case of an outage.

These components satisfy the what, how and where of the build process. BI can be thought of as a factory.  The raw material is code. The machinery is the build process and the created artifact is the product.  What about Quality Control?  BI is not responsible for the quality of the artifacts being built. Garbage in, garbage out.  The raw material should be checked before reaching the factory and all products should be tested before reaching the customer.

## Timeout - Why are you blogging about this?

I've spent the past 4 years confusing BI with Test Infrastructure(TI) and this is an attempt to clarify the characteristics and differences between BI and TI.  We spent alot of time building general purpose environments to satisfy both the build and test functions.  This has served us well in the past but will hinder our ability to scale in the coming years.

tl;dr BI and TI share characteristics but the investment, ownership, risk, lifecycle, elasticity and complexity differ greatly.

## Build Infrastructure characteristics

Some of the key characteristics of BI are reproducibility, availability, visibility, predictable and portability.  

 * Reproducibility

The environment, services and build dependencies need to be available to allow builds to be re-built byte-for-byte in the future.

 * Availability

The source control repository is critical. This may sound obvious but from past experience many source control tooling is not highly available due to additional cost, complexity or the feeling that "It'll be grand".  The build environments are also important but should be defined in code and can re-built within minutes if required.  Similarly the destination repository/registry should be defined in code and data recoverable from regular backups within minutes.

 * Visibility

There should be no black boxes, hacks or workarounds within BI.  The structure, status and origin of BI should be available to every user.  Each user should have the ability to trace their build from source through the build process to the artifacts destination. 

 * Predictable

This is a combination of reproducibility and availability.  The user should recieve a predictable and consistent experience during the build process regardless of when a build is running or where the build runs.  This is particularly challenging if builds rely on 3rd party tooling and libraries which may change upstream.  

 * Portability

Developer : "Where are the builds running?"  Build Engineer : "No idea"  

Using tools such as Docker and Ansible the entire BI should be portable.  This portability should be exercised as regularly as checking the integrity of backups.  Change is the only constant after all.  Using pipelines to deploy services nightly and to test build environments helps to protect from code rot.


## Sidenote - Change is coming

Build functions previously performed using CI/CD services such as Bamboo and Jenkins are being integrated into source control systems. Gitlab and Bitbucket are offering built-in CI/CD functions.  Github is likely to follow.  

What will this mean for tooling such as Bamboo and Jenkins?  Bamboo will likely be replaced by Bitbucket Pipelines in the coming years.  Jenkins, which many treat as an automation engine, as well as a CI server will continue to evolve.  Work being done by Cloudbees, in particular BlueOcean, will make the Jenkins UX beautiful and a joy to use.  Hosted CI/CD solutions such as CodeShip, CircleCI, Travis and Drone will continue to thrive and reduce the cost of building.  

# Summary

Build Infrastructure is reasonably static compared to Test Infrastructure.  Build requirements change less regularly, build environments change less regularly and there is a lesser need to scale on-demand.  Build environments are cheap. We could meet our build requirements by using a few dozen t2.micros on AWS.  This is not the case for test environments which are often more complex to setup and require more resources.  This will be covered more in the next post. 
