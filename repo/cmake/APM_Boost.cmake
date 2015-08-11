function(APM_require)
	# Managing arguments
	set(l_APM_OptionArguments OPTIONAL REQUIRED QUIET EXACT)
	set(l_APM_OneValueArguments VERSION)
	set(l_APM_MultipleValuesArguments TARGETS COMPONENTS)
	cmake_parse_arguments(l_APM_require "${l_APM_OptionArguments}" "${l_APM_OneValueArguments}" "${l_APM_MultipleValuesArguments}" ${ARGN})
	
	#########################
	#TODO : implement a function to set arguments like
	# function(APM_set a_APM_variableType a_APM_variableName)
	# ex. :
	# APM_set(APM_OPTION_ARG QUIET)
	# APM_set(APM_ONE_VALUE_ARG VERSION 1.2.3)
	# APM_set(APM_MULTIPLE_VALUE_ARG TARGETS Foo Bar)
	#
	#
	# Idem, create a function APM_puch_back for adding values to APM_MULTIPLE_VALUE_ARG
	APM_filter_arguments(l_APM_fiteredArgs "${l_APM_OptionArguments}" "${l_APM_OneValueArguments}" "${l_APM_MultipleValuesArguments}" ${ARGN})
	
	
	set(l_APM_find_package_args)
	
	if(NOT l_APM_require_VERSION)
		set(l_APM_require_VERSION "1.58.0")
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
	
	if(NOT l_APM_require_COMPONENTS)
		set(l_APM_require_COMPONENTS)
	else(NOT l_APM_require_COMPONENTS)
		list(APPEND l_APM_find_package_args COMPONENTS ${l_APM_require_COMPONENTS})
	endif(NOT l_APM_require_COMPONENTS)
	
	
	set(Boost_USE_STATIC_LIBS ON) 
	set(Boost_USE_MULTITHREADED ON)  
	set(Boost_USE_STATIC_RUNTIME OFF) 
		

	APM_message(STATUS "Trying to find boost as a module...")
	find_package(Boost ${l_APM_find_package_args} MODULE QUIET)
	
	if(NOT Boost_FOUND)
		APM_message(STATUS "Trying to find boost as a Config...")
		find_package(Boost ${l_APM_find_package_args} CONFIG QUIET)	
		if(NOT Boost_FOUND)
			APM_message(STATUS "Trying to set BOOST_ROOT...")
			set(BOOST_ROOT "${APM_REPOSITORY_DIR}/Boost/${l_APM_require_VERSION}/source/boost_${l_APM_underscore_version}/")
			find_package(Boost ${l_APM_find_package_args} MODULE QUIET)
		endif(NOT Boost_FOUND)
	endif(NOT Boost_FOUND)	
	
	#if boost was not found, just install it
	if(NOT Boost_FOUND)
		APM_installBoost()
		#test again after install
		find_package(Boost ${l_APM_find_package_args} MODULE QUIET)			
		if(NOT Boost_FOUND)
			APM_message(FATAL_ERROR "Boost was not found...")
		endif(NOT Boost_FOUND)
	endif(NOT Boost_FOUND)	

	#add include directories to targets
	if(NOT l_APM_require_TARGETS)
		APM_message(STATUS "Including directory ${Boost_INCLUDE_DIRS} globally.")
		include_directories(${Boost_INCLUDE_DIRS})
	else(NOT l_APM_require_TARGETS)
		APM_message(STATUS "Including directory ${Boost_INCLUDE_DIRS} for targets ${l_APM_require_TARGETS}.")
		foreach(l_APM_TARGET ${l_APM_require_TARGETS})
			target_include_directories(${l_APM_TARGET} PUBLIC ${Boost_INCLUDE_DIRS})
			if(Boost_LIBRARIES)
				target_link_libraries(${l_APM_TARGET} PUBLIC ${Boost_LIBRARIES})
			endif(Boost_LIBRARIES)
		endforeach(l_APM_TARGET)
	endif(NOT l_APM_require_TARGETS)
	
	if(MSVC)
		add_definitions(-DBOOST_ALL_NO_LIB)
		#add_definitions(-DBOOST_ALL_DYN_LINK)
	endif(MSVC)
endfunction()

