cmake_minimum_required (VERSION 3.0.0)
project (HelloEigenProject)

include(cmake/APM.cmake)

add_executable(HelloEigen helloEigen.cpp)

add_repository(localRepo FOLDER "${CMAKE_CURRENT_SOURCE_DIR}/../repo/")

require(Eigen3 VERSION 3.2.5 TARGETS HelloEigen REPOSITORY localRepo)
require(Boost VERSION 1.57.0 TARGETS HelloEigen COMPONENTS filesystem system)