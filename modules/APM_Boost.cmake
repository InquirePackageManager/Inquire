function(APM_install_package)
	APM_install_package_parse_arguments(l_APM_install_package ${ARGN})
	if(NOT DEFINED l_APM_install_package_VERSION)
		APM_message(STATUS "Triggering installation of Boost in version 1.58.0 (default)... ")
		set(l_APM_install_package_VERSION "1.58.0")
	else()
		APM_message(STATUS "Triggering installation of Eigen3 in version ${l_APM_install_package_VERSION}... ")
	endif()
	string(REPLACE "." "_" l_APM_underscore_version ${l_APM_install_package_VERSION})

	set(Boost_USE_STATIC_LIBS ON)
	set(Boost_USE_MULTITHREADED ON)
	set(Boost_USE_STATIC_RUNTIME OFF)


	APM_message(STATUS "Installing Boost libraries ${l_APM_install_package_COMPONENTS}")

	#---------------------------------------------------------------------------------------#
	#-										DOWNLOAD									   -#
	#---------------------------------------------------------------------------------------#
  if(CMAKE_SYSTEM_NAME MATCHES "Windows")
      set(l_APM_PACKAGE_TYPE zip)
  else()
      set(l_APM_PACKAGE_TYPE tar.gz)
  endif()

	if(NOT DEFINED l_APM_install_PACKAGE_REPOSITORY)
		#set default value to the package repository
		set(l_APM_install_PACKAGE_REPOSITORY  ${APM_DEFAULT_PACKAGE_REPOSITORY})
	endif()
	APM_Repository_getLocation(${l_APM_install_PACKAGE_REPOSITORY} l_APM_repo_location)
	set(l_APM_RootProjectDir "${l_APM_repo_location}/${a_APM_name}/${a_APM_version}")

	set(l_APM_archiveName "boost_${l_APM_underscore_version}.${l_APM_PACKAGE_TYPE}")
	set(l_APM_BoostLocation "http://sourceforge.net/projects/boost/files/boost/${l_APM_install_package_VERSION}/${l_APM_archiveName}")
	set(l_APM_BoostLocalDir ${l_APM_RootProjectDir})
	set(l_APM_BoostLocalArchive "${l_APM_BoostLocalDir}/download/${l_APM_archiveName}")

  if(NOT EXISTS "${l_APM_BoostLocalArchive}")
    APM_message(STATUS "Downloading Boost ${l_APM_install_package_VERSION} from ${l_APM_BoostLocation}.")
    file(DOWNLOAD "${l_APM_BoostLocation}" "${l_APM_BoostLocalArchive}" SHOW_PROGRESS STATUS l_APM_downloadStatus)
		list(GET l_APM_downloadStatus 0 l_APM_downloadStatusCode)
		list(GET l_APM_downloadStatus 1 l_APM_downloadStatusString)
		if(NOT l_APM_downloadStatusCode EQUAL 0)
			APM_message(FATAL_ERROR "Error: downloading ${l_APM_BoostLocation} failed with error : ${status_string}")
		endif()
  else()
      APM_message(STATUS "Using already downloaded Boost version from ${l_APM_BoostLocalArchive}")
  endif()

	#---------------------------------------------------------------------------------------#
	#-										EXTRACT 									   -#
	#---------------------------------------------------------------------------------------#
	if(EXISTS ${l_APM_BoostLocalDir}/source/boost_${l_APM_underscore_version}/)
		APM_message(STATUS "Folder ${l_APM_BoostLocalDir}/source/boost_${l_APM_underscore_version}/ already exists. ")
	else()
		APM_message(STATUS "Extracting Boost ${l_APM_install_package_VERSION}...")
		file(MAKE_DIRECTORY ${l_APM_BoostLocalDir}/source/)
		execute_process(COMMAND ${CMAKE_COMMAND} -E tar xzf ${l_APM_BoostLocalArchive} WORKING_DIRECTORY ${l_APM_BoostLocalDir}/source/)
		APM_message(STATUS "Extracting Boost ${l_APM_install_package_VERSION}... DONE.")
	endif()

endfunction()

