if(IPM_COMPILER_UTILS_INCLUDE_GUARD)
	inquire_message(DEBUG "IPM compiler utils already included.")
else()
	set(IPM_COMPILER_UTILS_INCLUDE_GUARD ON)

	function(IPM_compiler_version a_IPM_result)
		if(CMAKE_CXX_COMPILER_ID STREQUAL "Intel"
				OR CMAKE_CXX_COMPILER MATCHES "icl"
				OR CMAKE_CXX_COMPILER MATCHES "icpc")
			set (l_IPM_version "")
		elseif (MSVC14)
			set(l_IPM_version "14.0")
		elseif (MSVC12)
			set(l_IPM_version "12.0")
		elseif (MSVC11)
			set(l_IPM_version "11.0")
		elseif (MSVC10)
			set(l_IPM_version "10.0")
		elseif (MSVC90)
			set(l_IPM_version "9.0")
		elseif (MSVC80)
			set(l_IPM_version "8.0")
		elseif (MSVC71)
			set(l_IPM_version "7.1")
		elseif (MSVC70) # Good luck! (That's from Kitware, but I'm not sure here at biicode we support VC6.0 and 7.0 too. So good luck from the hive too!)
			set(l_IPM_version "7.0") # yes, this is correct
		elseif (MSVC60) # Good luck!
			set(l_IPM_version "6.0") # yes, this is correct
		elseif (BORLAND)
			set(l_IPM_version "")
		elseif(CMAKE_CXX_COMPILER_ID STREQUAL "SunPro")
			set(l_IPM_version "")
		else()
		if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
			EXECUTE_PROCESS( COMMAND ${CMAKE_CXX_COMPILER} --version OUTPUT_VARIABLE l_IPM_version )
			string (REGEX REPLACE ".*clang version ([0-9]+\\.[0-9]+).*" "\\1" l_IPM_version ${l_IPM_version})
		elseif(CMAKE_COMPILER_IS_GNUCXX)
			EXECUTE_PROCESS( COMMAND ${CMAKE_CXX_COMPILER} -dumpversion OUTPUT_VARIABLE l_IPM_version)
			string (REGEX REPLACE "([0-9])\\.([0-9])\\.([0-9])" "\\1.\\2.\\3" l_IPM_version ${l_IPM_version})
			string(STRIP ${l_IPM_version} l_IPM_version) #Remove extra newline character
		endif()
		endif()
		set(${a_IPM_result} ${l_IPM_version} PARENT_SCOPE)
	endfunction()

	function(IPM_compute_toolset a_IPM_result)
		if(CMAKE_CXX_COMPILER_ID STREQUAL "Intel"
				OR CMAKE_CXX_COMPILER MATCHES "icl"
				OR CMAKE_CXX_COMPILER MATCHES "icpc")
			set(_IPM_toolset "intel")
		elseif(MSVC)
			set(_IPM_toolset "msvc")
		elseif(BORLAND)
			set(_IPM_toolset "borland")
		elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
			set(_IPM_toolset "clang")
		elseif(CMAKE_COMPILER_IS_GNUCXX)
			set(_IPM_toolset "gcc")
		else()
			message(FATAL_ERROR "Unknown compiler, unable to compute toolset")
		endif()

		IPM_compiler_version(l_IPM_version)

		if(l_IPM_version AND (NOT (CMAKE_SYSTEM_NAME MATCHES "Darwin")))
			set(${a_IPM_result} "${_IPM_toolset}-${l_IPM_version}" PARENT_SCOPE)
		else()
			set(${a_IPM_result} "${_IPM_toolset}" PARENT_SCOPE)
		endif()
	endfunction()


function(IPM_boost_set_clang_compiler a_IPM_lib_dir a_IPM_result)
	# FindBoost auto-compute does not care about Clang?
	if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
		if(NOT (CMAKE_SYSTEM_NAME MATCHES "Darwin"))
			IPM_compiler_version(l_IPM_clang_version)#In boost/install/utils.cmake
			#Some regex kung-fu
			string(REGEX REPLACE "([0-9])\\.([0-9])" "\\1\\2" l_IPM_clang_version ${l_IPM_clang_version})
			set(l_IPM_boost_compiler "-clang${l_IPM_clang_version}")
		else()
			#On Darwin (OSX) the suffix is extracted from library binary names. That's why this setup is
			#done after build
			file(GLOB l_IPM_clang_libs RELATIVE ${a_IPM_lib_dir} "${a_IPM_lib_dir}/*clang*")
			if(l_IPM_clang_libs)
				list(GET l_IPM_clang_libs 0 l_IPM_clang_lib)
				message(STATUS ">>> Suffix source: ${l_IPM_clang_lib}")

				#More kung-fu
				string(REGEX REPLACE ".*(-clang-darwin[0-9]+).*" "\\1" l_IPM_clang_lib_suffix ${l_IPM_clang_lib})
				message(STATUS ">>>> Suffix: ${l_IPM_clang_lib_suffix}")
				set(l_IPM_boost_compiler ${l_IPM_clang_lib_suffix})
			else()
				inquire_message(FATAL_ERROR "Unable to compute Boost compiler suffix from Clang libraries names")
			endif()
		endif()
		message(STATUS ">>>> Setting l_IPM_boost_compiler suffix manually for clang: ${l_IPM_boost_compiler}")
		set(${a_IPM_result} ${l_IPM_boost_compiler} PARENT_SCOPE)
	endif()
endfunction()

endif()
