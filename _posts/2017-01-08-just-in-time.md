---
layout: post
comments: true
title: Just In Time Test Infrastructure 
---

> “The most dangerous kind of waste is the waste we do not recognize.”

― Shigeo Shingo 

![jit](../images/jit.jpg)

## Pop quiz, hotshot

- How much did it cost to test Release X? 
- How much did it cost to test a specific build of Release X?
- How much does it cost to run testsuite X? 
- How much does it cost to execute testcase X?

## What is Just In Time (JIT)?

JIT is a set of principles pioneered by Toyota in the 1950s aimed primarily at reducing flow times within production systems as well as response times from suppliers and to customers.  Some of the principles include :

- Elimination of Waste
- Quality at the source
- Simpification
- Respect for People

What does this have to do with Test Infrastructure?  With the rise of DevOps, the adoption of JIT principles is set for a resurgence.  Developers are increasingly owning entire production systems and the next generation of tooling is encouraging JIT and lean methodologies.

The container revolution and tooling such as Docker enables developers to build, test and deploy entire production systems.  As part of this production system developers are increasingly owning the test function and related infrastructure.

Defining the CI/CD configuration in code alongside service source code is common practice.  Travis, Jenkins, CodeShip all support this.  This improves visibility into what is being performed as part of a build, test and deploy process.  

Test Infrastructure as code and test resource requirements should also be located alongside the service code.  

## Benefits of Test Infrastructure as code

- Reduces drift between local testing environments and those used as part of CI/CD
- Better visibility into how test environments are configured
- Encourages better understanding of what resources are needed per test/testsuite.
- Environments are customised to the test requirements*

\* In the past I've worked on projects in which a default test environment was used for convenience or we simply "super-sized" the test environment to ensure tests ran consistently. This may seem reasonable when you are running a handful of tests but as you scale your testing then this becomes a real issue.  Resource utilization drops through the floor and costs per test cycle increase.

## JIT Test Infrastructure

During my time at Sun I was responsible for maintaining a "Test lab" for the JavaQA team.  This consisted of a few hundred baremetal servers which covered every architecture that supported Java. These systems hosted "Test environments" in the form of VMs, Containers (Solaris Zones), Logical Domains (LDOMS) and were available 24/7/365.  Our utilization was poor but it was never really an issue since "times were good".  Fast forward 15 years and the cost of hosting these test environments 24/7/365 in the cloud would be substantial.  

A typical Java Release went through a 2 week test cycle.  During this cycle the test environments would be running tests for the first several days. The rest of the time the systems were idling while we did some debugging of issues, running manual regression tests, fixing tests and producing test reports. In hindsight this was plain crazy. 

The prevalence of API accessible infrastructure and tooling such as Docker Swarm make the provisioning of test environments trivial.  We can create distributed, scalable, high availability clusters of test environments in minutes.  These test clusters are highly configurable and provide the precise resources required to run the specified set of tests. 

Sounds alot like on-demand.  True but with the proviso that the test environments operate with zero wastage.  Each test environment is resourced to the exact requirements of the tests to be executed and is only available for the lifespan of the tests.  This sounds like "serverless" or "Functions as a Service".

## Confessions of a QA 

In the past I've run tests with very little knowledge about what resources were needed.  To be honest I didn't care. The tests passed, happy days, ignorance is bliss.  This approach was lazy and based on "get it shipped" mentality.  Investing time in profiling resource usage of tests and building the test environments to specifically meet these requirements would have improved my understanding of the tests and saved my employer money.

# Summary

Effectively implementing JIT depends on education, training and commitment from all levels.  Management must commit to a fundamental "quality-first" policy.  Eliminating the wasteful provisioning of unnecessary resources and increasing resource utilization during the testing lifecycle is essential for future growth.  In 2017 I plan to use Docker Swarm, Terraform and Ansible to create JIT Test Infrastructure and experiment with "Functions as a service".  This work will be presented in a future Docker Dublin Meetup.  Sign up : https://www.meetup.com/Docker-Dublin/  

Thanks for reading.
