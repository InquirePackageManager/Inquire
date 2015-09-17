if(APM_MODULE_UTILS_INCLUDE_GUARD)
	APM_message(DEBUG "APM module utils already included.")
else()
	set(APM_MODULE_UTILS_INCLUDE_GUARD ON)


	function(APM_parse_arguments a_APM_prefix a_APM_option_arguments a_APM_one_value_arguments a_APM_multiple_values_arguments)
		cmake_parse_arguments(${a_APM_prefix}
			"${a_APM_option_arguments}"
			"${a_APM_one_value_arguments}"
			"${a_APM_multiple_values_arguments}"
			${ARGN})

		foreach(l_APM_option_arg ${a_APM_option_arguments})
			if(DEFINED ${a_APM_prefix}_${l_APM_option_arg})
				set(${a_APM_prefix}_${l_APM_option_arg} ${${a_APM_prefix}_${l_APM_option_arg}} PARENT_SCOPE)
			endif()
		endforeach()

		foreach(l_APM_one_value_arg ${a_APM_one_value_arguments})
			if(DEFINED ${a_APM_prefix}_${l_APM_one_value_arg})
				set(${a_APM_prefix}_${l_APM_one_value_arg} ${${a_APM_prefix}_${l_APM_one_value_arg}} PARENT_SCOPE)
			endif()
		endforeach()

		foreach(l_APM_multiple_values_arg ${a_APM_multiple_values_arguments})
			if(DEFINED ${a_APM_prefix}_${l_APM_multiple_values_arg})
				set(${a_APM_prefix}_${l_APM_multiple_values_arg} ${${a_APM_prefix}_${l_APM_multiple_values_arg}} PARENT_SCOPE)
			endif()
		endforeach()
	endfunction()

	#########################################
	#			APM_install_package arguments			#
	#########################################

	set(APM_install_package_option_arguments REQUIRED QUIET)
	set(APM_install_package_one_value_arguments VERSION PACKAGE_REPOSITORY)
	set(APM_install_package_multiple_values_arguments COMPONENTS TARGETS)

	macro(APM_install_package_parse_arguments a_APM_prefix)
		APM_parse_arguments(${a_APM_prefix} "${APM_install_package_option_arguments}"
											"${APM_install_package_one_value_arguments}"
											"${APM_install_package_multiple_values_arguments}"
											${ARGN})
	endmacro()

	#############################################
	#			compile_package_version arguments			#
	#############################################

	set(APM_compile_package_version_option_arguments )
	set(APM_compile_package_version_one_value_arguments )
	set(APM_compile_package_version_multiple_values_arguments COMPONENTS)

	macro(APM_compile_package_version_parse_arguments a_APM_prefix)
		APM_parse_arguments(${a_APM_prefix} "${APM_compile_package_version_option_arguments}"
											"${APM_compile_package_version_one_value_arguments}"
											"${APM_compile_package_version_multiple_values_arguments}"
											${ARGN})
	endmacro()


	###########################################
	#     APM_configure_targets arguments     #
	###########################################

	set(APM_configure_targets_option_arguments )
	set(APM_configure_targets_one_value_arguments INSTALL_DIR VERSION)
	set(APM_configure_targets_multiple_values_arguments COMPONENTS TARGETS)

	macro(APM_configure_targets_parse_arguments a_APM_prefix)
		APM_parse_arguments(${a_APM_prefix} "${APM_configure_targets_option_arguments}"
											"${APM_configure_targets_one_value_arguments}"
											"${APM_configure_targets_multiple_values_arguments}"
											${ARGN})
	endmacro()



	#################################################
	#     check_package_compatibility arguments     #
	#################################################

	set(APM_check_package_compatibility_option_arguments )
	set(APM_check_package_compatibility_one_value_arguments DETAILS)
	set(APM_check_package_compatibility_multiple_values_arguments )

	macro(APM_check_package_compatibility_parse_arguments a_APM_prefix)
		APM_parse_arguments(${a_APM_prefix} "${APM_install_package_option_arguments}"
											"${APM_install_package_one_value_arguments}"
											"${APM_install_package_multiple_values_arguments}"
											${ARGN})
	endmacro()


	#################################################
	#     check_package_compatibility arguments     #
	#################################################

	set(APM_get_compatible_package_version_root_option_arguments EXACT)
	set(APM_get_compatible_package_version_root_one_value_arguments )
	set(APM_get_compatible_package_version_root_multiple_values_arguments )

	macro(APM_get_compatible_package_version_root_parse_arguments a_APM_prefix)
		APM_parse_arguments(${a_APM_prefix} "${APM_install_package_option_arguments}"
											"${APM_install_package_one_value_arguments}"
											"${APM_install_package_multiple_values_arguments}"
											${ARGN})
	endmacro()


	######################################################
	#     package_version_need_compilation arguments     #
	######################################################

	set(APM_package_version_need_compilation_option_arguments )
	set(APM_package_version_need_compilation_one_value_arguments )
	set(APM_package_version_need_compilation_multiple_values_arguments COMPONENTS)

	macro(APM_package_version_need_compilation_parse_arguments a_APM_prefix)
		APM_parse_arguments(${a_APM_prefix} "${APM_install_package_option_arguments}"
											"${APM_install_package_one_value_arguments}"
											"${APM_install_package_multiple_values_arguments}"
											${ARGN})
	endmacro()


	######################################################
	#     configure_package_version arguments     #
	######################################################

	set(APM_configure_package_version_parse_arguments_option_arguments )
	set(APM_configure_package_version_parse_arguments_one_value_arguments FILES_TO_INCLUDE)
	set(APM_configure_package_version_parse_arguments_multiple_values_arguments COMPONENTS TARGETS)

	macro(APM_configure_package_version_parse_arguments a_APM_prefix)
		APM_parse_arguments(${a_APM_prefix} "${APM_configure_package_version_parse_arguments_option_arguments}"
											"${APM_configure_package_version_parse_arguments_one_value_arguments}"
											"${APM_configure_package_version_parse_arguments_multiple_values_arguments}"
											${ARGN})
	endmacro()



	# macro(APM_find_package a_APM_project)
	# 	cmake_policy(SET CMP0057 NEW)
	# 	set(l_APM_OptionArguments EXACT QUIET MODULE REQUIRED NO_POLICY_SCOPE)
	# 	set(l_APM_OneValueArguments )
	# 	set(l_APM_MultipleValuesArguments COMPONENTS OPTIONAL_COMPONENTS)
	#
	# 	list(GET ARGN 0 l_APM_probable_version)
	# 	list(APPEND l_APM_global_list ${APM_configure_package_option_arguments} ${APM_configure_package_one_value_arguments} ${APM_configure_package_multiple_values_arguments})
	# 	if(l_APM_probable_version IN_LIST l_APM_global_list)
	# 		set(l_APM_version)
	# 	else()
	# 		set(l_APM_version ${l_APM_probable_version})
	# 	endif()
	#
	# 	APM_filter_arguments(l_APM_res
	# 		"${APM_configure_package_option_arguments}" 			# \
	# 		"${APM_configure_package_one_value_arguments}" 		#  |	Arguments of APM_configure_package
	# 		"${APM_configure_package_multiple_values_arguments}" # /
	# 		"${l_APM_OptionArguments}" 						# \
	# 		"${l_APM_OneValueArguments}" 					#  |	Arguments of find_package
	# 		"${l_APM_MultipleValuesArguments}" 				# /
	# 		${ARGN})
	# 	find_package(${a_APM_project} 3.2.5 ${l_APM_res})
	# endmacro()
endif()
