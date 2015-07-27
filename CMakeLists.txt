cmake_minimum_required (VERSION 3.0.0)
project (HelloEigenProject)

include(cmake/APM.cmake)

add_executable(HelloEigen helloEigen.cpp)

add_repository(localRepo FOLDER "${CMAKE_CURRENT_SOURCE_DIR}/repo/cmake")

require(Eigen OPTIONAL REQUIRED EXACT VERSION 3.2.5 TARGETS Foo bar REPOSITORY localRepo)
require(TEST)