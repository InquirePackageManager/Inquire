if(APM_ARGUMENTS_UTILS_INCLUDE_GUARD)
	APM_message(DEBUG "APM arguments utils already included.")
else()
	set(APM_ARGUMENTS_UTILS_INCLUDE_GUARD ON)

	function(APM_filter_arguments a_APM_res a_APM_OptionArgs a_APM_OneValueArgs a_APM_MultipleValuesArgs
										a_APM_FilteredOptionArgs a_APM_FilteredOneValueArgs a_APM_FilteredMultipleValuesArgs)
		cmake_parse_arguments(l_APM_filter_arguments "${a_APM_OptionArgs}" "${a_APM_OneValueArgs}" "${a_APM_MultipleValuesArgs}" ${ARGN})

		set(${a_APM_res} )

		foreach(l_APM_OptionArg ${a_APM_FilteredOptionArgs})
			if(l_APM_filter_arguments_${l_APM_OptionArg})
				list(APPEND ${a_APM_res} ${l_APM_OptionArg})
			endif()
		endforeach(l_APM_OptionArg)

		foreach(l_APM_OneValueArg ${a_APM_FilteredOneValueArgs})
			if(DEFINED l_APM_filter_arguments_${l_APM_OneValueArg})
				list(APPEND ${a_APM_res} ${l_APM_OneValueArg} ${l_APM_filter_arguments_${l_APM_OneValueArg}})
			endif()
		endforeach(l_APM_OneValueArg)

		foreach(l_APM_MultipleValuesArg ${a_APM_FilteredMultipleValuesArgs})
			if(DEFINED l_APM_filter_arguments_${l_APM_MultipleValuesArg})
				list(APPEND ${a_APM_res} ${l_APM_MultipleValuesArg} ${l_APM_filter_arguments_${l_APM_MultipleValuesArg}})
			endif()
		endforeach(l_APM_MultipleValuesArg)

		set(${a_APM_res} ${${a_APM_res}} PARENT_SCOPE)
	endfunction()
#
# function(APM_filter_arguments_for_find_package a_APM_OptionArguments a_APM_OneValueArguments a_APM_MultipleValuesArguments a_APM_res)
# 	set(l_APM_OptionArguments EXACT QUIET MODULE REQUIRED NO_POLICY_SCOPE)
# 	set(l_APM_OneValueArguments VERSION)
# 	set(l_APM_MultipleValuesArguments COMPONENTS OPTIONAL_COMPONENTS)
# 	APM_message("ARGN = ${ARGN}")
# 	APM_filter_arguments(${a_APM_res} 	"${a_APM_OptionArguments}" "${a_APM_OneValueArguments}" "${a_APM_MultipleValuesArguments}"
# 										"${l_APM_OptionArguments}" "${l_APM_OneValueArguments}" "${l_APM_MultipleValuesArguments}" ${ARGN})
# 	APM_message("a_APM_res = ${a_APM_res}")
# 	APM_parentScope(a_APM_res)
# endfunction()
#
# function(APM_filter_arguments_for_APM_find_package a_APM_OptionArguments a_APM_OneValueArguments a_APM_MultipleValuesArguments a_APM_res)
# 	set(l_APM_OptionArguments EXACT QUIET MODULE REQUIRED NO_POLICY_SCOPE)
# 	set(l_APM_OneValueArguments VERSION)
# 	set(l_APM_MultipleValuesArguments COMPONENTS OPTIONAL_COMPONENTS)
# 	APM_filter_arguments(${a_APM_res} 	"${a_APM_OptionArguments}" "${a_APM_OneValueArguments}" "${a_APM_MultipleValuesArguments}"
# 										"${l_APM_OptionArguments}" "${l_APM_OneValueArguments}" "${l_APM_MultipleValuesArguments}" ${ARGN})
# 	APM_parentScope(a_APM_res)
# endfunction()
#
# function(APM_filter_arguments_for_install_package a_APM_OptionArguments a_APM_OneValueArguments a_APM_MultipleValuesArguments a_APM_res)
# 	set(l_APM_OptionArguments EXACT QUIET MODULE REQUIRED NO_POLICY_SCOPE)
# 	set(l_APM_OneValueArguments VERSION)
# 	set(l_APM_MultipleValuesArguments COMPONENTS OPTIONAL_COMPONENTS TARGETS)
# 	APM_filter_arguments(${a_APM_res} 	"${a_APM_OptionArguments}" "${a_APM_OneValueArguments}" "${a_APM_MultipleValuesArguments}"
# 										"${l_APM_OptionArguments}" "${l_APM_OneValueArguments}" "${l_APM_MultipleValuesArguments}" ${ARGN})
# 	APM_parentScope(a_APM_res)
# endfunction()






























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

	function(APM_set_argument a_APM_prefix a_APM_arg_name a_APM_arg_value)
		set(${a_APM_prefix}_${a_APM_arg_name} ${a_APM_arg_value} PARENT_SCOPE)
	endfunction()

	function(APM_append_to_argument a_APM_prefix a_APM_arg_name a_APM_arg_value)
		set(${a_APM_prefix}_${a_APM_arg_name} ${${a_APM_prefix}_${a_APM_arg_name}} ${a_APM_arg_value} PARENT_SCOPE)
	endfunction()

	function(APM_get_argument a_APM_prefix a_APM_arg_name a_APM_res)
		set(${a_APM_res} ${${a_APM_prefix}_${a_APM_arg_name}} PARENT_SCOPE)
	endfunction()

endif()
