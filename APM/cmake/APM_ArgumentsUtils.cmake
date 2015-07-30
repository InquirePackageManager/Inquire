function(APM_filter_arguments a_APM_res a_APM_OptionArgs a_APM_OneValueArgs a_APM_MultipleValuesArgs)
	cmake_parse_arguments(l_APM_filter_arguments "${a_APM_OptionArgs}" "${a_APM_OneValueArgs}" "${a_APM_MultipleValuesArgs}" ${ARGN})
	
	set(${a_APM_res} )
	
	foreach(l_APM_OptionArg ${a_APM_OptionArgs})
		if(l_APM_filter_arguments_${l_APM_OptionArg})
			list(APPEND ${a_APM_res} ${l_APM_OptionArg})
		endif(l_APM_filter_arguments_${l_APM_OptionArg})
	endforeach(l_APM_OptionArg)
	
	foreach(l_APM_OneValueArg ${a_APM_OneValueArgs})
		if(l_APM_filter_arguments_${l_APM_OneValueArg})
			list(APPEND ${a_APM_res} ${l_APM_OneValueArg} ${l_APM_filter_arguments_${l_APM_OneValueArg}})
		endif(l_APM_filter_arguments_${l_APM_OneValueArg})
	endforeach(l_APM_OneValueArg)
	
	foreach(l_APM_MultipleValuesArg ${a_APM_MultipleValuesArgs})
		if(l_APM_filter_arguments_${l_APM_MultipleValuesArg})
			list(APPEND ${a_APM_res} ${l_APM_MultipleValuesArg} ${l_APM_filter_arguments_${l_APM_MultipleValuesArg}})
		endif(l_APM_filter_arguments_${l_APM_MultipleValuesArg})
	endforeach(l_APM_MultipleValuesArg)
endfunction()



function(APM_set_argument a_APM_res a_APM_args a_APM_argType a_APM_argName)
	set(l_APM_optionArgs "")
	set(l_APM_oneValueArgs "")
	set(l_APM_multipleValueArgs "")
	if(a_APM_argType MATCHES APM_OPTION_ARG_TYPE)
		set(l_APM_optionArgs "${a_APM_argName}")
	elseif(a_APM_argType MATCHES APM_ONE_VALUE_ARG_TYPE)
		set(l_APM_oneValueArgs "${a_APM_argName}")
	elseif(a_APM_argType MATCHES APM_MULTIPLE_VALUE_ARG_TYPE)
		set(l_APM_multipleValueArgs "${a_APM_argName}")
	endif()

	cmake_parse_arguments(l_APM_arguments "${l_APM_optionArgs}" "${l_APM_oneValueArgs}" "${l_APM_multipleValueArgs}" ${${a_APM_args}})
	message("cmake_parse_arguments(l_APM_arguments \"${l_APM_optionArgs}\" \"${l_APM_oneValueArgs}\" \"${l_APM_multipleValueArgs}\" ${${a_APM_args}})")
	message("l_APM_arguments_UNPARSED_ARGUMENTS... = ${l_APM_arguments_UNPARSED_ARGUMENTS}")
	
	
	if(a_APM_argType MATCHES APM_OPTION_ARG_TYPE)
		if(${ARGN})
			set(l_APM_arguments_${a_APM_argName} ${a_APM_argName})
		endif()
	else()
		set(l_APM_arguments_${a_APM_argName} ${a_APM_argName} ${ARGN})
	endif()
	
	set(${a_APM_res} )
	list(APPEND ${a_APM_res} ${l_APM_arguments_UNPARSED_ARGUMENTS})	
	list(APPEND ${a_APM_res} ${l_APM_arguments_${a_APM_argName}})
	set(${a_APM_res} ${${a_APM_res}} PARENT_SCOPE)
endfunction()