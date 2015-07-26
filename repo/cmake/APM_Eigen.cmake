function(APM_install)
	# Managing arguments
	set(l_APM_OptionArguments OPTIONAL REQUIRED QUIET EXACT)
	set(l_APM_OneValueArguments VERSION)
	set(l_APM_MultipleValuesArguments TARGETS)
	cmake_parse_arguments(APM_installEigen "${l_APM_OptionArguments}" "${l_APM_OneValueArguments}" "${l_APM_MultipleValuesArguments}" ${ARGN})
	
	if(NOT APM_requireEigen_VERSION)
		set(APM_requireEigen_VERSION "3.2.5")
	endif(NOT APM_requireEigen_VERSION)
	
	set(l_APM_EigenLocation "https://bitbucket.org/eigen/eigen/get/${APM_requireEigen_VERSION}.tar.bz2")
	set(l_APM_EigenLocalDir "${APM_REPOSITORY_DIR}/Eigen/${APM_requireEigen_VERSION}")

	ExternalProject_Add(
		Eigen
		URL ${l_APM_EigenLocation}
		#URL_MD5 ${l_APM_EigenMD5}
		PREFIX ${l_APM_EigenLocalDir}
		DOWNLOAD_DIR ${l_APM_EigenLocalDir}/download
		SOURCE_DIR ${l_APM_EigenLocalDir}/source
		STAMP_DIR ${l_APM_EigenLocalDir}/stamps
		TMP_DIR ${l_APM_EigenLocalDir}/tmp
		BINARY_DIR ${l_APM_EigenLocalDir}/build
		CMAKE_ARGS
			${CMAKE_PROPAGATED_VARIABLES}
			-DCMAKE_INSTALL_PREFIX:PATH=${l_APM_EigenLocalDir}/install
			-DBUILD_TESTING=1
    )
	set(APM_Eigen_INCLUDE_DIR ${l_APM_EigenLocalDir}/include/eigen3)
endfunction()