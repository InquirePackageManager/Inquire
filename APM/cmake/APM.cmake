include(CMakeParseArguments)
include(ExternalProject)

include(cmake/APM_ArgumentsUtils.cmake)

set(APM_DEFAULT_REPOSITORY_DIR "C:/Developpements/APM/repo")
if(MSVC)
	if(CMAKE_CL_64)
		set(APM_COMPILER_ID "${CMAKE_CXX_COMPILER_ID}-64bits-${CMAKE_CXX_COMPILER_VERSION}")
	else(CMAKE_CL_64)
		set(APM_COMPILER_ID "${CMAKE_CXX_COMPILER_ID}-32bits-${CMAKE_CXX_COMPILER_VERSION}")
	endif(CMAKE_CL_64)
else(MSVC)
	set(APM_COMPILER_ID "${CMAKE_CXX_COMPILER_ID}-${CMAKE_CXX_COMPILER_VERSION}")
endif(MSVC)

#################################################
#				APM utilities					#
#################################################
macro(APM_message)
	if(NOT APM_QUIET)
		message(${ARGV})
	endif(NOT APM_QUIET)
endmacro()
macro(APM_parentScope a_APM_Variable)
	set(${a_APM_Variable} ${${a_APM_Variable}} PARENT_SCOPE)
endmacro()

function(APM_ExternalProject_Add a_APM_name a_APM_version)
	# Managing arguments
	set(l_APM_OptionArguments OPTIONAL REQUIRED QUIET EXACT)
	set(l_APM_OneValueArguments VERSION)
	set(l_APM_MultipleValuesArguments TARGETS)
	cmake_parse_arguments(l_APM_install "${l_APM_OptionArguments}" "${l_APM_OneValueArguments}" "${l_APM_MultipleValuesArguments}" ${ARGN})

	set(l_APM_RootProjectDir "${APM_REPOSITORY_DIR}/${a_APM_name}/${a_APM_version}")
	
	string(REPLACE "." "_" l_APM_underscore_version ${a_APM_version})
	set(l_APM_BaseVariableName "APM_${a_APM_name}_${l_APM_underscore_version}")
	
	set("${l_APM_BaseVariableName}_DOWNLOAD_DIR" "${l_APM_RootProjectDir}/download")
	set("${l_APM_BaseVariableName}_SOURCE_DIR" "${l_APM_RootProjectDir}/source" )
	set("${l_APM_BaseVariableName}_INSTALL_DIR" "${l_APM_RootProjectDir}/install/${APM_COMPILER_ID}")
	
	ExternalProject_Add(
		${a_APM_name}
		DOWNLOAD_DIR ${${l_APM_BaseVariableName}_DOWNLOAD_DIR}
		SOURCE_DIR ${${l_APM_BaseVariableName}_SOURCE_DIR}
		STAMP_DIR ${l_APM_RootProjectDir}/stamps
		TMP_DIR ${l_APM_RootProjectDir}/tmp
		BINARY_DIR ${l_APM_RootProjectDir}/build/${APM_COMPILER_ID}
		CMAKE_ARGS
			${CMAKE_PROPAGATED_VARIABLES}
			-DCMAKE_INSTALL_PREFIX:PATH=${${l_APM_BaseVariableName}_INSTALL_DIR}
			-DBUILD_TESTING=1
		${ARGV}
	)
	
	#set useful variables in parent scope
	set("${l_APM_BaseVariableName}_DOWNLOAD_DIR" "${${l_APM_BaseVariableName}_DOWNLOAD_DIR}" PARENT_SCOPE)
	set("${l_APM_BaseVariableName}_SOURCE_DIR" "${${l_APM_BaseVariableName}_SOURCE_DIR}" PARENT_SCOPE)
	set("${l_APM_BaseVariableName}_INSTALL_DIR" "${${l_APM_BaseVariableName}_INSTALL_DIR}" PARENT_SCOPE)
endfunction()


