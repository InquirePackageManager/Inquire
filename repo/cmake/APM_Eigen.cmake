function(APM_install)
	# Managing arguments
	set(l_APM_OptionArguments OPTIONAL REQUIRED QUIET EXACT)
	set(l_APM_OneValueArguments VERSION INSTALL_PATH)
	set(l_APM_MultipleValuesArguments TARGETS)
	cmake_parse_arguments(l_APM_install "${l_APM_OptionArguments}" "${l_APM_OneValueArguments}" "${l_APM_MultipleValuesArguments}" ${ARGN})
	
	if(NOT l_APM_install_VERSION)
		set(l_APM_install_VERSION "3.2.5")
	endif(NOT l_APM_install_VERSION)
	
	set(l_APM_EigenLocation "https://bitbucket.org/eigen/eigen/get/${l_APM_install_VERSION}.tar.bz2")
	set(l_APM_EigenLocalDir "${APM_REPOSITORY_DIR}/Eigen/${l_APM_install_VERSION}")

	APM_ExternalProject_Add(Eigen ${l_APM_install_VERSION}
		URL ${l_APM_EigenLocation}
    )
	set(APM_Eigen_INCLUDE_DIR "${APM_Eigen_${l_APM_install_VERSION}_SOURCE_DIR}/include/eigen3")
endfunction()