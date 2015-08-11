cmake_minimum_required (VERSION 3.0.0)
project (HelloEigenProject)
set(APM_DEBUG ON)

include(cmake/APM.cmake)

add_executable(HelloEigen helloEigen.cpp)
# an APM module repository is a place (folder, GIT repo, etc.) containing CMake modules to "require" projects.
APM_add_module_repository(moduleRepo FOLDER "${CMAKE_CURRENT_SOURCE_DIR}/../modules/")

# an APM package repository contains all the built libraries and sources.
APM_add_package_repository(packageRepo FOLDER "${CMAKE_CURRENT_SOURCE_DIR}/../packages/")


require(Eigen3 VERSION 3.2.5 TARGETS HelloEigen PACKAGE_REPOSITORY packageRepo)
require(Boost VERSION 1.57.0 TARGETS HelloEigen COMPONENTS filesystem system)
