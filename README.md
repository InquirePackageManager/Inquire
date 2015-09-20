# Inquire

Inquire is an experimental package manager for the CMake build system. Written in pure CMake, Inquire provides an API allowing CMake users easily manage external dependencies such as libraries or CMake modules.

# Simple Example

Inquire is designed to be simple for CMake users by providing an API following CMake classic rules. Here is an example CMake list file that build a project depending on Boost System and FileSystem libraries :


    cmake_minimum_required (VERSION 3.0.0)
    project (BoostTestProject)

    include(Inquire.cmake)

    add_executable(BoostTest BoostTest.cpp)

    require_package(Boost VERSION 1.59.0 TARGETS BoostTest COMPONENTS filesystem system REQUIRED)

As you can see, the only difference between a classic CMake file and Inquire is that `find_package` calls are translated in `require_package` calls with an additional parameter specifying the targets _requiring_ Boost.
In fact, the `require_package` call will handle all the things related to the library. This means that Inquire will be in charge of downloading, configuring, compiling the library, and configuring the targets.
All these things are transparent for the user. No more search on how to compile, configure or use a particular library. The behaviors is consistent for every library, you just need to call `require_package`.

# Current state

Currently, Inquire is a work in progress, the API may change at any time without warning.

That being said, feel free to use, modify, or do whatever you want with the code, which is licensed under the MIT license. If you want to contribute, I'm open to any sort of contribution (Pull requests, comments on what I should or shouldn't have done this way, or even coffee to help me stay awake at night).

The documentation is nonexistent. If you want to know how it works, I think the code is self explanatory (At least for the moment).

# Standard modules

Here is the current list of modules :

- Boost :  [![Build Status](https://github.com/InquirePackageManager/Inquire_Boost.svg?branch=master)](https://travis-ci.org/InquirePackageManager/Inquire_Boost)
- Eigen3 :  [![Build Status](https://travis-ci.org/InquirePackageManager/Inquire_Eigen3.svg?branch=master)](https://travis-ci.org/InquirePackageManager/Inquire_Eigen3)
- FileInformation :  [![Build Status](https://travis-ci.org/InquirePackageManager/Inquire_FileInformation.svg?branch=master)](https://travis-ci.org/InquirePackageManager/Inquire_FileInformation)