#compile an already downloaded package
function(APM_compile_package )
	APM_compile_package_parse_arguments(l_APM_compile_package ${ARGN})

	APM_message(STATUS "Triggering compilation of Boost...")

	#---------------------------------------------------------------------------------------#
	#-										BOOTSTRAP 									   -#
	#---------------------------------------------------------------------------------------#
	set(l_APM_BoostRoot ${l_APM_compile_package_SOURCE_DIR}/source/boost_${l_APM_underscore_version})
	if(CMAKE_SYSTEM_NAME MATCHES "Windows")
    set(l_APM_BOOSTRAPER ${l_APM_BoostRoot}/bootstrap.bat)
    set(l_APM_B2 ${l_APM_BoostRoot}/b2.exe)
    set(l_APM_DYNLIB_EXTENSION .dll)
  elseif(CMAKE_SYSTEM_NAME MATCHES "Darwin")
    set(l_APM_BOOSTRAPER ${l_APM_BoostRoot}/bootstrap.sh)
    set(l_APM_B2 ${l_APM_BoostRoot}/b2)
    set(l_APM_DYNLIB_EXTENSION .dylib)
  elseif(CMAKE_SYSTEM_NAME MATCHES "Linux")
    set(l_APM_BOOSTRAPER ${l_APM_BoostRoot}/bootstrap.sh)
    set(l_APM_B2 ${l_APM_BoostRoot}/b2)
    set(l_APM_DYNLIB_EXTENSION .so)
  else()
    APM_message(FATAL_ERROR "Platform not suported. Unable to install boost libraries.")
  endif()

  if(NOT EXISTS ${l_APM_B2})
    APM_message(STATUS "Bootstrapping Boost ${l_APM_compile_package_VERSION}...")
		file(MAKE_DIRECTORY ${l_APM_compile_package_SOURCE_DIR}/source/)
    execute_process(COMMAND ${l_APM_BOOSTRAPER} # --prefix=${l_APM_compile_package_SOURCE_DIR}/source/
				WORKING_DIRECTORY ${l_APM_BoostRoot}
				RESULT_VARIABLE l_APM_Result
				OUTPUT_VARIABLE l_APM_Output
				ERROR_VARIABLE l_APM_Error)
    if(NOT l_APM_Result EQUAL 0)
      APM_message(FATAL_ERROR "Failed running bootstrap :\n${Output}\n${Error}\n")
    endif()
    APM_message("${l_APM_BOOSTRAPER} --prefix=${l_APM_compile_package_SOURCE_DIR}/source/")
  endif()

	#---------------------------------------------------------------------------------------#
	#-										BUILD	 									   -#
	#---------------------------------------------------------------------------------------#

	APM_compute_toolset(l_APM_toolset)

  if(l_APM_compile_package_COMPONENTS)
    APM_message(STATUS "Building Boost ${l_APM_compile_package_VERSION} components with toolset ${l_APM_toolset}...")

		#TODO : Add the possibility to launch parallel compilation
		set(l_APM_B2CallString  ${l_APM_B2} --includedir=${l_APM_BoostLocalDir} --toolset=${l_APM_toolset} -j1 --layout=versioned --build-type=complete)
		foreach(l_APM_component ${l_APM_compile_package_COMPONENTS})
			set(l_APM_B2CallString ${l_APM_B2CallString} --with-${l_APM_component})
		endforeach()

		execute_process(COMMAND ${l_APM_B2CallString}
				WORKING_DIRECTORY ${l_APM_BoostRoot})
  endif()

	APM_message(STATUS "Triggering compilation of Boost... OK")
endfunction()






function(APM_configure_targets)
	cmake_parse_arguments(l_APM_configure_targets "" "INSTALL_DIR" "TARGETS;COMPONENTS" ${ARGN})

	set(BOOST_ROOT ${l_APM_configure_targets_INSTALL_DIR})

	if(DEFINED l_APM_configure_targets_COMPONENTS)
		find_package(Boost COMPONENTS ${l_APM_configure_targets_COMPONENTS} MODULE QUIET)
	else()
		find_package(Boost MODULE QUIET)
	endif()


	#add include directories to targets
	if(NOT l_APM_configure_targets_TARGETS)
		APM_message(STATUS "Including directory ${Boost_INCLUDE_DIRS} globally.")
		include_directories(${Boost_INCLUDE_DIRS})
	else()
		APM_message(STATUS "Including directory ${Boost_INCLUDE_DIRS} for targets ${l_APM_configure_targets_TARGETS}.")
		foreach(l_APM_TARGET ${l_APM_configure_targets_TARGETS})
			target_include_directories(${l_APM_TARGET} PUBLIC ${Boost_INCLUDE_DIRS})
			if(Boost_LIBRARIES)
				target_link_libraries(${l_APM_TARGET} PUBLIC ${Boost_LIBRARIES})
			endif(Boost_LIBRARIES)
		endforeach(l_APM_TARGET)
	endif()

	if(MSVC)
		add_definitions(-DBOOST_ALL_NO_LIB)
		#add_definitions(-DBOOST_ALL_DYN_LINK)
	endif(MSVC)

endfunction()
