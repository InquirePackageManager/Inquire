if(APM_COMPILER_UTILS_INCLUDE_GUARD)
	APM_message(DEBUG "APM compiler utils already included.")
else()
	set(APM_COMPILER_UTILS_INCLUDE_GUARD ON)

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


function(APM_boost_set_clang_compiler a_APM_lib_dir a_APM_result)
	# FindBoost auto-compute does not care about Clang?
	if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
		if(NOT (CMAKE_SYSTEM_NAME MATCHES "Darwin"))
			APM_compiler_version(l_APM_clang_version)#In boost/install/utils.cmake
			#Some regex kung-fu
			string(REGEX REPLACE "([0-9])\\.([0-9])" "\\1\\2" l_APM_clang_version ${l_APM_clang_version})
			set(l_APM_boost_compiler "-clang${l_APM_clang_version}")
		else()
			#On Darwin (OSX) the suffix is extracted from library binary names. That's why this setup is
			#done after build
			file(GLOB l_APM_clang_libs RELATIVE ${a_APM_lib_dir} "${a_APM_lib_dir}/*clang*")
			if(l_APM_clang_libs)
				list(GET l_APM_clang_libs 0 l_APM_clang_lib)
				message(STATUS ">>> Suffix source: ${l_APM_clang_lib}")

				#More kung-fu
				string(REGEX REPLACE ".*(-clang-darwin[0-9]+).*" "\\1" l_APM_clang_lib_suffix ${l_APM_clang_lib})
				message(STATUS ">>>> Suffix: ${l_APM_clang_lib_suffix}")
				set(l_APM_boost_compiler ${l_APM_clang_lib_suffix})
			else()
				APM_message(FATAL_ERROR "Unable to compute Boost compiler suffix from Clang libraries names")
			endif()
		endif()
		message(STATUS ">>>> Setting l_APM_boost_compiler suffix manually for clang: ${l_APM_boost_compiler}")
		set(${a_APM_result} ${l_APM_boost_compiler} PARENT_SCOPE)
	endif()
endfunction()

endif()
