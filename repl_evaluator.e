class
	REPL_EVALUATOR

feature -- Settings

	set_last_expression (a_expr: like last_expression)
			-- Sets `last_expression' to `a_expr'.
		do
			last_expression := a_expr
		end

	set_last_line (a_line: like last_line)
			--
		do
			last_line := a_line
		ensure
			set: last_line.same_string (a_line)
		end

feature -- Access

	last_expression: detachable STRING assign set_last_expression
	last_expression_attached: attached like last_expression
		do
			check attached last_expression as al_result then
				Result := al_result
			end
		end

	last_line: STRING attribute create Result.make_empty end

	variables: HASH_TABLE [attached like variable_anchor, STRING]
			-- variables
		attribute
			create Result.make (100)
		end

feature -- Basic Operations

	evaluate_and_process (a_line: STRING)
			-- `evaluate_and_process' `a_line' of input from user.
		require
			not_exit: not a_line.same_string ({REPL_ENGINE}.exit_command)
		do
			reset_last_blah_properties

			last_line := a_line.twin
			last_line.adjust

			if is_comment (last_line) then
				print ("comment: " + last_line + "%N")
			elseif is_declaration then
				process_declaration
			elseif is_assignment then
				process_assignment
			elseif is_do_end (last_line) then
				print ("do ... end")
			elseif last_line.is_empty then
				do_nothing
			else
				process_expression
			end
			print ("%N")
		end

feature -- Queries

	is_comment (s: STRING): BOOLEAN
			-- Is `s' a comment?
		do
			Result := s.substring (1, 2).same_string ("--")
		end

	is_declaration: BOOLEAN
			-- Is `s' a declaration? (e.g. x: INTEGER)
		do
			Result := last_line.has (':') and then (last_line.split (':')).count = 2
		end

	is_assignment: BOOLEAN
			-- Is `s' and assignment instruction?
		local
			l_line: STRING
		do
			l_line := last_line.twin
			l_line.replace_substring_all (":=", "%N")
			Result := last_line.has_substring (":=") and then (l_line.split ('%N')).count = 2
		ensure
			last_line.same_string (old last_line)
		end

	is_do_end (s: STRING): BOOLEAN
			-- Is `s' a do-end block?
		do

		end

