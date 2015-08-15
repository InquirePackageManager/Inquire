include(CMakeParseArguments)
include(ExternalProject)

if(APM_INCLUDE_GUARD)
	APM_message(DEBUG "APM already included.")
else(APM_INCLUDE_GUARD)
	set(APM_INCLUDE_GUARD ON)

	include(${CMAKE_CURRENT_LIST_DIR}/APM_repository.cmake)
	include(${CMAKE_CURRENT_LIST_DIR}/APM_utils.cmake)
	include(${CMAKE_CURRENT_LIST_DIR}/APM_arguments_utils.cmake)
	include(${CMAKE_CURRENT_LIST_DIR}/APM_compiler_utils.cmake)
	include(${CMAKE_CURRENT_LIST_DIR}/APM_module_utils.cmake)

	#################################################
	#				User functions					#
	#################################################

	function(APM_add_module_repository a_APM_name a_APM_type a_APM_address)
		APM_message(DEBUG "Creating module repository ${a_APM_name} of type ${a_APM_type} and address ${a_APM_address}.")

		#create the APM_module_repositories global variable if needed
		if(NOT DEFINED APM_module_repositories)
			set(APM_module_repositories PARENT_SCOPE)
		endif()

		#check if the repository already exists
		if(DEFINED ${a_APM_name})
			APM_message(SEND_ERROR "Repository ${${a_APM_name}} already exists. It will be overriden.")
		endif()

		#handle backslashes
		string(REPLACE "\\" "/" a_APM_address ${a_APM_address})

		#create repository
		APM_Repository_create(${a_APM_type} ${a_APM_address} ${a_APM_name})
		#declare repository in parent scope
		APM_parentScope(${a_APM_name})

		#append repository to the list of repositories in current scope
		list(APPEND APM_module_repositories ${a_APM_name})
		#apply modifications in parent scope
		APM_parentScope(APM_module_repositories)
	endfunction()

	function(APM_add_package_repository a_APM_name a_APM_type a_APM_address)
		APM_message(DEBUG "Creating package repository ${a_APM_name} of type ${a_APM_type} and address ${a_APM_address}.")
		#create the APM_package_repositories global variable if needed
		if(NOT DEFINED APM_package_repositories)
			set(APM_package_repositories PARENT_SCOPE)
		endif()

		#check if the repository already exists
		if(DEFINED ${a_APM_name})
			APM_message(SEND_ERROR "Repository ${${a_APM_name}} already exists. It will be overriden.")
		endif()

		#handle backslashes
		string(REPLACE "\\" "/" a_APM_address ${a_APM_address})

		#create repository
		APM_Repository_create(${a_APM_type} ${a_APM_address} ${a_APM_name})
		#declare repository in parent scope
		APM_parentScope(${a_APM_name})

		#append repository to the list of repositories in current scope
		list(APPEND APM_package_repositories ${a_APM_name})
		#apply modifications in parent scope
		APM_parentScope(APM_package_repositories)
	endfunction()

	function(require a_APM_projectName)
		###########################################################################################################
		#																						Managing arguments																						#
		###########################################################################################################
		set(l_APM_OptionArguments REQUIRED QUIET EXACT)
		set(l_APM_OneValueArguments VERSION PACKAGE_REPOSITORY)
		set(l_APM_MultipleValuesArguments TARGETS COMPONENTS)
		cmake_parse_arguments(l_APM_require "${l_APM_OptionArguments}" "${l_APM_OneValueArguments}" "${l_APM_MultipleValuesArguments}" ${ARGN})

		# update the APM_QUIET global argument fior the current scope (it will be automatically restored after the "require" function call)
		if(DEFINED l_APM_require_QUIET)
			if(${l_APM_require_QUIET})
				set(APM_QUIET TRUE)
			endif()
		endif()

		###########################################################################################################
		#																					Function implementation																					#
		###########################################################################################################

		APM_message(STATUS "Requiring module APM_${a_APM_projectName}...")

		# Each l_APM_repo contains the name of a repository variable
		foreach(l_APM_repo ${APM_module_repositories})
			APM_require_module(${l_APM_repo} ${a_APM_projectName} l_APM_module_path)
			if(DEFINED l_APM_module_path)
				break()
			endif()
		endforeach(l_APM_repo)

		#if we did not find the module, either return or send an error depending on the "REQUIRED" flag
		if(NOT DEFINED l_APM_module_path)
			set(APM_${a_APM_projectName}_FOUND FALSE PARENT_SCOPE)
			APM_message(STATUS "Requiring module APM_${a_APM_projectName}... NOT FOUND")
			if(${l_APM_require_REQUIRED})
				APM_message(FATAL_ERROR "Unable to find the required module APM_${a_APM_projectName}. Aborting.")
			endif()
			return()
		endif()

		APM_message(STATUS "Requiring module APM_${a_APM_projectName}... FOUND")
		set(APM_${a_APM_projectName}_FOUND TRUE PARENT_SCOPE)
		include(${l_APM_module_path})

		#if a PACKAGE_REPOSITORY is given, use it. Otherwise, try to find a suitable installed version before.
		if(DEFINED l_APM_require_PACKAGE_REPOSITORY)
			set(l_APM_package_repositories ${l_APM_require_PACKAGE_REPOSITORY})
		else()
			set(l_APM_package_repositories ${APM_package_repositories})
		endif()

		# if the user have set APM_${a_APM_projectName}_DIR, use it. Otherwise try to find the package.
		if(DEFINED APM_${a_APM_projectName}_DIR)
			APM_message(STATUS "Using provided path as package root : ${APM_${a_APM_projectName}_DIR}")
			set(l_APM_install_dir ${APM_${a_APM_projectName}_DIR})
		else()
			# try to find a suitable installed version of the project
			foreach(l_APM_repo ${l_APM_package_repositories})
				APM_Repository_getLocation(${l_APM_repo} l_APM_repo_location)
				APM_message(STATUS "Searching for installation of project ${a_APM_projectName} in repository ${l_APM_repo_location}...")

				#first, check if there is a ${a_APM_projectName} folder
				set(l_APM_need_install FALSE)
				if(NOT EXISTS ${l_APM_repo_location}/${a_APM_projectName})
					APM_message(STATUS "Searching for installation of project ${a_APM_projectName} in repository ${l_APM_repo_location}... NOT FOUND")
					set(l_APM_need_install TRUE)
					continue()
				endif()

				# then check if a valid version is available and store it in l_APM_retained_version
				APM_get_subdirectories(${l_APM_repo_location}/${a_APM_projectName} l_APM_version_dirs)

				if(DEFINED l_APM_require_VERSION)
					#if the user specified a version, try to find a matching one
					unset(l_APM_retained_version)
					foreach(l_APM_version_dir ${l_APM_version_dirs})
						set(l_APM_version_compatible FALSE)
						# first check that the project has been installed. If so, chack version compatibility.
						if(EXISTS ${l_APM_repo_location}/${a_APM_projectName}/${l_APM_version_dir}/install)
							if(${l_APM_version_dir} VERSION_EQUAL ${l_APM_require_VERSION})
								APM_message(STATUS "Searching for installation of project ${a_APM_projectName} in repository ${l_APM_repo_location}... FOUND")
								set(l_APM_version_compatible TRUE)
							else()
								if(${l_APM_version_dir} VERSION_GREATER ${l_APM_require_VERSION})
									APM_message(STATUS "Searching for installation of project ${a_APM_projectName} in repository ${l_APM_repo_location}... FOUND")
									set(l_APM_version_compatible TRUE)
								endif()
							endif()
						endif()
						if(${l_APM_version_compatible})
							set(l_APM_retained_version ${l_APM_version_dir})
							break()
						endif()
					endforeach()

					if(NOT ${l_APM_version_compatible})
						APM_message(STATUS "Searching for installation of project ${a_APM_projectName} in repository ${l_APM_repo_location}... NOT FOUND")
					endif()
				else()
					#if the user did not specify a version, use the most recent one
					#TODO
					APM_message(FATAL_ERROR "NOT YET IMPLEMENTED")
				endif()

				if(${l_APM_version_compatible})
					#if we found a valid version, break the loop and save the repository
					set(l_APM_package_repository ${l_APM_repo})
					break()
				else()
					#otherwise, go to the next iteration
					set(l_APM_need_install TRUE)
					continue()
				endif()
			endforeach(l_APM_repo)

			# if no valid repository was found, use the repository given as parameter or the default one
			if(NOT DEFINED l_APM_package_repository)
				# if a package repository was given, install the package in this repository. Otherwise use the default one.
				if(DEFINED l_APM_require_PACKAGE_REPOSITORY)
					set(l_APM_package_repository ${l_APM_require_PACKAGE_REPOSITORY})
				else()
					set(l_APM_package_repository APM_DEFAULT_PACKAGE_REPOSITORY)
				endif()
			endif()

			# if no compatible version was defined or found, set the version to the one given by the user.
			if(NOT DEFINED l_APM_version_compatible)
				set(l_APM_retained_version ${l_APM_require_VERSION})
			endif()
			if(NOT ${l_APM_version_compatible})
				set(l_APM_retained_version ${l_APM_require_VERSION})
			endif()

			#if we need to install the package, do it now, before searching for the good compiler version.
			if(${l_APM_need_install})
				set(l_APM_install_package_args )
				list(APPEND l_APM_install_package_args ${l_APM_require_REQUIRED} ${l_APM_require_QUIET})
				if(DEFINED l_APM_retained_version)
					list(APPEND l_APM_install_package_args VERSION ${l_APM_retained_version})
				endif()
				if(DEFINED l_APM_require_COMPONENTS)
					list(APPEND l_APM_install_package_args COMPONENTS ${l_APM_require_COMPONENTS})
				endif()
				if(DEFINED l_APM_require_TARGETS)
					list(APPEND l_APM_install_package_args TARGETS ${l_APM_require_TARGETS})
				endif()

				set(APM_install_${a_APM_projectName} OFF CACHE BOOL "Install package ${a_APM_projectName} ? To use an already installed version, set the APM_${a_APM_projectName}_DIR variable to the root folder.")
				if(${APM_install_${a_APM_projectName}})
					APM_install_package(${l_APM_install_package_args} PACKAGE_REPOSITORY ${l_APM_package_repository})
				endif()
				set(l_APM_retained_compiler_version ${APM_COMPILER_ID})
			else()
				# check if the compiler used to compile the package match
				set(l_APM_need_compile TRUE)
				APM_Repository_getLocation(${l_APM_package_repository} l_APM_repo_location)
				set(l_APM_install_dir ${l_APM_repo_location}/${a_APM_projectName}/${l_APM_retained_version}/install/)
				APM_get_subdirectories(${l_APM_install_dir} l_APM_compiler_version_dirs)

				foreach(l_APM_compiler_version_dir ${l_APM_compiler_version_dirs})
					APM_message(STATUS "Searching for compatible compiled version in ${l_APM_install_dir}...")
					if(${l_APM_compiler_version_dir} MATCHES ${APM_COMPILER_ID})
						APM_message(STATUS "Searching for compatible compiled version in ${l_APM_install_dir}... FOUND")
						set(l_APM_retained_compiler_version ${l_APM_compiler_version_dir})
						set(l_APM_need_compile FALSE)
						break()
					endif()
				endforeach()

				#if we do not have a matching compiler version, ask for a recompilation
				if(${l_APM_need_compile})
					APM_message(STATUS "Searching for compatible compiled version in ${l_APM_install_dir}... NOT FOUND")

					set(l_APM_compile_package_args )
					list(APPEND l_APM_compile_package_args ${l_APM_require_REQUIRED} ${l_APM_require_QUIET})
					if(DEFINED l_APM_retained_version)
						list(APPEND l_APM_compile_package_args VERSION ${l_APM_retained_version})
					endif()
					if(DEFINED l_APM_require_COMPONENTS)
						list(APPEND l_APM_compile_package_args COMPONENTS ${l_APM_require_COMPONENTS})
					endif()
					if(DEFINED l_APM_require_TARGETS)
						list(APPEND l_APM_compile_package_args TARGETS ${l_APM_require_TARGETS})
					endif()

					APM_compile_package(${l_APM_compile_package_args} SOURCE_DIR ${l_APM_repo_location}${a_APM_projectName}/${l_APM_retained_version}/source)
					set(l_APM_need_compile FALSE)
				endif()
			endif()

			if(${l_APM_need_install} AND NOT ${APM_install_${a_APM_projectName}})
				set(l_APM_msg  "No compatible installed version of ${a_APM_projectName} found. Set APM_install_${a_APM_projectName} to TRUE if you want top install the package, or set APM_${a_APM_projectName}_DIR to the path of a compatible installed version.")
				if(${l_APM_require_REQUIRED})
					APM_message(SEND_ERROR ${l_APM_msg})
				else()
					APM_message(STATUS ${l_APM_msg})
				endif()
			endif()

			# at this point, we should have a usable version. So configure it.
			set(l_APM_install_dir ${l_APM_repo_location}/${a_APM_projectName}/${l_APM_retained_version}/install/${l_APM_retained_compiler_version})
		endif()

		if(DEFINED l_APM_install_dir)
			string(LENGTH "${l_APM_install_dir}" l_APM_str_length)
			if(l_APM_str_length GREATER 0)
				APM_configure_targets(INSTALL_DIR ${l_APM_install_dir} COMPONENTS ${l_APM_require_COMPONENTS} TARGETS ${l_APM_require_TARGETS} VERSION ${l_APM_retained_version})
			endif()
		endif()
	endfunction()


	############################
	##     Initialization     ##
	############################
	# if true, no messages will be printed
	APM_defaultSet(APM_QUIET FALSE)

	# if true, debug messages will be printed to screen.
	APM_defaultSet(APM_DEBUG FALSE)

	# APM configuration folder
	if(WIN32 OR CYGWIN)
		set(APM_DATA_DIRECTORY $ENV{USERPROFILE}/.apm)
	else()
		set(APM_DATA_DIRECTORY $ENV{HOME}/.apm)
	endif()
	set(APM_CONFIG_FILE ${APM_DATA_DIRECTORY}/settings.cmake)

	if(EXISTS ${APM_DATA_DIRECTORY})
		APM_message(DEBUG "${APM_DATA_DIRECTORY} already exists.")
	else()
		APM_message(DEBUG "${APM_DATA_DIRECTORY} does not exist.")
		APM_message(DEBUG "Creating directory ${APM_DATA_DIRECTORY}...")
		file(MAKE_DIRECTORY ${APM_DATA_DIRECTORY})
		if(EXISTS ${APM_DATA_DIRECTORY})
			APM_message(DEBUG "Creating directory ${APM_DATA_DIRECTORY}... OK")
		else()
			APM_message(SEND_ERROR "Creating directory ${APM_DATA_DIRECTORY}... ERROR")
			APM_message(SEND_ERROR "Directory ${APM_DATA_DIRECTORY} could not be created. User settings will not be available.")
		endif()
	endif()
	if(NOT EXISTS ${APM_CONFIG_FILE})
		APM_message(DEBUG "Creating default configuration file in ${APM_CONFIG_FILE}...")
		file(WRITE ${APM_CONFIG_FILE} "#APM configuration file.")
		if(EXISTS ${APM_CONFIG_FILE})
			APM_message(DEBUG "Creating default configuration file in ${APM_CONFIG_FILE}... OK")
		else()
			APM_message(SEND_ERROR "Creating default configuration file in ${APM_CONFIG_FILE}... ERROR")
			APM_message(SEND_ERROR "User settings file ${APM_CONFIG_FILE} could not be created. User settings will not be available.")
		endif()
	endif()

	APM_defaultSet(APM_DEFAULT_PACKAGE_REPOSITORY_DIR ${APM_DATA_DIRECTORY}/packages)
	APM_message(DEBUG "Default package repository location : ${APM_DEFAULT_PACKAGE_REPOSITORY_DIR}")
	APM_add_package_repository(APM_DEFAULT_PACKAGE_REPOSITORY FOLDER "${APM_DEFAULT_PACKAGE_REPOSITORY_DIR}")


	if(MSVC)
		if(CMAKE_CL_64)
			set(APM_COMPILER_ID "${CMAKE_CXX_COMPILER_ID}-64bits-${CMAKE_CXX_COMPILER_VERSION}")
		else(CMAKE_CL_64)
			set(APM_COMPILER_ID "${CMAKE_CXX_COMPILER_ID}-32bits-${CMAKE_CXX_COMPILER_VERSION}")
		endif(CMAKE_CL_64)
	else(MSVC)
		set(APM_COMPILER_ID "${CMAKE_CXX_COMPILER_ID}-${CMAKE_CXX_COMPILER_VERSION}")
	endif(MSVC)
	APM_message(DEBUG "Compiler id : ${APM_COMPILER_ID}")
endif(APM_INCLUDE_GUARD)
