include(CMakeParseArguments)
include(ExternalProject)

set(APM_DEFAULT_REPOSITORY_DIR "C:/Developpements/APM/repo")
function(APM_install)
endfunction()

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
function(APM_Repository_getProject a_APM_repo a_APM_projectName)
	APM_Repository_getType(${a_APM_repo} l_APM_repositoryType)
	APM_Repository_getLocation(${a_APM_repo} l_APM_repositoryLocation)
	
	if(${l_APM_repositoryType} MATCHES "FOLDER")
		APM_message(STATUS "Search project ${a_APM_projectName} in repo ${a_APM_repo} of type FOLDER and location ${l_APM_repositoryLocation}")
		if(EXISTS "${l_APM_repositoryLocation}/APM_${a_APM_projectName}.cmake")
			include("${l_APM_repositoryLocation}/APM_${a_APM_projectName}.cmake")
			APM_install(VERSION APM_require_VERSION)
		else(EXISTS "${l_APM_repositoryLocation}/APM_${a_APM_projectName}.cmake")
			APM_message(STATUS "Merde alors... ${l_APM_repositoryLocation}/APM_${a_APM_projectName}.cmake")
		endif(EXISTS "${l_APM_repositoryLocation}/APM_${a_APM_projectName}.cmake")
		
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
	set(l_APM_MultipleValuesArguments TARGETS)
	cmake_parse_arguments(APM_require "${l_APM_OptionArguments}" "${l_APM_OneValueArguments}" "${l_APM_MultipleValuesArguments}" ${ARGN})
	set(APM_QUIET ${APM_require_QUIET})
	if(NOT APM_require_REPOSITORY)
		set(APM_REPOSITORY_DIR ${APM_DEFAULT_REPOSITORY_DIR})
	else(NOT APM_require_REPOSITORY)
		APM_Repository_getLocation(APM_repository_${APM_require_REPOSITORY} l_APM_RepoLocation)
		set(APM_REPOSITORY_DIR ${l_APM_RepoLocation})
	endif(NOT APM_require_REPOSITORY)
	
	
	APM_message(STATUS "Requiring project ${a_APM_projectName}")
	# Each l_APM_repo contains the name of a repository variable
	foreach(l_APM_repo ${APM_repositories})
		APM_Repository_getProject(${l_APM_repo} ${a_APM_projectName})
	endforeach(l_APM_repo)
endfunction()


