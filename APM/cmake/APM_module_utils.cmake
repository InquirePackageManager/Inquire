if(APM_MODULE_UTILS_INCLUDE_GUARD)
	APM_message(DEBUG "APM module utils already included.")
else()
	set(APM_MODULE_UTILS_INCLUDE_GUARD ON)

	include(${CMAKE_CURRENT_LIST_DIR}/APM_arguments_utils.cmake)

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

	#########################################
	#			APM_compile_package arguments			#
	#########################################

	set(APM_compile_package_option_arguments REQUIRED QUIET)
	set(APM_compile_package_one_value_arguments VERSION SOURCE_DIR)
	set(APM_compile_package_multiple_values_arguments COMPONENTS TARGETS)

	macro(APM_compile_package_parse_arguments a_APM_prefix)
		APM_parse_arguments(${a_APM_prefix} "${APM_compile_package_option_arguments}"
											"${APM_compile_package_one_value_arguments}"
											"${APM_compile_package_multiple_values_arguments}"
											${ARGN})
	endmacro()


	#####################################################
	#			APM_find_package arguments				#
	#####################################################

	set(APM_configure_package_option_arguments EXACT QUIET MODULE REQUIRED NO_POLICY_SCOPE)
	set(APM_configure_package_one_value_arguments VERSION PACKAGE_REPOSITORY)
	set(APM_configure_package_multiple_values_arguments COMPONENTS OPTIONAL_COMPONENTS TARGETS)

	macro(APM_configure_package_parse_arguments a_APM_prefix)
		APM_parse_arguments(${a_APM_prefix} "${APM_configure_package_option_arguments}"
											"${APM_configure_package_one_value_arguments}"
											"${APM_configure_package_multiple_values_arguments}"
											${ARGN})
	endmacro()


	macro(APM_find_package a_APM_project)
		cmake_policy(SET CMP0057 NEW)
		set(l_APM_OptionArguments EXACT QUIET MODULE REQUIRED NO_POLICY_SCOPE)
		set(l_APM_OneValueArguments )
		set(l_APM_MultipleValuesArguments COMPONENTS OPTIONAL_COMPONENTS)

		list(GET ARGN 0 l_APM_probable_version)
		list(APPEND l_APM_global_list ${APM_configure_package_option_arguments} ${APM_configure_package_one_value_arguments} ${APM_configure_package_multiple_values_arguments})
		if(l_APM_probable_version IN_LIST l_APM_global_list)
			set(l_APM_version)
		else()
			set(l_APM_version ${l_APM_probable_version})
		endif()

		APM_filter_arguments(l_APM_res
			"${APM_configure_package_option_arguments}" 			# \
			"${APM_configure_package_one_value_arguments}" 		#  |	Arguments of APM_configure_package
			"${APM_configure_package_multiple_values_arguments}" # /
			"${l_APM_OptionArguments}" 						# \
			"${l_APM_OneValueArguments}" 					#  |	Arguments of find_package
			"${l_APM_MultipleValuesArguments}" 				# /
			${ARGN})
		find_package(${a_APM_project} 3.2.5 ${l_APM_res})
	endmacro()
endif()