function(APM_installBoost)	
	APM_message(STATUS "Installing Boost libraries ${l_APM_require_COMPONENTS}")
	
	if(NOT l_APM_require_VERSION)
		set(l_APM_require_VERSION "1.57.0")
	endif(NOT l_APM_require_VERSION)
	string(REPLACE "." "_" l_APM_underscore_version ${l_APM_require_VERSION})
	
	#---------------------------------------------------------------------------------------#
	#-										DOWNLOAD									   -#
	#---------------------------------------------------------------------------------------#
    if(CMAKE_SYSTEM_NAME MATCHES "Windows")
        set(l_APM_PACKAGE_TYPE zip)
    else()
        set(l_APM_PACKAGE_TYPE tar.gz)
    endif()
	
	set(l_APM_archiveName "boost_${l_APM_underscore_version}.${l_APM_PACKAGE_TYPE}")
	set(l_APM_BoostLocation "http://sourceforge.net/projects/boost/files/boost/${l_APM_require_VERSION}/${l_APM_archiveName}")
	set(l_APM_BoostLocalDir "${APM_REPOSITORY_DIR}/Boost/${l_APM_require_VERSION}")
	set(l_APM_BoostLocalArchive "${l_APM_BoostLocalDir}/download/${l_APM_archiveName}")
	
    if(NOT (EXISTS "${l_APM_BoostLocalArchive}"))
        APM_message(STATUS "Downloading Boost ${l_APM_require_VERSION} from ${l_APM_BoostLocation}.") 
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
	else(EXISTS ${l_APM_BoostLocalDir}/source/boost_${l_APM_underscore_version}/)
		APM_message(STATUS "Extracting Boost ${l_APM_require_VERSION}...")
		file(MAKE_DIRECTORY ${l_APM_BoostLocalDir}/source/)
		execute_process(COMMAND ${CMAKE_COMMAND} -E tar xzf ${l_APM_BoostLocalArchive} WORKING_DIRECTORY ${l_APM_BoostLocalDir}/source/)
		APM_message(STATUS "Extracting Boost ${l_APM_require_VERSION}... Done.")
	endif(EXISTS ${l_APM_BoostLocalDir}/source/boost_${l_APM_underscore_version}/)
	
	#---------------------------------------------------------------------------------------#
	#-										BOOTSTRAP 									   -#
	#---------------------------------------------------------------------------------------#
	set(l_APM_BoostRoot ${l_APM_BoostLocalDir}/source/boost_${l_APM_underscore_version})
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
        APM_message(STATUS "l_APM_BOOSTRAPER = ${l_APM_BOOSTRAPER}")
        APM_message(STATUS "l_APM_B2 = ${l_APM_B2}")
        APM_message(STATUS "l_APM_DYNLIB_EXTENSION = ${l_APM_DYNLIB_EXTENSION}")

    if(NOT (EXISTS ${l_APM_B2}))
        APM_message(STATUS "Bootstrapping Boost ${l_APM_require_VERSION}...")
		file(MAKE_DIRECTORY ${l_APM_BoostLocalDir}/source/)
        execute_process(COMMAND ${l_APM_BOOSTRAPER} # --prefix=${l_APM_BoostLocalDir}/source/
			WORKING_DIRECTORY ${l_APM_BoostRoot}
			RESULT_VARIABLE l_APM_Result 
			OUTPUT_VARIABLE l_APM_Output 
			ERROR_VARIABLE l_APM_Error)
        if(NOT l_APM_Result EQUAL 0)
            APM_message(FATAL_ERROR "Failed running bootstrap :\n${Output}\n${Error}\n")
        endif()
        APM_message("${l_APM_BOOSTRAPER} --prefix=${l_APM_BoostLocalDir}/source/")
    endif()
	
	#---------------------------------------------------------------------------------------#
	#-										BUILD	 									   -#
	#---------------------------------------------------------------------------------------#
	
	APM_compute_toolset(l_APM_toolset)
    APM_message(STATUS "l_APM_require_COMPONENTS = ${l_APM_require_COMPONENTS}")
	
    if(l_APM_require_COMPONENTS)
        APM_message(STATUS "Building Boost ${l_APM_require_VERSION} components with toolset ${l_APM_toolset}...")

		#TODO : Add the possibility to launch parallel compilation
		set(l_APM_B2CallString  ${l_APM_B2} --includedir=${l_APM_BoostLocalDir} --toolset=${l_APM_toolset} -j1 --layout=versioned --build-type=complete)
		foreach(l_APM_component ${l_APM_require_COMPONENTS})
			set(l_APM_B2CallString ${l_APM_B2CallString} --with-${l_APM_component})
		endforeach()
		
		execute_process(COMMAND ${l_APM_B2CallString}
			WORKING_DIRECTORY ${l_APM_BoostRoot})
    endif()
endfunction()
