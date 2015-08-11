function(APM_require)
	# Managing arguments
	set(l_APM_OptionArguments OPTIONAL REQUIRED QUIET EXACT)
	set(l_APM_OneValueArguments VERSION INSTALL_PATH)
	set(l_APM_MultipleValuesArguments TARGETS)
	cmake_parse_arguments(l_APM_require "${l_APM_OptionArguments}" "${l_APM_OneValueArguments}" "${l_APM_MultipleValuesArguments}" ${ARGN})
	
	set(l_APM_find_package_args)
	
	if(NOT l_APM_require_VERSION)
		set(l_APM_require_VERSION "3.2.5")
	else(NOT l_APM_require_VERSION)
		list(APPEND l_APM_find_package_args ${l_APM_require_VERSION})
	endif(NOT l_APM_require_VERSION)
	string(REPLACE "." "_" l_APM_underscore_version ${l_APM_require_VERSION})
	
	if(NOT l_APM_require_EXACT)
		set(l_APM_require_EXACT )
	else(NOT l_APM_require_EXACT)
		list(APPEND l_APM_find_package_args EXACT)
	endif(NOT l_APM_require_EXACT)
	
	if(NOT l_APM_require_OPTIONAL)
		set(l_APM_require_OPTIONAL )
	else(NOT l_APM_require_OPTIONAL)
		list(APPEND l_APM_find_package_args OPTIONAL)
	endif(NOT l_APM_require_OPTIONAL)
	
	
	if(NOT l_APM_require_QUIET)
		set(l_APM_require_QUIET )
	else(NOT l_APM_require_QUIET)
		list(APPEND l_APM_find_package_args QUIET)
	endif(NOT l_APM_require_QUIET)
	
	APM_message(STATUS "Searching FindEigen3.cmake...")
	
	#search file FindEigen3.cmake in repository
	file(GLOB_RECURSE l_APM_fileLocation RELATIVE ${APM_DEFAULT_REPOSITORY_DIR} "FindEigen3.cmake")
	#if we found it, just call find_package
	if(l_APM_fileLocation)
		APM_message(STATUS "Found it : ${l_APM_fileLocation}")
		get_filename_component(l_APM_pathOfFindFile "${APM_DEFAULT_REPOSITORY_DIR}/${l_APM_fileLocation}" DIRECTORY)
		
		list(APPEND CMAKE_MODULE_PATH ${l_APM_pathOfFindFile})
		
		APM_message(STATUS "Calling find_package...")
		find_package(Eigen3 ${l_APM_find_package_args} MODULE)
	else()
		APM_message(DEBUG "Unable to find Eigen3 find module.")
		set(Eigen3_FOUND FALSE)
	endif()
	
	#if eigen was not found, just install it through APM_ExternalProject_Add
	if(NOT Eigen3_FOUND)
		APM_message(DEBUG "Eigen3 not found. Installing it.")
		set(l_APM_EigenLocation "https://bitbucket.org/eigen/eigen/get/${l_APM_require_VERSION}.tar.bz2")
		set(l_APM_EigenLocalDir "${APM_REPOSITORY_DIR}/Eigen/${l_APM_require_VERSION}")

		APM_message(STATUS "Installing Eigen3 via ExternalProject_Add.")
		APM_ExternalProject_Add(Eigen ${l_APM_require_VERSION}
			URL ${l_APM_EigenLocation}
		)
		if(Eigen3_FOUND)
			set(Eigen3_INCLUDE_DIR "${APM_Eigen_${l_APM_underscore_version}_INSTALL_DIR}/include/eigen3")
		else()
			APM_message(SEND_ERROR "Unable to find Eigen3.")
		endif()
	endif()

	#add include directories to targets
	if(NOT l_APM_require_TARGETS)
		APM_message(STATUS "Including directory ${Eigen3_INCLUDE_DIR} globally.")
		include_directories(${Eigen3_INCLUDE_DIR})
	else(NOT l_APM_require_TARGETS)
		APM_message(STATUS "Including directory ${Eigen3_INCLUDE_DIR} for targets ${l_APM_require_TARGETS}.")
		foreach(l_APM_TARGET ${l_APM_require_TARGETS})
			target_include_directories(${l_APM_TARGET} PUBLIC ${Eigen3_INCLUDE_DIR})
		endforeach(l_APM_TARGET)
	endif(NOT l_APM_require_TARGETS)
	
endfunction()