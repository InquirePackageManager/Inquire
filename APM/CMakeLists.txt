cmake_minimum_required (VERSION 3.0.0)
project (HelloEigenProject)

include(cmake/APM.cmake)

add_executable(HelloEigen helloEigen.cpp)

#add_repository(localRepo FOLDER "${CMAKE_CURRENT_SOURCE_DIR}/../repo/")

#require(Eigen3 VERSION 3.2.5 TARGETS HelloEigen REPOSITORY localRepo)
#require(Boost VERSION 1.57.0 TARGETS HelloEigen COMPONENTS filesystem system)



	set(l_APM_OptionArguments OPTIONAL REQUIRED QUIET EXACT)
	set(l_APM_OneValueArguments VERSION)
	set(l_APM_MultipleValuesArguments TARGETS COMPONENTS)
	
	
	set(l_APM_previousArgs VERSION 1.57.0 TARGETS HelloEigen COMPONENTS filesystem system)


APM_set_argument(res l_APM_previousArgs APM_OPTION_ARG_TYPE QUIET True)
#APM_set_argument(res res APM_ONE_VALUE_ARG_TYPE VERSION 1.58.0)
APM_set_argument(res res APM_MULTIPLE_VALUE_ARG_TYPE TARGETS Foo Bar Baz)

message("l_APM_previousArgs = ${l_APM_previousArgs}")
message("res = ${res}")