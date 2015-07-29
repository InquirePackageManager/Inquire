function(APM_compiler_version a_APM_result)
	if(CMAKE_CXX_COMPILER_ID STREQUAL "Intel"
      OR CMAKE_CXX_COMPILER MATCHES "icl"
      OR CMAKE_CXX_COMPILER MATCHES "icpc")
    set (l_APM_version "")
  elseif (MSVC14)
    set(l_APM_version "14.0")
  elseif (MSVC12)
    set(l_APM_version "12.0")
  elseif (MSVC11)
    set(l_APM_version "11.0")
  elseif (MSVC10)
    set(l_APM_version "10.0")
  elseif (MSVC90)
    set(l_APM_version "9.0")
  elseif (MSVC80)
    set(l_APM_version "8.0")
  elseif (MSVC71)
    set(l_APM_version "7.1")
  elseif (MSVC70) # Good luck! (That's from Kitware, but I'm not sure here at biicode we support VC6.0 and 7.0 too. So good luck from the hive too!)
    set(l_APM_version "7.0") # yes, this is correct
  elseif (MSVC60) # Good luck!
    set(l_APM_version "6.0") # yes, this is correct
  elseif (BORLAND)
    set(l_APM_version "")
  elseif(CMAKE_CXX_COMPILER_ID STREQUAL "SunPro")
    set(l_APM_version "")
  else()
	if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
		EXECUTE_PROCESS( COMMAND ${CMAKE_CXX_COMPILER} --version OUTPUT_VARIABLE l_APM_version )
		string (REGEX REPLACE ".*clang version ([0-9]+\\.[0-9]+).*" "\\1" l_APM_version ${l_APM_version})
	elseif(CMAKE_COMPILER_IS_GNUCXX)
		EXECUTE_PROCESS( COMMAND ${CMAKE_CXX_COMPILER} -dumpversion OUTPUT_VARIABLE l_APM_version)
		string (REGEX REPLACE "([0-9])\\.([0-9])\\.([0-9])" "\\1.\\2.\\3" l_APM_version ${l_APM_version})
    string(STRIP ${l_APM_version} l_APM_version) #Remove extra newline character
	endif()
  endif()
  set(${a_APM_result} ${l_APM_version} PARENT_SCOPE)
endfunction()

function(APM_compute_toolset a_APM_result)
	if(CMAKE_CXX_COMPILER_ID STREQUAL "Intel"
      OR CMAKE_CXX_COMPILER MATCHES "icl"
      OR CMAKE_CXX_COMPILER MATCHES "icpc")
		set(_APM_toolset "intel")
	elseif(MSVC)
		set(_APM_toolset "msvc")
	elseif(BORLAND)
		set(_APM_toolset "borland")
	elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
		set(_APM_toolset "clang")
	elseif(CMAKE_COMPILER_IS_GNUCXX)
		set(_APM_toolset "gcc")
	else()
		message(FATAL_ERROR "Unknown compiler, unable to compute toolset")
	endif()

	APM_compiler_version(l_APM_version)

    if(l_APM_version AND (NOT (CMAKE_SYSTEM_NAME MATCHES "Darwin")))
		set(${a_APM_result} "${_APM_toolset}-${l_APM_version}" PARENT_SCOPE)
	else()
		set(${a_APM_result} "${_APM_toolset}" PARENT_SCOPE)
	endif()
endfunction()



