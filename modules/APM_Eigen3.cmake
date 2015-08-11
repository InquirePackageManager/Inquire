#compile an already downloaded package
function(APM_compile_package )
	APM_compile_package_parse_arguments(l_APM_compile_package ${ARGN})

	APM_message(STATUS "Triggering compilation of Eigen3...")
	APM_ExternalProject_Add(Eigen3
		${l_APM_compile_package_VERSION}
		SOURCE_DIR  ${l_APM_compile_package_SOURCE_DIR}
	)
	APM_message(STATUS "Triggering compilation of Eigen3... OK")
endfunction()


function(APM_install_package)
	APM_install_package_parse_arguments(l_APM_install_package ${ARGN})
	if(NOT DEFINED l_APM_install_package_VERSION)
		APM_message(STATUS "Triggering installation of Eigen3 in version 3.2.5 (default)... ")
		set(l_APM_install_package_VERSION "3.2.5")
	else()
		APM_message(STATUS "Triggering installation of Eigen3 in version ${l_APM_install_package_VERSION}... ")
	endif()
	string(REPLACE "." "_" l_APM_underscore_version ${l_APM_install_package_VERSION})

	# install eigen through APM_ExternalProject_Add
	set(l_APM_EigenLocation https://bitbucket.org/eigen/eigen/get/${l_APM_install_package_VERSION}.tar.bz2)

	APM_ExternalProject_Add(Eigen3
		${l_APM_install_package_VERSION}
		URL ${l_APM_EigenLocation}
		PACKAGE_REPOSITORY ${l_APM_install_package_PACKAGE_REPOSITORY}#TODO if empty do not pass it
	)
	APM_message(STATUS "Triggering installation of Eigen3... OK")
endfunction()

function(APM_configure_targets)
	cmake_parse_arguments(l_APM_configure_targets "" "INSTALL_DIR" "TARGETS;COMPONENTS" ${ARGN})

	set(l_APM_include_dir "${l_APM_configure_targets_INSTALL_DIR}/include/eigen3")
	if(NOT DEFINED l_APM_configure_targets_TARGETS)
		APM_message(STATUS "Including directory ${l_APM_include_dir} globally.")
		include_directories(${l_APM_include_dir})
	else()
		APM_message(STATUS "Including directory ${l_APM_include_dir} for targets ${l_APM_configure_targets_TARGETS}.")
		foreach(l_APM_TARGET ${l_APM_configure_targets_TARGETS})
			target_include_directories(${l_APM_TARGET} PUBLIC ${l_APM_include_dir})
		endforeach(l_APM_TARGET)
	endif()
endfunction()
