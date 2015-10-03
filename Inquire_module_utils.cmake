if(IPM_MODULE_UTILS_INCLUDE_GUARD)
	inquire_message(DEBUG "IPM module utils already included.")
else()
	set(IPM_MODULE_UTILS_INCLUDE_GUARD ON)


	function(IPM_parse_arguments a_IPM_prefix a_IPM_option_arguments a_IPM_one_value_arguments a_IPM_multiple_values_arguments)
		cmake_parse_arguments(${a_IPM_prefix}
			"${a_IPM_option_arguments}"
			"${a_IPM_one_value_arguments}"
			"${a_IPM_multiple_values_arguments}"
			${ARGN})

		foreach(l_IPM_option_arg ${a_IPM_option_arguments})
			if(DEFINED ${a_IPM_prefix}_${l_IPM_option_arg})
				set(${a_IPM_prefix}_${l_IPM_option_arg} ${${a_IPM_prefix}_${l_IPM_option_arg}} PARENT_SCOPE)
			endif()
		endforeach()

		foreach(l_IPM_one_value_arg ${a_IPM_one_value_arguments})
			if(DEFINED ${a_IPM_prefix}_${l_IPM_one_value_arg})
				set(${a_IPM_prefix}_${l_IPM_one_value_arg} ${${a_IPM_prefix}_${l_IPM_one_value_arg}} PARENT_SCOPE)
			endif()
		endforeach()

		foreach(l_IPM_multiple_values_arg ${a_IPM_multiple_values_arguments})
			if(DEFINED ${a_IPM_prefix}_${l_IPM_multiple_values_arg})
				set(${a_IPM_prefix}_${l_IPM_multiple_values_arg} ${${a_IPM_prefix}_${l_IPM_multiple_values_arg}} PARENT_SCOPE)
			endif()
		endforeach()
	endfunction()

	#########################################
	#			IPM_install_package arguments			#
	#########################################

	set(IPM_install_package_option_arguments REQUIRED QUIET)
	set(IPM_install_package_one_value_arguments VERSION PACKAGE_REPOSITORY)
	set(IPM_install_package_multiple_values_arguments COMPONENTS TARGETS)

	macro(IPM_install_package_parse_arguments a_IPM_prefix)
		IPM_parse_arguments(${a_IPM_prefix} "${IPM_install_package_option_arguments}"
											"${IPM_install_package_one_value_arguments}"
											"${IPM_install_package_multiple_values_arguments}"
											${ARGN})
	endmacro()

	#############################################
	#			compile_package_version arguments			#
	#############################################

	set(IPM_compile_package_version_option_arguments )
	set(IPM_compile_package_version_one_value_arguments )
	set(IPM_compile_package_version_multiple_values_arguments COMPONENTS)

	macro(IPM_compile_package_version_parse_arguments a_IPM_prefix)
		IPM_parse_arguments(${a_IPM_prefix} "${IPM_compile_package_version_option_arguments}"
											"${IPM_compile_package_version_one_value_arguments}"
											"${IPM_compile_package_version_multiple_values_arguments}"
											${ARGN})
	endmacro()


	###########################################
	#     IPM_configure_targets arguments     #
	###########################################

	set(IPM_configure_targets_option_arguments )
	set(IPM_configure_targets_one_value_arguments INSTALL_DIR VERSION)
	set(IPM_configure_targets_multiple_values_arguments COMPONENTS TARGETS)

	macro(IPM_configure_targets_parse_arguments a_IPM_prefix)
		IPM_parse_arguments(${a_IPM_prefix} "${IPM_configure_targets_option_arguments}"
											"${IPM_configure_targets_one_value_arguments}"
											"${IPM_configure_targets_multiple_values_arguments}"
											${ARGN})
	endmacro()



	#################################################
	#     check_package_compatibility arguments     #
	#################################################

	set(IPM_check_package_compatibility_option_arguments )
	set(IPM_check_package_compatibility_one_value_arguments DETAILS)
	set(IPM_check_package_compatibility_multiple_values_arguments )

	macro(IPM_check_package_compatibility_parse_arguments a_IPM_prefix)
		IPM_parse_arguments(${a_IPM_prefix} "${IPM_install_package_option_arguments}"
											"${IPM_install_package_one_value_arguments}"
											"${IPM_install_package_multiple_values_arguments}"
											${ARGN})
	endmacro()


	#################################################
	#     check_package_compatibility arguments     #
	#################################################

	set(IPM_get_compatible_package_version_root_option_arguments EXACT)
	set(IPM_get_compatible_package_version_root_one_value_arguments )
	set(IPM_get_compatible_package_version_root_multiple_values_arguments )

	macro(IPM_get_compatible_package_version_root_parse_arguments a_IPM_prefix)
		IPM_parse_arguments(${a_IPM_prefix} "${IPM_install_package_option_arguments}"
											"${IPM_install_package_one_value_arguments}"
											"${IPM_install_package_multiple_values_arguments}"
											${ARGN})
	endmacro()


	######################################################
	#     package_version_need_compilation arguments     #
	######################################################

	set(IPM_package_version_need_compilation_option_arguments )
	set(IPM_package_version_need_compilation_one_value_arguments )
	set(IPM_package_version_need_compilation_multiple_values_arguments COMPONENTS)

	macro(IPM_package_version_need_compilation_parse_arguments a_IPM_prefix)
		IPM_parse_arguments(${a_IPM_prefix} "${IPM_install_package_option_arguments}"
											"${IPM_install_package_one_value_arguments}"
											"${IPM_install_package_multiple_values_arguments}"
											${ARGN})
	endmacro()


	######################################################
	#     configure_package_version arguments     #
	######################################################

	set(IPM_configure_package_version_parse_arguments_option_arguments )
	set(IPM_configure_package_version_parse_arguments_one_value_arguments FILES_TO_INCLUDE)
	set(IPM_configure_package_version_parse_arguments_multiple_values_arguments COMPONENTS TARGETS)

	macro(IPM_configure_package_version_parse_arguments a_IPM_prefix)
		IPM_parse_arguments(${a_IPM_prefix} "${IPM_configure_package_version_parse_arguments_option_arguments}"
											"${IPM_configure_package_version_parse_arguments_one_value_arguments}"
											"${IPM_configure_package_version_parse_arguments_multiple_values_arguments}"
											${ARGN})
	endmacro()



	# macro(IPM_find_package a_IPM_project)
	# 	cmake_policy(SET CMP0057 NEW)
	# 	set(l_IPM_OptionArguments EXACT QUIET MODULE REQUIRED NO_POLICY_SCOPE)
	# 	set(l_IPM_OneValueArguments )
	# 	set(l_IPM_MultipleValuesArguments COMPONENTS OPTIONAL_COMPONENTS)
	#
	# 	list(GET ARGN 0 l_IPM_probable_version)
	# 	list(APPEND l_IPM_global_list ${IPM_configure_package_option_arguments} ${IPM_configure_package_one_value_arguments} ${IPM_configure_package_multiple_values_arguments})
	# 	if(l_IPM_probable_version IN_LIST l_IPM_global_list)
	# 		set(l_IPM_version)
	# 	else()
	# 		set(l_IPM_version ${l_IPM_probable_version})
	# 	endif()
	#
	# 	IPM_filter_arguments(l_IPM_res
	# 		"${IPM_configure_package_option_arguments}" 			# \
	# 		"${IPM_configure_package_one_value_arguments}" 		#  |	Arguments of IPM_configure_package
	# 		"${IPM_configure_package_multiple_values_arguments}" # /
	# 		"${l_IPM_OptionArguments}" 						# \
	# 		"${l_IPM_OneValueArguments}" 					#  |	Arguments of find_package
	# 		"${l_IPM_MultipleValuesArguments}" 				# /
	# 		${ARGN})
	# 	find_package(${a_IPM_project} 3.2.5 ${l_IPM_res})
	# endmacro()

endif()