function(APM_install)
	# Managing arguments
	set(l_APM_OptionArguments OPTIONAL REQUIRED QUIET EXACT)
	set(l_APM_OneValueArguments VERSION)
	set(l_APM_MultipleValuesArguments TARGETS COMPONENTS)
	cmake_parse_arguments(l_APM_install "${l_APM_OptionArguments}" "${l_APM_OneValueArguments}" "${l_APM_MultipleValuesArguments}" ${ARGN})
	
	APM_message(STATUS "Installing Boost libraries ${l_APM_install_COMPONENTS}")
	

	if(NOT l_APM_install_VERSION)
		set(l_APM_install_VERSION "1.57.0")
	endif(NOT l_APM_install_VERSION)
	string(REPLACE "." "_" l_APM_underscore_version ${l_APM_install_VERSION})
	
	#---------------------------------------------------------------------------------------#
	#-										DOWNLOAD									   -#
	#---------------------------------------------------------------------------------------#
    if(CMAKE_SYSTEM_NAME MATCHES "Windows")
        set(l_APM_PACKAGE_TYPE zip)
    else()
        set(l_APM_PACKAGE_TYPE tar.gz)
    endif()
	
	set(l_APM_archiveName "boost_${l_APM_underscore_version}.${l_APM_PACKAGE_TYPE}")
	set(l_APM_BoostLocation "http://sourceforge.net/projects/boost/files/boost/${l_APM_install_VERSION}/${l_APM_archiveName}")
	set(l_APM_BoostLocalDir "${APM_REPOSITORY_DIR}/Boost/${l_APM_install_VERSION}")
	set(l_APM_BoostLocalArchive "${l_APM_BoostLocalDir}/download/${l_APM_archiveName}")
	
    if(NOT (EXISTS "${l_APM_BoostLocalArchive}"))
        APM_message(STATUS "Downloading Boost ${l_APM_install_VERSION} from ${l_APM_BoostLocation}.") 
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
	APM_message(STATUS "Extracting Boost ${l_APM_install_VERSION}...")
	execute_process(COMMAND ${CMAKE_COMMAND} -E tar xzf "${l_APM_BoostLocalArchive}" WORKING_DIRECTORY "${l_APM_BoostLocalDir}/source/")
	
	
	#---------------------------------------------------------------------------------------#
	#-										BOOTSTRAP 									   -#
	#---------------------------------------------------------------------------------------#
	if(CMAKE_SYSTEM_NAME MATCHES "Windows")
        set(l_APM_BOOSTRAPER ${l_APM_BoostLocalDir}/bootstrap.bat)
        set(l_APM_B2 ${l_APM_BoostLocalDir}/b2.exe)
        set(l_APM_DYNLIB_EXTENSION .dll)
    elseif(CMAKE_SYSTEM_NAME MATCHES "Darwin")
        set(l_APM_BOOSTRAPER ${l_APM_BoostLocalDir}/bootstrap.sh)
        set(l_APM_B2 ${l_APM_BoostLocalDir}/b2)
        set(l_APM_DYNLIB_EXTENSION .dylib)
    elseif(CMAKE_SYSTEM_NAME MATCHES "Linux")
        set(l_APM_BOOSTRAPER ${l_APM_BoostLocalDir}/bootstrap.sh)
        set(l_APM_B2 ${l_APM_BoostLocalDir}/b2)
        set(l_APM_DYNLIB_EXTENSION .so)
    else()
        APM_message(FATAL_ERROR "Platform not suported. Unable to install boost libraries.")
    endif()

    if(NOT (EXISTS ${l_APM_B2}))
        APM_message(STATUS "Bootstrapping Boost ${l_APM_install_VERSION}...")
        execute_process(COMMAND "${l_APM_BOOSTRAPER} --prefix=${l_APM_BoostLocalDir}/source/" 
			WORKING_DIRECTORY "${l_APM_BoostLocalDir}/source/"
			RESULT_VARIABLE l_APM_Result 
			OUTPUT_VARIABLE l_APM_Output 
			ERROR_VARIABLE l_APM_Error)
        if(NOT l_APM_Result EQUAL 0)
            APM_message(FATAL_ERROR "Failed running bootstrap :\n${Output}\n${Error}\n")
        endif()
    endif()
	
	#---------------------------------------------------------------------------------------#
	#-										BUILD	 									   -#
	#---------------------------------------------------------------------------------------#
	
	APM_compute_toolset(l_APM_toolset)
	
    if(l_APM_install_COMPONENTS)
        APM_message(STATUS "Building Boost ${l_APM_install_VERSION} components with toolset ${l_APM_toolset}...")

		#TODO : Add the possibility to launch parallel compilation
		set(l_APM_B2CallString  ${l_APM_B2} --includedir=${l_APM_BoostLocalDir} 
                                              --toolset=${l_APM_toolset} 
                                              -j1 
                                              --layout=versioned 
                                              --build-type=complete)
		foreach(l_APM_component ${l_APM_install_COMPONENTS})
			set(l_APM_B2CallString ${l_APM_B2CallString} --with-${l_APM_component})
		endforeach()
		
		execute_process(${l_APM_B2CallString})
    endif()
endfunction()
	
endfunction()
