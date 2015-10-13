include(CMakeParseArguments)

if(INQUIRE_INCLUDE_GUARD)
	inquire_message(DEBUG "Inquire already included.")
else(INQUIRE_INCLUDE_GUARD)
	set(INQUIRE_INCLUDE_GUARD ON)

	include(${CMAKE_CURRENT_LIST_DIR}/Inquire_repository.cmake)
	include(${CMAKE_CURRENT_LIST_DIR}/Inquire_utils.cmake)
	include(${CMAKE_CURRENT_LIST_DIR}/Inquire_system_utils.cmake)
	include(${CMAKE_CURRENT_LIST_DIR}/Inquire_compiler_utils.cmake)
	include(${CMAKE_CURRENT_LIST_DIR}/Inquire_module_utils.cmake)

	##########################################################################################################
	#                                             User functions                                             #
	##########################################################################################################

	#! \brief Add a module repository with name ${a_IPM_name}.
	#!
	#!  This function add a module repository of type ${a_IPM_type} and at location ${a_IPM_address}. The variable pointing to the repository is stored in ${a_IPM_name} and appended to the global module repository list ${IPM_module_repositories}.
	#!
	function(inquire_add_module_repository a_IPM_name a_IPM_type a_IPM_address)
		inquire_message(DEBUG "Creating module repository ${a_IPM_name} of type ${a_IPM_type} and address ${a_IPM_address}.")

		#create the IPM_module_repositories global variable if needed
		if(NOT DEFINED IPM_module_repositories)
			set(IPM_module_repositories PARENT_SCOPE)
		endif()

		#check if the repository already exists
		if(DEFINED ${a_IPM_name})
			inquire_message(WARNING "Repository ${${a_IPM_name}} already exists. It will be overriden.")
		endif()

		#handle backslashes
		string(REPLACE "\\" "/" a_IPM_address ${a_IPM_address})

		#create repository
		IPM_create_repository(${a_IPM_type} ${a_IPM_address} ${a_IPM_name})
		#declare repository in parent scope
		set(${a_IPM_name} ${${a_IPM_name}} PARENT_SCOPE)

		#append repository to the list of repositories in current scope
		list(APPEND IPM_module_repositories ${a_IPM_name})
		#apply modifications in parent scope
		set(IPM_module_repositories ${IPM_module_repositories} PARENT_SCOPE)
	endfunction()

	#! \brief Add a package repository.
	#!
	#!  This function adds a package repository of type ${a_IPM_type} and at location ${a_IPM_address}. The variable pointing to the repository is stored in ${a_IPM_name} and appended to the global package repository list ${IPM_package_repositories}.
	#!
	function(inquire_add_package_repository a_IPM_name a_IPM_type a_IPM_address)
		inquire_message(DEBUG "Creating package repository ${a_IPM_name} of type ${a_IPM_type} and address ${a_IPM_address}.")
		#create the IPM_package_repositories global variable if needed
		if(NOT DEFINED IPM_package_repositories)
			set(IPM_package_repositories PARENT_SCOPE)
		endif()

		#check if the repository already exists
		if(DEFINED ${a_IPM_name})
			inquire_message(WARNING "Repository ${${a_IPM_name}} already exists. It will be overriden.")
		endif()

		#handle backslashes
		string(REPLACE "\\" "/" a_IPM_address ${a_IPM_address})

		#create repository
		IPM_create_repository(${a_IPM_type} ${a_IPM_address} ${a_IPM_name})
		#declare repository in parent scope
		set(${a_IPM_name} ${${a_IPM_name}} PARENT_SCOPE)

		#append repository to the list of repositories in current scope
		list(APPEND IPM_package_repositories ${a_IPM_name})
		#apply modifications in parent scope
		set(IPM_package_repositories ${IPM_package_repositories} PARENT_SCOPE)
	endfunction()


	#! \brief Macro requiring a package.
	#!
	#!  This macro require is a wrapper around the IPM_require_package function, used to allow including files in the scope calling the macro.
	#!
	macro(require_package)
		IPM_require_package(${ARGN} FILES_TO_INCLUDE l_IPM_files_to_include)
		if(DEFINED l_IPM_files_to_include)
			foreach(l_IPM_file_to_include ${l_IPM_files_to_include})
				include(${l_IPM_file_to_include})
			endforeach(l_IPM_file_to_include)
		endif()
	endmacro()

	function(IPM_require_package a_IPM_projectName)
		##################################################################
		#                       Managing arguments                       #
		##################################################################
		set(l_IPM_OptionArguments REQUIRED QUIET EXACT )
		set(l_IPM_OneValueArguments VERSION PACKAGE_REPOSITORY FILES_TO_INCLUDE)
		set(l_IPM_MultipleValuesArguments TARGETS COMPONENTS)
		cmake_parse_arguments(l_IPM_require_package "${l_IPM_OptionArguments}" "${l_IPM_OneValueArguments}" "${l_IPM_MultipleValuesArguments}" ${ARGN})

		# update the IPM_QUIET global argument for the current scope (it will be automatically restored after the "require_package" function call)
		if(DEFINED l_IPM_require_package_QUIET)
			if(${l_IPM_require_package_QUIET})
				set(IPM_QUIET TRUE)
			endif()
		endif()

		set(${a_IPM_projectName}_VERSION ${l_IPM_require_package_VERSION})
		set(${a_IPM_projectName}_TARGETS ${l_IPM_require_package_TARGETS})
		set(${a_IPM_projectName}_COMPONENTS ${l_IPM_require_package_COMPONENTS})
		set(${a_IPM_projectName}_EXACT ${l_IPM_require_package_EXACT})

		##################################################################
		#                          Configuration                         #
		##################################################################

		#if a PACKAGE_REPOSITORY is given, only use this one. Otherwise, try to find a suitable installed version in repositories available in the ${IPM_package_repositories} variable.
		if(DEFINED l_IPM_require_package_PACKAGE_REPOSITORY)
			set(l_IPM_package_repositories ${l_IPM_require_package_PACKAGE_REPOSITORY})
		else()
			set(l_IPM_package_repositories ${IPM_package_repositories})
		endif()

		###################################################################
		#                     Function implementation                     #
		###################################################################
		#
		# 1 - search for module
		#
		inquire_message(INFO "Requiring module ${a_IPM_projectName}...")

		# Each l_IPM_repo contains the name of a repository variable
		set(${a_IPM_projectName}_FOUND FALSE)
		foreach(l_IPM_repo ${IPM_module_repositories})
			unset(l_IPM_module_path)
			IPM_require_module(${l_IPM_repo} ${a_IPM_projectName} l_IPM_module_path)
			if(DEFINED l_IPM_module_path)
				if(NOT "${l_IPM_module_path}" STREQUAL "")
					set(${a_IPM_projectName}_FOUND TRUE)
					break()
				endif()
			endif()
		endforeach(l_IPM_repo)

		#if we did not find the module, either return or send an error depending on the "REQUIRED" flag
		if(NOT ${${a_IPM_projectName}_FOUND})
			set(IPM_${a_IPM_projectName}_FOUND FALSE PARENT_SCOPE)
			if(${l_IPM_require_package_REQUIRED})
				inquire_message(ERROR "Requiring module ${a_IPM_projectName}... NOT FOUND")
				inquire_message(FATAL "Unable to find the required module ${a_IPM_projectName}. Aborting.")
			else()
				inquire_message(INFO "Requiring module ${a_IPM_projectName}... NOT FOUND")
			endif()

			return()
		endif()

		inquire_message(INFO "Requiring module ${a_IPM_projectName}... FOUND")
		set(${a_IPM_projectName}_FOUND TRUE PARENT_SCOPE)


		#
		# 2 - check package compatibility
		#
		# TODO : Check that required scripts are given
		#
		# Set default values :
		#

		set(${a_IPM_projectName}_COMPATIBLE TRUE)
		set(${a_IPM_projectName}_COMPATIBILITY_DETAILS "")
		if(EXISTS ${l_IPM_module_path}/compatibility.cmake)
			inquire_message(DEBUG "Including ${l_IPM_module_path}/compatibility.cmake")

			#NOTE : The use of a function here is to ensure that we declare a new scope.
			function(IPM_check_module_compatibility)
				include(${l_IPM_module_path}/compatibility.cmake)
				set(${a_IPM_projectName}_COMPATIBLE ${${a_IPM_projectName}_COMPATIBLE} PARENT_SCOPE)
				set(${a_IPM_projectName}_COMPATIBILITY_DETAILS ${${a_IPM_projectName}_COMPATIBILITY_DETAILS} PARENT_SCOPE)
			endfunction()

			IPM_check_module_compatibility(${l_IPM_module_path})

		else()
			inquire_message(DEBUG "${l_IPM_module_path}/compatibility.cmake does not exist.")
		endif()

		if(NOT ${${a_IPM_projectName}_COMPATIBLE})
			if(${l_IPM_require_package_REQUIRED})
				inquire_message(FATAL "Module ${a_IPM_projectName} is not compatible with the current configuration : \n ${${a_IPM_projectName}_COMPATIBILITY_DETAILS}\n")
			else()
				inquire_message(INFO "Module ${a_IPM_projectName} is not compatible with the current configuration : \n ${${a_IPM_projectName}_COMPATIBILITY_DETAILS}\n")
			endif()
		endif()

		#
		# 3 - if the user provided a path for the package via the ${a_IPM_projectName}_INSTALLATION_DIR variable, just configure the package.
		#
		if(DEFINED ${a_IPM_projectName}_INSTALLATION_DIR)
			inquire_message(INFO "Using provided path as package root : ${${a_IPM_projectName}_INSTALLATION_DIR}")
			set(${a_IPM_projectName}_FILES_TO_INCLUDE )
			#NOTE : The use of a function here is to ensure that we declare a new scope.
			function(IPM_configure_targets)
				set(IPM_PACKAGE_VERSION_ROOT ${${a_IPM_projectName}_INSTALLATION_DIR})
				set(IPM_COMPONENTS ${l_IPM_require_package_COMPONENTS})
				set(IPM_TARGETS ${l_IPM_require_package_TARGETS})
				include(${l_IPM_module_path}/configure.cmake)
				set(${a_IPM_projectName}_FILES_TO_INCLUDE ${${a_IPM_projectName}_FILES_TO_INCLUDE} PARENT_SCOPE)
			endfunction()
			IPM_configure_targets()
			return()
		endif()

		#
		# 3.b - try to find a suitable installed version of the project in the defined repositories
		#
		foreach(l_IPM_repo ${l_IPM_package_repositories})
			IPM_Repository_getLocation(${l_IPM_repo} l_IPM_repo_location)
			inquire_message(INFO "Searching for installation of project ${a_IPM_projectName} in repository ${l_IPM_repo_location}...")

			#first, check if there is a ${a_IPM_projectName} folder
			if(NOT EXISTS ${l_IPM_repo_location}/${a_IPM_projectName})
				inquire_message(INFO "Searching for installation of project ${a_IPM_projectName} in repository ${l_IPM_repo_location}... NOT FOUND")
				set(l_IPM_need_install TRUE)
				continue()
			endif()

			# then check if a compatible version of the package is available
			set(IPM_PACKAGE_ROOT "${l_IPM_repo_location}/${a_IPM_projectName}")
			set(${a_IPM_projectName}_COMPATIBLE_VERSION_FOUND FALSE)
			set(${a_IPM_projectName}_VERSION_ROOT )

			#NOTE : The use of a function here is to ensure that we declare a new scope.
			function(IPM_search_compatible_version)
				set(${a_IPM_projectName}_PACKAGE_ROOT "${l_IPM_repo_location}/${a_IPM_projectName}")
				include(${l_IPM_module_path}/search_compatible_version.cmake)
				set(${a_IPM_projectName}_COMPATIBLE_VERSION_FOUND ${${a_IPM_projectName}_COMPATIBLE_VERSION_FOUND} PARENT_SCOPE)
				set(${a_IPM_projectName}_VERSION_ROOT ${${a_IPM_projectName}_VERSION_ROOT} PARENT_SCOPE)
			endfunction()
			IPM_search_compatible_version()

			if(${${a_IPM_projectName}_COMPATIBLE_VERSION_FOUND})
				# we found our version. Break the loop and save the repository.
				set(l_IPM_package_repository ${l_IPM_repo})
				inquire_message(INFO "Searching for installation of project ${a_IPM_projectName} in repository ${l_IPM_repo_location}... FOUND")
				set(l_IPM_package_version_root ${${a_IPM_projectName}_VERSION_ROOT})
				break()
			else()
				#otherwise, go to the next iteration. Set l_IPM_need_install to TRUE in case this is the last iteration.
				inquire_message(INFO "Searching for installation of project ${a_IPM_projectName} in repository ${l_IPM_repo_location}... NOT FOUND")
				set(l_IPM_need_install TRUE)
				continue()
			endif()
		endforeach(l_IPM_repo)

		# if no valid repository was found, use the repository given as parameter or the default one
		if(NOT DEFINED l_IPM_package_repository)
			# if a package repository was given, install the package in this repository. Otherwise use the default one.
			if(DEFINED l_IPM_require_package_PACKAGE_REPOSITORY)
				set(l_IPM_package_repository ${l_IPM_require_package_PACKAGE_REPOSITORY})
			else()
				set(l_IPM_package_repository IPM_DEFAULT_PACKAGE_REPOSITORY)
			endif()
		endif()

		IPM_Repository_getLocation(${l_IPM_package_repository} l_IPM_repo_location)
		set(${a_IPM_projectName}_REPOSITORY_DIR "${l_IPM_repo_location}/${a_IPM_projectName}")


		set(${a_IPM_projectName}_PACKAGE_VERSION_ROOT )
		if(${l_IPM_need_install})
			#
			# 3.3 - if no compatible installed version is found, ask user if we need to install the package
			#
			set(INSTALL_${a_IPM_projectName} OFF CACHE BOOL "Install package ${a_IPM_projectName} ? To use an already installed version, set the ${a_IPM_projectName}_INSTALLATION_DIR variable to the root folder.")
			if(${INSTALL_${a_IPM_projectName}})
				set(${a_IPM_projectName}_INSTALLATION_DIR )
				#NOTE : The use of a function here is to ensure that we declare a new scope.
				function(IPM_download)
					set(${a_IPM_projectName}_VERSION ${l_IPM_require_package_VERSION})
					set(${a_IPM_projectName}_PACKAGE_ROOT ${${a_IPM_projectName}_REPOSITORY_DIR})
					include(${l_IPM_module_path}/download.cmake)
					set(l_IPM_package_version_root ${${a_IPM_projectName}_PACKAGE_VERSION_ROOT} PARENT_SCOPE)
				endfunction()
				IPM_download()
				set(l_IPM_need_install FALSE)
			endif()
			#TODO : terminer le processus ici. pas besoin de faire le reste si le projet n'est pas accessible...
		endif()
		#
		# 3.4 - check if the package needs to be compiled
		#
		if(NOT ${l_IPM_need_install})
			#NOTE : The use of a function here is to ensure that we declare a new scope.
			function(IPM_compile)
				set(${a_IPM_projectName}_PACKAGE_VERSION_ROOT ${l_IPM_package_version_root})
				set(${a_IPM_projectName}_COMPONENTS ${l_IPM_require_package_COMPONENTS})
				if(EXISTS ${l_IPM_module_path}/compile.cmake)
					include(${l_IPM_module_path}/compile.cmake)
				endif()
			endfunction()
			IPM_compile()
		endif()


		#
		# 3.5 - if no compatible installed version is found and user did not ask to install package, send error if package is required, or display a status message otherwise.
		#
		if(${l_IPM_need_install})
			if(NOT ${INSTALL_${a_IPM_projectName}})
				set(l_IPM_msg  "No compatible installed version of ${a_IPM_projectName} found. Set INSTALL_${a_IPM_projectName} to TRUE if you want top install the package, or set ${a_IPM_projectName}_INSTALLATION_DIR to the path of a compatible installed version.")
				if(${l_IPM_require_package_REQUIRED})
					inquire_message(ERROR ${l_IPM_msg})
				else()
					inquire_message(INFO ${l_IPM_msg})
				endif()
			endif()
		endif()

		#NOTE : The use of a function here is to ensure that we declare a new scope.
		function(IPM_configure)
			set(${a_IPM_projectName}_PACKAGE_VERSION_ROOT ${l_IPM_package_version_root})
			set(${a_IPM_projectName}_COMPONENTS ${l_IPM_require_package_COMPONENTS})
			set(${a_IPM_projectName}_TARGETS ${l_IPM_require_package_TARGETS})
			include(${l_IPM_module_path}/configure.cmake)
			set(${a_IPM_projectName}_FILES_TO_INCLUDE "${${a_IPM_projectName}_FILES_TO_INCLUDE}" PARENT_SCOPE)
		endfunction()
		IPM_configure()
		set(${l_IPM_require_package_FILES_TO_INCLUDE} "${${a_IPM_projectName}_FILES_TO_INCLUDE}" PARENT_SCOPE)
	endfunction()


	############################
	##     Initialization     ##
	############################

	# if true, all messages will be printed
	IPM_defaultSet(IPM_LOG_LEVEL_ALL FALSE)
	# if true, debug messages will be printed to screen.
	IPM_defaultSet(IPM_LOG_LEVEL_DEBUG FALSE)
	# if true, error messages will be printed
	IPM_defaultSet(IPM_LOG_LEVEL_ERROR TRUE)
	# if true, inforation messages will be printed
	IPM_defaultSet(IPM_LOG_LEVEL_INFO TRUE)
	# if true, no messages will be printed
	IPM_defaultSet(IPM_LOG_LEVEL_OFF FALSE)
	# if true, trace messages will be printed
	IPM_defaultSet(IPM_LOG_LEVEL_TRACE TRUE)
	# if true, warning messages will be printed
	IPM_defaultSet(IPM_LOG_LEVEL_WARN TRUE)


	# IPM configuration folder
	if(WIN32 OR CYGWIN)
		set(IPM_DATA_DIRECTORY $ENV{USERPROFILE}/.inquire)
	else()
		set(IPM_DATA_DIRECTORY $ENV{HOME}/.inquire)
	endif()

	if(EXISTS ${IPM_DATA_DIRECTORY})
		inquire_message(DEBUG "${IPM_DATA_DIRECTORY} already exists.")
		set(l_IPM_DATA_DIRECTORY_EXISTS TRUE)
	else()
		inquire_message(DEBUG "${IPM_DATA_DIRECTORY} does not exist.")
		inquire_message(DEBUG "Creating directory ${IPM_DATA_DIRECTORY}...")
		file(MAKE_DIRECTORY ${IPM_DATA_DIRECTORY})
		if(EXISTS ${IPM_DATA_DIRECTORY})
			inquire_message(DEBUG "Creating directory ${IPM_DATA_DIRECTORY}... OK")
			set(l_IPM_DATA_DIRECTORY_EXISTS TRUE)
		else()
			inquire_message(SEND_ERROR "Creating directory ${IPM_DATA_DIRECTORY}... ERROR")
			inquire_message(SEND_ERROR "Directory ${IPM_DATA_DIRECTORY} could not be created. User settings will not be available.")
			set(l_IPM_DATA_DIRECTORY_EXISTS FALSE)
		endif()
	endif()

	# IPM configuration file
	set(IPM_CONFIG_FILE ${IPM_DATA_DIRECTORY}/settings.cmake)
	if(NOT EXISTS ${IPM_CONFIG_FILE} AND ${l_IPM_DATA_DIRECTORY_EXISTS})
		inquire_message(DEBUG "Creating default configuration file in ${IPM_CONFIG_FILE}...")
		file(WRITE ${IPM_CONFIG_FILE} "#IPM configuration file.")
		if(EXISTS ${IPM_CONFIG_FILE})
			inquire_message(DEBUG "Creating default configuration file in ${IPM_CONFIG_FILE}... OK")
		else()
			inquire_message(SEND_ERROR "Creating default configuration file in ${IPM_CONFIG_FILE}... ERROR")
			inquire_message(SEND_ERROR "User settings file ${IPM_CONFIG_FILE} could not be created. User settings will not be available.")
		endif()
	endif()

	if(EXISTS ${IPM_CONFIG_FILE})
		include(${IPM_CONFIG_FILE})
	endif()

	# IPM default package repository
	IPM_defaultSet(IPM_DEFAULT_PACKAGE_REPOSITORY_DIR ${IPM_DATA_DIRECTORY}/packages)
	inquire_message(DEBUG "Default package repository location : ${IPM_DEFAULT_PACKAGE_REPOSITORY_DIR}")
	inquire_add_package_repository(IPM_DEFAULT_PACKAGE_REPOSITORY FOLDER "${IPM_DEFAULT_PACKAGE_REPOSITORY_DIR}")

	# IPM compiler id.
	if(MSVC)
		if(CMAKE_CL_64)
			set(IPM_COMPILER_ID "${CMAKE_CXX_COMPILER_ID}-64bits-${CMAKE_CXX_COMPILER_VERSION}")
		else()
			set(IPM_COMPILER_ID "${CMAKE_CXX_COMPILER_ID}-32bits-${CMAKE_CXX_COMPILER_VERSION}")
		endif()
	else()
		set(IPM_COMPILER_ID "${CMAKE_CXX_COMPILER_ID}-${CMAKE_CXX_COMPILER_VERSION}")
	endif()
	inquire_message(DEBUG "Compiler id : ${IPM_COMPILER_ID}")
endif(INQUIRE_INCLUDE_GUARD)
