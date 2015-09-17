
	#! \brief Brief description.
	#!         Brief description continued.
	#!
	#!  Detailed description starts here.
	#!
	function(testfunc)
	endfunction()


include(CMakeParseArguments)
include(ExternalProject)

if(APM_INCLUDE_GUARD)
	APM_message(DEBUG "APM already included.")
else(APM_INCLUDE_GUARD)
	set(APM_INCLUDE_GUARD ON)

	include(${CMAKE_CURRENT_LIST_DIR}/APM_repository.cmake)
	include(${CMAKE_CURRENT_LIST_DIR}/APM_utils.cmake)
	include(${CMAKE_CURRENT_LIST_DIR}/APM_system_utils.cmake)
	include(${CMAKE_CURRENT_LIST_DIR}/APM_compiler_utils.cmake)
	include(${CMAKE_CURRENT_LIST_DIR}/APM_module_utils.cmake)

	##########################################################################################################
	#                                             User functions                                             #
	##########################################################################################################

	#! \brief Add a module repository.
	#!
	#!  This function add a module repository of type ${a_APM_type} and at location ${a_APM_address}. The variable pointing to the repository is stored in ${a_APM_name} and appended to the global module repository list ${APM_module_repositories}.
	#!
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
		set(${a_APM_name} ${${a_APM_name}} PARENT_SCOPE)

		#append repository to the list of repositories in current scope
		list(APPEND APM_module_repositories ${a_APM_name})
		#apply modifications in parent scope
		set(APM_module_repositories ${APM_module_repositories} PARENT_SCOPE)
	endfunction()

	#! \brief Add a package repository.
	#!
	#!  This function add a package repository of type ${a_APM_type} and at location ${a_APM_address}. The variable pointing to the repository is stored in ${a_APM_name} and appended to the global package repository list ${APM_package_repositories}.
	#!
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
		set(${a_APM_name} ${${a_APM_name}} PARENT_SCOPE)

		#append repository to the list of repositories in current scope
		list(APPEND APM_package_repositories ${a_APM_name})
		#apply modifications in parent scope
		set(APM_package_repositories ${APM_package_repositories} PARENT_SCOPE)
	endfunction()


	#! \brief Macro requiring a package.
	#!
	#!  This macro require is a wrapper around the APM_require_package function, used to allow including files in the scope calling the macro.
	#!
	macro(require_package)
		APM_require_package(${ARGN} FILES_TO_INCLUDE l_APM_files_to_include)
		if(DEFINED l_APM_files_to_include)
			foreach(l_APM_file_to_include ${l_APM_files_to_include})
				include(${l_APM_file_to_include})
			endforeach(l_APM_file_to_include)
		endif()
	endmacro()

	function(APM_require_package a_APM_projectName)
		##################################################################
		#                       Managing arguments                       #
		##################################################################
		set(l_APM_OptionArguments REQUIRED QUIET EXACT )
		set(l_APM_OneValueArguments VERSION PACKAGE_REPOSITORY FILES_TO_INCLUDE)
		set(l_APM_MultipleValuesArguments TARGETS COMPONENTS)
		cmake_parse_arguments(l_APM_require_package "${l_APM_OptionArguments}" "${l_APM_OneValueArguments}" "${l_APM_MultipleValuesArguments}" ${ARGN})

		# update the APM_QUIET global argument for the current scope (it will be automatically restored after the "require_package" function call)
		if(DEFINED l_APM_require_package_QUIET)
			if(${l_APM_require_package_QUIET})
				set(APM_QUIET TRUE)
			endif()
		endif()

		##################################################################
		#                          Configuration                         #
		##################################################################

		#if a PACKAGE_REPOSITORY is given, only use this one. Otherwise, try to find a suitable installed version in repositories available in the ${APM_package_repositories} variable.
		if(DEFINED l_APM_require_package_PACKAGE_REPOSITORY)
			set(l_APM_package_repositories ${l_APM_require_package_PACKAGE_REPOSITORY})
		else()
			set(l_APM_package_repositories ${APM_package_repositories})
		endif()

		###################################################################
		#                     Function implementation                     #
		###################################################################
		#
		# 1 - search for module
		#
		APM_message(INFO "Requiring module APM_${a_APM_projectName}...")

		# Each l_APM_repo contains the name of a repository variable
		set(${a_APM_projectName}_FOUND FALSE PARENT_SCOPE)
		foreach(l_APM_repo ${APM_module_repositories})
			APM_require_module(${l_APM_repo} ${a_APM_projectName} l_APM_module_path)
			if(DEFINED l_APM_module_path)
				set(${a_APM_projectName}_FOUND TRUE PARENT_SCOPE)
				break()
			endif()
		endforeach(l_APM_repo)

		#if we did not find the module, either return or send an error depending on the "REQUIRED" flag
		if(NOT ${${a_APM_projectName}_FOUND})
			set(APM_${a_APM_projectName}_FOUND FALSE PARENT_SCOPE)
			if(${l_APM_require_package_REQUIRED})
				APM_message(ERROR "Requiring module APM_${a_APM_projectName}... NOT FOUND")
				APM_message(FATAL "Unable to find the required module APM_${a_APM_projectName}. Aborting.")
			else()
				APM_message(INFO "Requiring module APM_${a_APM_projectName}... NOT FOUND")
			endif()
			return()
		endif()

		APM_message(INFO "Requiring module APM_${a_APM_projectName}... FOUND")
		set(APM_${a_APM_projectName}_FOUND TRUE PARENT_SCOPE)

		#TODO : undef every function of the API before including the module
		include(${l_APM_module_path})

		#
		# 2 - check package compatibility
		#
		check_package_compatibility(l_APM_compatibility_result DETAILS l_APM_compatibility_result_details)
		if(NOT l_APM_compatibility_result)
			if(${l_APM_require_package_REQUIRED})
				APM_message(FATAL_ERROR "Module APM_${a_APM_projectName} is not compatible with the current configuration : \n ${l_APM_compatibility_result_details}")
			else()
				APM_message(INFO "Module APM_${a_APM_projectName} is not compatible with the current configuration : \n ${l_APM_compatibility_result_details}")
			endif()
		endif()

		#
		# 3 - if the user provided a path for the package via the APM_${a_APM_projectName}_DIR variable, just configure the package.
		#
		if(DEFINED APM_${a_APM_projectName}_DIR)
			APM_message(INFO "Using provided path as package root : ${APM_${a_APM_projectName}_DIR}")
			configure_package_version(${${APM_${a_APM_projectName}_DIR}} COMPONENTS ${l_APM_require_package_COMPONENTS} TARGETS ${l_APM_require_package_TARGETS} FILES_TO_INCLUDE ${l_APM_require_package_FILES_TO_INCLUDE})
			return()
		endif()

		#
		# 3.b - try to find a suitable installed version of the project in the defined repositories
		#
		foreach(l_APM_repo ${l_APM_package_repositories})
			APM_Repository_getLocation(${l_APM_repo} l_APM_repo_location)
			APM_message(INFO "Searching for installation of project ${a_APM_projectName} in repository ${l_APM_repo_location}...")

			#first, check if there is a ${a_APM_projectName} folder
			set(l_APM_need_install FALSE)
			if(NOT EXISTS ${l_APM_repo_location}/${a_APM_projectName})
				APM_message(INFO "Searching for installation of project ${a_APM_projectName} in repository ${l_APM_repo_location}... NOT FOUND")
				set(l_APM_need_install TRUE)
				continue()
			endif()

			# then check if a compatible version of the package is available
			if(${l_APM_require_package_EXACT})
				get_compatible_package_version_root("${l_APM_repo_location}/${a_APM_projectName}" ${l_APM_require_package_VERSION} EXACT l_APM_get_compatible_package_version_root_result)
			else()
				get_compatible_package_version_root("${l_APM_repo_location}/${a_APM_projectName}" ${l_APM_require_package_VERSION} l_APM_get_compatible_package_version_root_result)
			endif()

			if(DEFINED l_APM_get_compatible_package_version_root_result)
				# we found our version. Break the loop and save the repository.
				set(l_APM_package_repository ${l_APM_repo})
				APM_message(INFO "Searching for installation of project ${a_APM_projectName} in repository ${l_APM_repo_location}... FOUND")
				set(l_APM_package_version_root ${l_APM_get_compatible_package_version_root_result})
				break()
			else()
				#otherwise, go to the next iteration. Set l_APM_need_install to TRUE in case this is the last iteration.
				APM_message(INFO "Searching for installation of project ${a_APM_projectName} in repository ${l_APM_repo_location}... NOT FOUND")
				set(l_APM_need_install TRUE)
				continue()
			endif()
		endforeach(l_APM_repo)

		# if no valid repository was found, use the repository given as parameter or the default one
		if(NOT DEFINED l_APM_package_repository)
			# if a package repository was given, install the package in this repository. Otherwise use the default one.
			if(DEFINED l_APM_require_package_PACKAGE_REPOSITORY)
				set(l_APM_package_repository ${l_APM_require_package_PACKAGE_REPOSITORY})
			else()
				set(l_APM_package_repository APM_DEFAULT_PACKAGE_REPOSITORY)
			endif()
		endif()


		if(${l_APM_need_install})
			#
			# 3.3 - if no compatible installed version is found, ask user if we need to install the package
			#
			set(APM_install_${a_APM_projectName} OFF CACHE BOOL "Install package ${a_APM_projectName} ? To use an already installed version, set the APM_${a_APM_projectName}_DIR variable to the root folder.")
			if(${APM_install_${a_APM_projectName}})
				APM_Repository_getLocation(${l_APM_package_repository} l_APM_repo_location)
				download_package_version("${l_APM_repo_location}/${a_APM_projectName}" l_APM_package_version_root ${l_APM_require_package_VERSION})
				set(l_APM_need_install FALSE)
			endif()
			#TODO : terminer le processus ici. pas besoin de faire le reste si le projet est pas accessible...
		endif()
		#
		# 3.4 - check if the package needs to be compiled
		#
		if(NOT ${l_APM_need_install})
			APM_Repository_getLocation(${l_APM_package_repository} l_APM_repo_location)

			package_version_need_compilation(${l_APM_package_version_root} l_APM_need_compile COMPONENTS ${l_APM_require_package_COMPONENTS})

			#if we do not have a matching compiler version, ask for a recompilation
			if(${l_APM_need_compile})
				#APM_message(INFO "Searching for compatible compiled version in ${l_APM_repo_location}/${a_APM_projectName}... NOT FOUND")

				set(l_APM_compile_package_args ${l_APM_package_version_root} l_APM_compile_package_result )
				list(APPEND l_APM_compile_package_args ${l_APM_require_package_REQUIRED} ${l_APM_require_package_QUIET})
				if(DEFINED l_APM_require_package_VERSION)
					list(APPEND l_APM_compile_package_args VERSION ${l_APM_require_package_VERSION})
				endif()
				if(DEFINED l_APM_require_package_COMPONENTS)
					list(APPEND l_APM_compile_package_args COMPONENTS ${l_APM_require_package_COMPONENTS})
				endif()

				compile_package_version(${l_APM_compile_package_args})
			endif()
		endif()


		#
		# 3.5 - if no compatible installed version is found and user did not ask to install package, send error if package is required, or display a status message otherwise.
		#
		if(${l_APM_need_install} AND NOT ${APM_install_${a_APM_projectName}})
			set(l_APM_msg  "No compatible installed version of ${a_APM_projectName} found. Set APM_install_${a_APM_projectName} to TRUE if you want top install the package, or set APM_${a_APM_projectName}_DIR to the path of a compatible installed version.")
			if(${l_APM_require_package_REQUIRED})
				APM_message(ERROR ${l_APM_msg})
			else()
				APM_message(INFO ${l_APM_msg})
			endif()
		endif()

		configure_package_version(${l_APM_package_version_root} COMPONENTS ${l_APM_require_package_COMPONENTS} TARGETS ${l_APM_require_package_TARGETS} FILES_TO_INCLUDE ${l_APM_require_package_FILES_TO_INCLUDE})
		set(${l_APM_require_package_FILES_TO_INCLUDE} "${${l_APM_require_package_FILES_TO_INCLUDE}}" PARENT_SCOPE)
	endfunction()


	############################
	##     Initialization     ##
	############################

	# if true, all messages will be printed
	APM_defaultSet(APM_LOG_LEVEL_ALL FALSE)
	# if true, debug messages will be printed to screen.
	APM_defaultSet(APM_LOG_LEVEL_DEBUG FALSE)
	# if true, error messages will be printed
	APM_defaultSet(APM_LOG_LEVEL_ERROR FALSE)
	# if true, inforation messages will be printed
	APM_defaultSet(APM_LOG_LEVEL_INFO FALSE)
	# if true, no messages will be printed
	APM_defaultSet(APM_LOG_LEVEL_OFF FALSE)
	# if true, trace messages will be printed
	APM_defaultSet(APM_LOG_LEVEL_TRACE FALSE)
	# if true, warning messages will be printed
	APM_defaultSet(APM_LOG_LEVEL_WARN FALSE)


	# APM configuration folder
	if(WIN32 OR CYGWIN)
		set(APM_DATA_DIRECTORY $ENV{USERPROFILE}/.apm)
	else()
		set(APM_DATA_DIRECTORY $ENV{HOME}/.apm)
	endif()

	if(EXISTS ${APM_DATA_DIRECTORY})
		APM_message(DEBUG "${APM_DATA_DIRECTORY} already exists.")
		set(l_APM_DATA_DIRECTORY_EXISTS TRUE)
	else()
		APM_message(DEBUG "${APM_DATA_DIRECTORY} does not exist.")
		APM_message(DEBUG "Creating directory ${APM_DATA_DIRECTORY}...")
		file(MAKE_DIRECTORY ${APM_DATA_DIRECTORY})
		if(EXISTS ${APM_DATA_DIRECTORY})
			APM_message(DEBUG "Creating directory ${APM_DATA_DIRECTORY}... OK")
			set(l_APM_DATA_DIRECTORY_EXISTS TRUE)
		else()
			APM_message(SEND_ERROR "Creating directory ${APM_DATA_DIRECTORY}... ERROR")
			APM_message(SEND_ERROR "Directory ${APM_DATA_DIRECTORY} could not be created. User settings will not be available.")
			set(l_APM_DATA_DIRECTORY_EXISTS FALSE)
		endif()
	endif()

	# APM configuration file
	set(APM_CONFIG_FILE ${APM_DATA_DIRECTORY}/settings.cmake)
	if(NOT EXISTS ${APM_CONFIG_FILE} AND ${l_APM_DATA_DIRECTORY_EXISTS})
		APM_message(DEBUG "Creating default configuration file in ${APM_CONFIG_FILE}...")
		file(WRITE ${APM_CONFIG_FILE} "#APM configuration file.")
		if(EXISTS ${APM_CONFIG_FILE})
			APM_message(DEBUG "Creating default configuration file in ${APM_CONFIG_FILE}... OK")
		else()
			APM_message(SEND_ERROR "Creating default configuration file in ${APM_CONFIG_FILE}... ERROR")
			APM_message(SEND_ERROR "User settings file ${APM_CONFIG_FILE} could not be created. User settings will not be available.")
		endif()
	endif()

	if(EXISTS ${APM_CONFIG_FILE})
		include(${APM_CONFIG_FILE})
	endif()

	# APM default package repository
	APM_defaultSet(APM_DEFAULT_PACKAGE_REPOSITORY_DIR ${APM_DATA_DIRECTORY}/packages)
	APM_message(DEBUG "Default package repository location : ${APM_DEFAULT_PACKAGE_REPOSITORY_DIR}")
	APM_add_package_repository(APM_DEFAULT_PACKAGE_REPOSITORY FOLDER "${APM_DEFAULT_PACKAGE_REPOSITORY_DIR}")

	# APM compiler id.
	if(MSVC)
		if(CMAKE_CL_64)
			set(APM_COMPILER_ID "${CMAKE_CXX_COMPILER_ID}-64bits-${CMAKE_CXX_COMPILER_VERSION}")
		else()
			set(APM_COMPILER_ID "${CMAKE_CXX_COMPILER_ID}-32bits-${CMAKE_CXX_COMPILER_VERSION}")
		endif()
	else()
		set(APM_COMPILER_ID "${CMAKE_CXX_COMPILER_ID}-${CMAKE_CXX_COMPILER_VERSION}")
	endif()
	APM_message(DEBUG "Compiler id : ${APM_COMPILER_ID}")
endif(APM_INCLUDE_GUARD)
