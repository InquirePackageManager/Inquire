if(APM_REPOSITORY_INCLUDE_GUARD)
	APM_message(DEBUG "APM repository already included.")
else()
	set(APM_REPOSITORY_INCLUDE_GUARD ON)
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
		file(TO_CMAKE_PATH ${a_APM_repoLocation} l_APM_repo_location)
		list(APPEND ${a_APM_res} ${a_APM_repoType} "${l_APM_repo_location}")
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
		APM_message(DEBUG "a_APM_res = ${a_APM_res}")
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
	function(APM_require_module a_APM_repo a_APM_projectName a_APM_res)
		APM_Repository_getType(${a_APM_repo} l_APM_repositoryType)
		APM_Repository_getLocation(${a_APM_repo} l_APM_repositoryLocation)

		if("${l_APM_repositoryType}" MATCHES "FOLDER")
			if(EXISTS "${l_APM_repositoryLocation}/APM_${a_APM_projectName}.cmake")
				set(${a_APM_res} "${l_APM_repositoryLocation}/APM_${a_APM_projectName}.cmake" PARENT_SCOPE)
			endif()
		else()
			APM_message(FATAL_ERROR "Unknown repository type : ${l_APM_repositoryType}")
		endif()
	endfunction()
	#
	#################################################
	#				End Class Repository			#
	#################################################
endif()