feature -- Operations

	reset_last_blah_properties
			--
		do
			last_variable := Void
			last_type := Void
			last_expression := Void
			last_declared_variable := Void
		end

	process_assignment
			--
		require
			has_assignment_mark: last_line.has_substring (":=")
		local
			l_list: LIST [STRING]
		do
			last_expression := last_line.twin
			last_line.replace_substring_all (":=", "%N")
			l_list := last_line.split ('%N')

			check precisely_two: l_list.count = 2 end

			last_variable := l_list [1]
			last_expression := l_list [2]

			if attached variables [last_variable_attached] as al_variable_tuple then
				last_declared_variable := al_variable_tuple
				last_line := last_expression_attached
				process_expression
				al_variable_tuple.value := last_eshell_basic_output_attached
			else
				print ("Variable `" + last_variable_attached + "' is undeclared." )
			end
		end

	process_declaration
			-- Process a declaration in `last_line'
		note
			warning: "[
				Declaring a variable in EShell does not require a code change
				and then compile. It only requires ensuring that we capture the
				name and type in the `variables' list with no expression or value.
				]"
		require
			has_line: attached last_line as al_line and then al_line.has (':')
		local
			l_list: LIST [STRING]
			l_last_line: STRING
		do
			l_last_line := last_line.twin
			l_last_line.replace_substring_all (":", "%N")
			l_list := l_last_line.split ('%N')

			check precisely_two: l_list.count = 2 end

			last_variable := l_list [1]
			last_type := l_list [2]
			check no_u: not last_type_attached.has ('%U') end
			last_declared_variable := [last_variable_attached, null_variable, null_value, last_type_attached]
			variables.force (last_declared_variable_attached, last_variable_attached)
		ensure
			has_variable: attached variables.has (last_variable_attached)
			no_expression: attached variables [last_variable_attached] as al_tuple and then
							not attached al_tuple.expression
			no_value: not attached al_tuple.value
		end

	process_expression
			-- Process `last_expression' in `last_line'.
		do
			last_expression := last_line.twin
			application_make (generated_class_code)
			compile_eshell_basic
		end

	generated_class_code: STRING
			--
		require
			attached last_expression
		local
			l_class_code,
			l_properties,
			l_property,
			l_type: STRING
		do
				-- expression into make print (expr)
			l_class_code := eshell_APPLICATION_make_expression.twin
			l_class_code.replace_substring_all (expression_key, last_expression_attached)

				-- variables to properties
			create l_properties.make_empty
			check has_all_types: across variables as ic all attached ic.item.type as al_type and then not al_type.is_empty end end
			across variables as ic loop
				create l_property.make_empty
				check has_type: attached ic.item.type as al_type then l_type := al_type end
				l_type.replace_substring_all ("%U", "")
				if l_type.same_string (any_type_name) then
					do_nothing -- for the moment ...
				elseif l_type.same_string (integer_type_name) then
					l_property.append_string_general (ic.item.identifier + ": " + l_type)
					if attached ic.item.value as al_value then
						l_property.append_string_general (" attribute Result := " + al_value.out + " end")
					else
						l_property.append_string_general (" attribute Result := 0 end")
					end
				else
					check unknown_type: False end
				end
				l_properties.append_string_general (l_property)
			end
			l_class_code.replace_substring_all (properties_key, l_properties)

				-- code to file
			Result := l_class_code
		ensure
			no_expression_key: not Result.has_substring (expression_key)
			no_properties_key: not Result.has_substring (properties_key)
		end

	application_make (a_code: STRING)
			-- Create APPLICATION.e class file
		local
			l_file: PLAIN_TEXT_FILE
		do
			create l_file.make_create_read_write ("./eshell_basic/application.e")
			l_file.put_string (a_code)
			l_file.close
		end

	compile_eshell_basic
			--
		local
			l_output: STRING
		do
				-- Compile
			l_output := process.output_of_command (compile_eshell, Void)
			if l_output.has_substring ("C compilation completed") then
				last_eshell_basic_output := process.output_of_command (call_eshell_basic_exe, Void)
				print ("= " + last_eshell_basic_output_attached)
			else
				print ("Compile error%N")
				print (l_output)
			end
		end

	last_eshell_basic_output: detachable STRING
	last_eshell_basic_output_attached: attached like last_eshell_basic_output
		do
			check attached last_eshell_basic_output as al_result then
				Result := al_result
			end
		end

	any_type_name: STRING = "ANY"

	integer_type_name: STRING = "INTEGER"

feature {NONE} -- Implementation: Access

	null_variable: detachable STRING
	null_value: detachable ANY

	last_variable: detachable STRING
	last_variable_attached: attached like last_variable
		do
			check attached last_variable as al_result then
				Result := al_result
			end
		end

	last_type: detachable STRING
	last_type_attached: attached like last_type
		do
			check attached last_type as al_result then
				Result := al_result
			end
		end

	last_declared_variable: like variable_anchor
	last_declared_variable_attached: attached like last_declared_variable
		do
			check attached last_declared_variable as al_result then
				Result := al_result
			end
		end

	variable_anchor: detachable TUPLE [identifier: STRING expression: detachable STRING; value: detachable ANY; type: STRING]

feature {NONE} -- Implementation: Constants

	process: FW_PROCESS_HELPER
			-- CLI Processor
		once
			create Result
		end

	compile_eshell: STRING = "C:\PROGRA~1\EIFFEL~1\EIFFEL~1.05S\studio\spec\win64\bin\ec.exe -config ./eshell_basic/eshell_basic.ecf -project_path ./eshell_basic -freeze -c_compile"

	call_eshell_basic_exe: STRING = "./eshell_basic/EIFGENs/eshell_basic/W_code/eshell_basic.exe"

	expression_key: STRING = "<<EXPRESSION>>"

	properties_key: STRING = "<<PROPERTIES>>"

	eshell_APPLICATION_make_expression: STRING = "[
class APPLICATION

create make

feature

	make
		do
			print (<<EXPRESSION>>)
		end

feature -- Properties

	<<PROPERTIES>>

end
]"

end
