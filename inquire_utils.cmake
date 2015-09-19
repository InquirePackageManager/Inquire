if(IPM_UTILS_INCLUDE_GUARD)
	inquire_message(DEBUG "IPM utils already included.")
else()
	set(IPM_UTILS_INCLUDE_GUARD ON)

	#################################################
	#  inquire_message function
	#################################################
	#TODO : create varibales like IPM_LOG_LEVEL_INFO_PREFIX to configure output...
	function(inquire_message)
		set(l_inquire_message_OptionArguments ALL DEBUG ERROR FATAL INFO OFF TRACE WARN)
		cmake_parse_arguments(l_inquire_message "${l_inquire_message_OptionArguments}" "" "" ${ARGN})
		if(l_inquire_message_DEBUG AND (IPM_LOG_LEVEL_ALL OR IPM_LOG_LEVEL_DEBUG))
			message(STATUS "DEBUG : " ${l_inquire_message_UNPARSED_ARGUMENTS})
		elseif(l_inquire_message_ERROR AND (IPM_LOG_LEVEL_ALL OR IPM_LOG_LEVEL_ERROR))
			message(SEND_ERROR "ERROR : " ${l_inquire_message_UNPARSED_ARGUMENTS})
		elseif(l_inquire_message_FATAL)# For fatal errors, always print it...
			message(FATAL_ERROR "FATAL ERROR : " ${l_inquire_message_UNPARSED_ARGUMENTS})
		elseif(l_inquire_message_INFO AND (IPM_LOG_LEVEL_ALL OR IPM_LOG_LEVEL_INFO))
			message(STATUS "INFO : " ${l_inquire_message_UNPARSED_ARGUMENTS})
		elseif(l_inquire_message_TRACE AND (IPM_LOG_LEVEL_ALL OR IPM_LOG_LEVEL_TRACE))
			message(STATUS "TRACE : " ${l_inquire_message_UNPARSED_ARGUMENTS})
		elseif(l_inquire_message_WARN AND (IPM_LOG_LEVEL_ALL OR IPM_LOG_LEVEL_WARN))
			message(WARNING "WARN : " ${l_inquire_message_UNPARSED_ARGUMENTS})
		else()
			message(STATUS ${l_inquire_message_UNPARSED_ARGUMENTS})
		endif()
	endfunction()

	function(IPM_defaultSet a_IPM_Variable)
		if(NOT DEFINED ${a_IPM_Variable})
			set(${a_IPM_Variable} ${ARGN} PARENT_SCOPE)
		endif()
	endfunction()

	function(IPM_ExternalProject_Add a_IPM_name a_IPM_version)
		inquire_message(DEBUG "Installing project ${a_IPM_name} in version ${a_IPM_version} via ExternalProject.")
		# Managing arguments
		set(l_IPM_OptionArguments OPTIONAL REQUIRED QUIET EXACT)
		set(l_IPM_OneValueArguments VERSION PACKAGE_REPOSITORY URL SOURCE_DIR)
		set(l_IPM_MultipleValuesArguments TARGETS)
		cmake_parse_arguments(l_IPM_install "${l_IPM_OptionArguments}" "${l_IPM_OneValueArguments}" "${l_IPM_MultipleValuesArguments}" ${ARGN})


		#verify integrity of parameters and configure the call to ExternalProject_Add
		set(l_IPM_arguments ${a_IPM_name})
		if(DEFINED l_IPM_install_SOURCE_DIR)
			list(APPEND l_IPM_arguments
									SOURCE_DIR ${l_IPM_install_SOURCE_DIR}
									DOWNLOAD_COMMAND "")
			if(DEFINED l_IPM_install_PACKAGE_REPOSITORY)
				inquire_message(WARNING "PACKAGE_REPOSITORY in conjuction with SOURCE_DIR. PACKAGE_REPOSITORY will be ignored.")
			endif()
			if(DEFINED l_IPM_install_URL)
				inquire_message(WARNING "URL and SOURCE_DIR given. URL will be ignored.")
			endif()
			set(l_IPM_RootProjectDir "${l_IPM_install_SOURCE_DIR}/..")
		else()
			if(NOT DEFINED l_IPM_install_URL)
				inquire_message(FATAL_ERROR "No URL or SOURCE_DIR given.")
			else()
				if(NOT DEFINED l_IPM_install_PACKAGE_REPOSITORY)
					#set default value to the package repository
					set(l_IPM_install_PACKAGE_REPOSITORY  ${IPM_DEFAULT_PACKAGE_REPOSITORY})
				endif()
				list(APPEND l_IPM_arguments
										URL ${l_IPM_install_URL})
				IPM_Repository_getLocation(${l_IPM_install_PACKAGE_REPOSITORY} l_IPM_repo_location)
				set(l_IPM_RootProjectDir "${l_IPM_repo_location}/${a_IPM_name}/${a_IPM_version}")
			endif()
		endif()

		list(APPEND l_IPM_arguments
			STAMP_DIR ${l_IPM_RootProjectDir}/stamps
			TMP_DIR ${l_IPM_RootProjectDir}/tmp
			BINARY_DIR ${l_IPM_RootProjectDir}/build/${IPM_COMPILER_ID}
			CMAKE_ARGS
				${CMAKE_PROPAGATED_VARIABLES}
				-DCMAKE_INSTALL_PREFIX:PATH=${l_IPM_RootProjectDir}/install/${IPM_COMPILER_ID}
				-DBUILD_TESTING=1
			)


		ExternalProject_Add(${l_IPM_arguments})
	endfunction()

	function(IPM_get_subdirectories a_IPM_folder a_IPM_subdir_list)
		file(GLOB l_IPM_children RELATIVE ${a_IPM_folder} ${a_IPM_folder}/*)
		set(${a_IPM_subdir_list} )
		foreach(l_IPM_child ${l_IPM_children})
			if(IS_DIRECTORY ${a_IPM_folder}/${l_IPM_child})
				list(APPEND ${a_IPM_subdir_list} ${l_IPM_child})
			endif()
		endforeach()
		set(${a_IPM_subdir_list} ${${a_IPM_subdir_list}} PARENT_SCOPE)
	endfunction()

endif()
