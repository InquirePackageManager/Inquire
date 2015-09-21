if(IPM_REPOSITORY_INCLUDE_GUARD)
	inquire_message(DEBUG "IPM repository already included.")
else()
	set(IPM_REPOSITORY_INCLUDE_GUARD ON)
	#################################################
	#				Class Repository				#
	#################################################
	#
	# Purpose : Create an instance of class Repository
	#
	# Input : a_IPM_repoType:
	#         -----------
	#         a_IPM_repoType          Variable containing the repository type;
	#         ${a_IPM_repoType}       Repository type.
	#         ------------------------------------------------------------------------------
	#         a_IPM_repoLocation:
	#         -----------
	#         a_IPM_repoLocation      Variable containing the repository location;
	#         ${a_IPM_repoLocation}   Repository location.
	#         ------------------------------------------------------------------------------
	#         a_IPM_res:
	#         ----------
	#         a_IPM_res               Result variable name.
	#		  ${a_IPM_res}            Variable containing the result;
	#		  ${${a_IPM_res}}         Result.
	#         ------------------------------------------------------------------------------
	function(IPM_Repository_create a_IPM_repoType a_IPM_repoLocation a_IPM_res)
		file(TO_CMAKE_PATH ${a_IPM_repoLocation} l_IPM_repo_location)
		list(APPEND ${a_IPM_res} ${a_IPM_repoType} "${l_IPM_repo_location}")
		set(${a_IPM_res} "${${a_IPM_res}}" PARENT_SCOPE)
	endfunction()
	#
	# Purpose : Given a repository, return its type (FOLDER, GIT, etc.)
	#
	# Input : a_IPM_repo:
	#         -----------
	#         a_IPM_repo      Variable containing the name of the repository variable;
	#         ${a_IPM_repo}   Repository variable.
	#         ------------------------------------------------------------------------------
	#         a_IPM_res:
	#         ----------
	#         a_IPM_res       Result variable name.
	#		  ${a_IPM_res}    Variable containing the result;
	#		  ${${a_IPM_res}} Result.
	#         ------------------------------------------------------------------------------
	function(IPM_Repository_getType a_IPM_repo a_IPM_res)
		list(GET ${a_IPM_repo} 0 ${a_IPM_res})
		set(${a_IPM_res} "${${a_IPM_res}}" PARENT_SCOPE)
	endfunction()
	#
	# Purpose : Given a repository, return its location
	#
	# Input : a_IPM_repo:
	#         -----------
	#         a_IPM_repo      Variable containing the name of the repository variable;
	#         ${a_IPM_repo}   Repository variable.
	#         ------------------------------------------------------------------------------
	#         a_IPM_res:
	#         ----------
	#         a_IPM_res       Result variable name.
	#		  ${a_IPM_res}    Variable containing the result;
	#		  ${${a_IPM_res}} Result.
	#         ------------------------------------------------------------------------------
	function(IPM_Repository_getLocation a_IPM_repo a_IPM_res)
		list(GET ${a_IPM_repo} 1 ${a_IPM_res})
		set(${a_IPM_res} "${${a_IPM_res}}" PARENT_SCOPE)
	endfunction()
	#
	# Purpose : Search the project a_IPM_projectName in the Repository a_IPM_repo
	#
	# Input : a_IPM_repo:
	#         -----------
	#         a_IPM_repo              Variable containing the repository variable name;
	#         ${a_IPM_repo}           Repository variable.
	#         ${${a_IPM_repo}}        Repository content.
	#         ------------------------------------------------------------------------------
	#         a_IPM_projectName:
	#         -----------
	#         a_IPM_projectName       Variable containing the project name;
	#         ${a_IPM_projectName}    Project name.
	#         ------------------------------------------------------------------------------
	function(IPM_require_module a_IPM_repo a_IPM_projectName a_IPM_res)
		IPM_Repository_getType(${a_IPM_repo} l_IPM_repositoryType)
		IPM_Repository_getLocation(${a_IPM_repo} l_IPM_repositoryLocation)

		if("${l_IPM_repositoryType}" MATCHES "FOLDER")
			if(EXISTS "${l_IPM_repositoryLocation}/Inquire_${a_IPM_projectName}.cmake")
				set(${a_IPM_res} "${l_IPM_repositoryLocation}/Inquire_${a_IPM_projectName}.cmake" PARENT_SCOPE)
			else()
				unset(${a_IPM_res} PARENT_SCOPE)
			endif()
		else()
			inquire_message(FATAL_ERROR "Unknown repository type : ${l_IPM_repositoryType}")
		endif()
	endfunction()
	#
	#################################################
	#				End Class Repository			#
	#################################################
endif()
