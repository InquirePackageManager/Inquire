cmake_minimum_required (VERSION 3.0.0)
project (HelloEigenProject)

include(cmake/APM.cmake)

add_executable(HelloEigen helloEigen.cpp)

add_repository(localRepo FOLDER "C:/Developpements/APM/repo/cmake")

require(Eigen OPTIONAL REQUIRED QUIET EXACT VERSION 1.0.0 TARGETS Foo bar REPOSITORY localRepo)
require(TEST)