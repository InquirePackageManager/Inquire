if(APM_UTILS_INCLUDE_GUARD)
	APM_message(DEBUG "APM utils already included.")
else()
	set(APM_UTILS_INCLUDE_GUARD ON)

	#################################################
	#  APM_message function
	#################################################
	#TODO : create varibales like APM_LOG_LEVEL_INFO_PREFIX to configure output...
	function(APM_message)
		set(l_APM_message_OptionArguments ALL DEBUG ERROR FATAL INFO OFF TRACE WARN)
		cmake_parse_arguments(l_APM_message "${l_APM_message_OptionArguments}" "" "" ${ARGN})
		if(l_APM_message_DEBUG AND (APM_LOG_LEVEL_ALL OR APM_LOG_LEVEL_DEBUG))
			message(STATUS "DEBUG : " ${l_APM_message_UNPARSED_ARGUMENTS})
		elseif(l_APM_message_ERROR AND (APM_LOG_LEVEL_ALL OR APM_LOG_LEVEL_ERROR))
			message(SEND_ERROR "ERROR : " ${l_APM_message_UNPARSED_ARGUMENTS})
		elseif(l_APM_message_FATAL)# For fatal errors, always print it...
			message(FATAL_ERROR "FATAL ERROR : " ${l_APM_message_UNPARSED_ARGUMENTS})
		elseif(l_APM_message_INFO AND (APM_LOG_LEVEL_ALL OR APM_LOG_LEVEL_INFO))
			message(STATUS "INFO : " ${l_APM_message_UNPARSED_ARGUMENTS})
		elseif(l_APM_message_TRACE AND (APM_LOG_LEVEL_ALL OR APM_LOG_LEVEL_TRACE))
			message(STATUS "TRACE : " ${l_APM_message_UNPARSED_ARGUMENTS})
		elseif(l_APM_message_WARN AND (APM_LOG_LEVEL_ALL OR APM_LOG_LEVEL_WARN))
			message(WARNING "WARN : " ${l_APM_message_UNPARSED_ARGUMENTS})
		else()
			message(STATUS ${l_APM_message_UNPARSED_ARGUMENTS})
		endif()
	endfunction()

	function(APM_defaultSet a_APM_Variable)
		if(NOT DEFINED ${a_APM_Variable})
			set(${a_APM_Variable} ${ARGN} PARENT_SCOPE)
		endif()
	endfunction()

	function(APM_ExternalProject_Add a_APM_name a_APM_version)
		APM_message(DEBUG "Installing project ${a_APM_name} in version ${a_APM_version} via ExternalProject.")
		# Managing arguments
		set(l_APM_OptionArguments OPTIONAL REQUIRED QUIET EXACT)
		set(l_APM_OneValueArguments VERSION PACKAGE_REPOSITORY URL SOURCE_DIR)
		set(l_APM_MultipleValuesArguments TARGETS)
		cmake_parse_arguments(l_APM_install "${l_APM_OptionArguments}" "${l_APM_OneValueArguments}" "${l_APM_MultipleValuesArguments}" ${ARGN})


		#verify integrity of parameters and configure the call to ExternalProject_Add
		set(l_APM_arguments ${a_APM_name})
		if(DEFINED l_APM_install_SOURCE_DIR)
			list(APPEND l_APM_arguments
									SOURCE_DIR ${l_APM_install_SOURCE_DIR}
									DOWNLOAD_COMMAND "")
			if(DEFINED l_APM_install_PACKAGE_REPOSITORY)
				APM_message(WARNING "PACKAGE_REPOSITORY in conjuction with SOURCE_DIR. PACKAGE_REPOSITORY will be ignored.")
			endif()
			if(DEFINED l_APM_install_URL)
				APM_message(WARNING "URL and SOURCE_DIR given. URL will be ignored.")
			endif()
			set(l_APM_RootProjectDir "${l_APM_install_SOURCE_DIR}/..")
		else()
			if(NOT DEFINED l_APM_install_URL)
				APM_message(FATAL_ERROR "No URL or SOURCE_DIR given.")
			else()
				if(NOT DEFINED l_APM_install_PACKAGE_REPOSITORY)
					#set default value to the package repository
					set(l_APM_install_PACKAGE_REPOSITORY  ${APM_DEFAULT_PACKAGE_REPOSITORY})
				endif()
				list(APPEND l_APM_arguments
										URL ${l_APM_install_URL})
				APM_Repository_getLocation(${l_APM_install_PACKAGE_REPOSITORY} l_APM_repo_location)
				set(l_APM_RootProjectDir "${l_APM_repo_location}/${a_APM_name}/${a_APM_version}")
			endif()
		endif()

		list(APPEND l_APM_arguments
			STAMP_DIR ${l_APM_RootProjectDir}/stamps
			TMP_DIR ${l_APM_RootProjectDir}/tmp
			BINARY_DIR ${l_APM_RootProjectDir}/build/${APM_COMPILER_ID}
			CMAKE_ARGS
				${CMAKE_PROPAGATED_VARIABLES}
				-DCMAKE_INSTALL_PREFIX:PATH=${l_APM_RootProjectDir}/install/${APM_COMPILER_ID}
				-DBUILD_TESTING=1
			)


		ExternalProject_Add(${l_APM_arguments})
	endfunction()

	function(APM_get_subdirectories a_APM_folder a_APM_subdir_list)
		file(GLOB l_APM_children RELATIVE ${a_APM_folder} ${a_APM_folder}/*)
		set(${a_APM_subdir_list} )
		foreach(l_APM_child ${l_APM_children})
			if(IS_DIRECTORY ${a_APM_folder}/${l_APM_child})
				list(APPEND ${a_APM_subdir_list} ${l_APM_child})
			endif()
		endforeach()
		set(${a_APM_subdir_list} ${${a_APM_subdir_list}} PARENT_SCOPE)
	endfunction()

endif()