#################################################
#				Class Repository				#
#################################################
#
# Purpose : Create an instance of class Repository
# 
# Input : a_APM_repoType: 
#         ----------- 
#         a_APM_repoType          Variable containing the repository type;
#         ${a_APM_repoType}       Repository type.
#         ------------------------------------------------------------------------------
#         a_APM_repoLocation: 
#         ----------- 
#         a_APM_repoLocation      Variable containing the repository location;
#         ${a_APM_repoLocation}   Repository location.
#         ------------------------------------------------------------------------------
#         a_APM_res:
#         ----------
#         a_APM_res               Result variable name. 
#		  ${a_APM_res}            Variable containing the result;
#		  ${${a_APM_res}}         Result.
#         ------------------------------------------------------------------------------
function(APM_Repository_create a_APM_repoType a_APM_repoLocation a_APM_res)
	list(APPEND ${a_APM_res} ${a_APM_repoType} "${a_APM_repoLocation}")
	APM_parentScope(${a_APM_res})
endfunction()
#
# Purpose : Given a repository, return its type (FOLDER, GIT, etc.)
# 
# Input : a_APM_repo: 
#         ----------- 
#         a_APM_repo      Variable containing the name of the repository variable;
#         ${a_APM_repo}   Repository variable.
#         ------------------------------------------------------------------------------
#         a_APM_res:
#         ----------
#         a_APM_res       Result variable name. 
#		  ${a_APM_res}    Variable containing the result;
#		  ${${a_APM_res}} Result.
#         ------------------------------------------------------------------------------
function(APM_Repository_getType a_APM_repo a_APM_res)
	list(GET ${a_APM_repo} 0 ${a_APM_res})
	APM_parentScope(${a_APM_res})
endfunction()
#
# Purpose : Given a repository, return its location
# 
# Input : a_APM_repo: 
#         ----------- 
#         a_APM_repo      Variable containing the name of the repository variable;
#         ${a_APM_repo}   Repository variable.
#         ------------------------------------------------------------------------------
#         a_APM_res:
#         ----------
#         a_APM_res       Result variable name. 
#		  ${a_APM_res}    Variable containing the result;
#		  ${${a_APM_res}} Result.
#         ------------------------------------------------------------------------------
function(APM_Repository_getLocation a_APM_repo a_APM_res)
	list(GET ${a_APM_repo} 1 ${a_APM_res})
	APM_parentScope(${a_APM_res})
endfunction()
#
# Purpose : Search the project a_APM_projectName in the Repository a_APM_repo
# 
# Input : a_APM_repo: 
#         ----------- 
#         a_APM_repo              Variable containing the repository variable name;
#         ${a_APM_repo}           Repository variable.
#         ${${a_APM_repo}}        Repository content.
#         ------------------------------------------------------------------------------
#         a_APM_projectName: 
#         ----------- 
#         a_APM_projectName       Variable containing the project name;
#         ${a_APM_projectName}    Project name.
#         ------------------------------------------------------------------------------
function(APM_Repository_require a_APM_repo a_APM_projectName)
	APM_Repository_getType(${a_APM_repo} l_APM_repositoryType)
	APM_Repository_getLocation(${a_APM_repo} l_APM_repositoryLocation)
	
	if(${l_APM_repositoryType} MATCHES "FOLDER")
		APM_message(STATUS "Search APM module for ${a_APM_projectName} in repo ${a_APM_repo} of type FOLDER and location ${l_APM_repositoryLocation}")
		if(EXISTS "${l_APM_repositoryLocation}/cmake/APM_${a_APM_projectName}.cmake")
			APM_message(STATUS "Module found.")
			include("${l_APM_repositoryLocation}/cmake/APM_${a_APM_projectName}.cmake")
			APM_require(VERSION ${APM_require_VERSION} ${ARGV})
		else(EXISTS "${l_APM_repositoryLocation}/cmake/APM_${a_APM_projectName}.cmake")
		
		endif(EXISTS "${l_APM_repositoryLocation}/cmake/APM_${a_APM_projectName}.cmake")
		
	endif(${l_APM_repositoryType} MATCHES "FOLDER")
