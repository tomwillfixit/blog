---
layout: post
comments: true
title: Build and Test Infrastructure (Part 2)
---

---
> “Quality is free, but only to those who are willing to pay heavily for it.”

― Tom DeMarco (1987) Peopleware: Productive Projects and Teams. 


![scale](../images/scale.jpg)

This is the second of two blog posts looking at Build Infrastructure (BI), Test Infrastructure (TI) and the benefits of separating the two.

**Disclaimer** : This post contains opinions which are my own and based upon past experiences of managing Test Infrastructure.

> “Testing is an infinite process of comparing the invisible to the ambiguous in order to avoid the unthinkable happening to the anonymous.”

— James Bach

## What is Test Infrastructure?  

Test Infrastructure consists of the tooling, services and environments required to verify that an artifact satisfies the specified requirements.

The core components of TI are : 

* **Artifact repository/registry** 

  Hosts artifacts created as part of the build process.

* **Test environment**

  Contains the tooling, services and/or hooks to external services required for tests to be executed.

* **Testsuite**

  Contains the code used to verify the product requirements.


These core components are a simplification of the what, where and how of the test function.

A comprehensive TI consists of many other supporting services such as a test scheduler, environment orchestration, centralised logging, metrics gathering and reporting. 

## Test Infrastructure characteristics

TI shares many of the same characteristics as BI :

 * Reproducibility

 * Availability

 * Visibility

 * Predictability

 * Portability

Please refer to the previous [post](http://tomwillfixit.com/blog/build-infra/) for an explanation of each.

In addition to these characteristics TI should support scalability, distributed systems and be highly configurable.

The majority of this blog will focus on the test environment component and how it differs from the build environment.

## Test environment (TE)

TE and arguably the testsuites, should be designed to be scalable and runnable across a distributed system.  From experience I've never been asked for more resources to build artifacts. More resources for testing however is quite a common request.  In the past our response to such requests was to increase the resources available to the build environments to handle resource hungry testsuites.

Modifying build environments to support testing is problematic for two reasons :

* **Glass ceiling of resources**

  When do we stop adding more resources? As we increase the resources per environment the cost of build and test increases.

* **Reproducing environments locally becomes more difficult**

  As the build and test environments become more resource hungry the ability to run them locally becomes more challenging.


> “We cannot solve our problems with the same thinking we used when we created them.”

— Albert Einstein


## Build environments (BE) vs Test environments (TE)

In the previous [post](http://tomwillfixit.com/blog/build-infra/) the BE was described as a core component of Build Infrastructure.  The BE is typically lean and provides just enough resources required for the build function.  A BE may be a container, a VM or baremetal but it is not generally required for the BE to be part of a distributed system or to scale on demand.

The TE is more complex.  The TE should be capable of running any number of tests on a single environment or across hundreds/thousands of environments.  This scalability needs to happen seamlessly, as part of the test setup or preferably during execution as resources become available.

The TE should be as close to Production and Staging as possible.  If Production and Staging are running in a distributed fashion then so should the tests.  The BE has no such requirement.

This next point is purely anecdotal.  A misconfiguration in the BE is alot more forgiving than a misconfiguration in the TE.  I have seen entire test cycles being invalidated due to the wrong test dependency being defined in a config file.  In one case the wrong build was tested due to a misconfiguration and the build deployed to production was untested.


## A possible solution

Separate the ownership of Build Infrastructure and Test Infrastructure.  

BI should be as simple as possible while TI should be designed with elasticity and production parity in mind.  Tools such as Docker Swarm can help with the orchestration of such environments. Developers can use Docker Swarm to create ad-hoc test clusters while the QA team can use Docker Swarm to create more permanent shared test clusters. Some more details of this can be found [here](http://www.slideshare.net/ThomasShaw5/containerised-testing-at-demonware-pycon-ireland-2016).


## Challenges 

Test Infrastructure has some unique challenges :

* Expensive

* Ownership

* Risk

* Investment

## Expensive

Test Infrastructure is expensive and cost per test cycle will increase without continuous optimization of products, tests and environments. As more tests are added, more testsuites are run and the complexity of the supporting services increases so will the cost of each test cycle.  It isn't all doom and gloom.  As the cost of compute drops teams can leverage the "portability" characteristic to move tests between providers to find the best price.

## Ownership

Test Infrastructure is constantly changing and this requires ownership. Test environments, test dependencies and testsuites need to be managed with the same rigor as the product being shipped.  Ideally TI would be managed by a QA team but in the absence of QA the ownership may fall to the developers. Developers owning and sharing TI may lead to a number of positive outcomes :

* Better understanding of testcycle and dependencies
* Help identify areas of optimization
* Help identify overlapping test requirements between products
* Reduce risk of stale environments/dependencies

## Risk

Test Infrastructure which is under resourced and unowned can leave you open to the following risks :

* Stale test environments
* Stale test dependencies
* Deploying untested code to production

I've come across these 3 scenarios in the past and while no-one died it was quite embarassing.  You may be testing one artifact and deploying another. Test environments and test dependencies are always changing and they need to be rebuilt regularly. Needless to say every TE should be defined in code.

## Investment

A change in how and where tests are being run will require investment from each team.  Many testsuites are written to run on single environments and may require development time to allow them to run in a distributed manner.


> “I remember the days when QA testers were treated almost as second-class citizens and developers ruled the software world. But as it recently occurred to me: we’re all testers now.” 

— Joe Colantonio


# Summary

I've discussed this topic with a number of past and current colleagues and the opinions have been interesting.  Some agree that Build Infrastructure and Test Infrastructure should be separate while others feel that this is a case of passing the buck.  There was unanimous agreement on one point. Test environments need to match Production more closely. Using tools such as Docker, Ansible and Docker Swarm developers are being empowered to create production like test environments from code and deployable across any platform.   