endfunction()
#
#################################################
#				End Class Repository			#
#################################################



#################################################
#				User functions					#
#################################################

function(add_repository a_APM_name a_APM_type a_APM_address)
	#check if the repository already exists
	if(APM_repository_${a_APM_name})
		APM_message(SEND_ERROR "Repository ${APM_repository_${a_APM_name}} already exists. It will be overriden.")
	endif(APM_repository_${a_APM_name})
	
	#handle backslashes
	STRING(REPLACE "\\" "/" a_APM_address ${a_APM_address}) 
	#create repository
	APM_Repository_create(${a_APM_type} ${a_APM_address} APM_repository_${a_APM_name})
	#declare repository in parent scope
	set(APM_repository_${a_APM_name} ${APM_repository_${a_APM_name}} PARENT_SCOPE)
	#append repository to the list of repositories in current scope
	list(APPEND APM_repositories APM_repository_${a_APM_name})
	#apply modifications in parent scope
	set(APM_repositories ${APM_repositories} PARENT_SCOPE)
endfunction()

function(require a_APM_projectName)
	# Managing arguments
	set(l_APM_OptionArguments OPTIONAL REQUIRED QUIET EXACT)
	set(l_APM_OneValueArguments VERSION REPOSITORY)
	set(l_APM_MultipleValuesArguments TARGETS COMPONENTS)
	cmake_parse_arguments(APM_require "${l_APM_OptionArguments}" "${l_APM_OneValueArguments}" "${l_APM_MultipleValuesArguments}" ${ARGN})
	
	set(APM_QUIET ${APM_require_QUIET})
	
	if(NOT APM_require_REPOSITORY)
		set(APM_REPOSITORY_DIR ${APM_DEFAULT_REPOSITORY_DIR})
	else(NOT APM_require_REPOSITORY)
		APM_Repository_getLocation(APM_repository_${APM_require_REPOSITORY} l_APM_RepoLocation)
		set(APM_REPOSITORY_DIR ${l_APM_RepoLocation})
	endif(NOT APM_require_REPOSITORY)
	
	set(l_APM_forwarded_args)
	
	if(NOT APM_require_VERSION)
		set(APM_require_VERSION )
	else(NOT APM_require_VERSION)
		list(APPEND l_APM_forwarded_args ${APM_require_VERSION})
	endif(NOT APM_require_VERSION)
	
	if(NOT APM_require_EXACT)
		set(APM_require_EXACT )
	else(NOT APM_require_EXACT)
		list(APPEND l_APM_forwarded_args EXACT)
	endif(NOT APM_require_EXACT)
	
	if(NOT APM_require_OPTIONAL)
		set(APM_require_OPTIONAL )
	else(NOT APM_require_OPTIONAL)
		list(APPEND l_APM_forwarded_args OPTIONAL)
	endif(NOT APM_require_OPTIONAL)
	
	
	if(NOT APM_require_QUIET)
		set(APM_require_QUIET )
	else(NOT APM_require_QUIET)
		list(APPEND l_APM_forwarded_args QUIET)
	endif(NOT APM_require_QUIET)
	
	if(NOT APM_require_COMPONENTS)
		set(APM_require_COMPONENTS )
	else(NOT APM_require_COMPONENTS)
		list(APPEND l_APM_forwarded_args COMPONENTS ${APM_require_COMPONENTS})
	endif(NOT APM_require_COMPONENTS)
	
	if(NOT APM_require_TARGETS)
		set(APM_require_TARGETS )
	else(NOT APM_require_TARGETS)
		list(APPEND l_APM_forwarded_args TARGETS ${APM_require_TARGETS})
	endif(NOT APM_require_TARGETS)
	
	APM_message(STATUS "Requiring project ${a_APM_projectName}")
	
	# Each l_APM_repo contains the name of a repository variable
	foreach(l_APM_repo ${APM_repositories})
		APM_Repository_require(${l_APM_repo} ${a_APM_projectName} ${l_APM_forwarded_args})
	endforeach(l_APM_repo)
endfunction()


