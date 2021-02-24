note
	description: "[
		Eiffel tests that can be executed by testing tool.
	]"
	author: "EiffelStudio test wizard"
	date: "$Date$"
	revision: "$Revision$"
	testing: "type/manual"

class
	REPL_EVALUATOR_TEST_SET

inherit
	TEST_SET_SUPPORT

feature -- Test routines

	is_assignment_test
			--
		local
			l_repl: REPL_EVALUATOR
		do
			create l_repl
			l_repl.set_last_line ("y:=1")
			assert ("is_assignment", l_repl.is_assignment)
		end

	generated_class_code_test
			--
		note
			testing:  "covers/{REPL_EVALUATOR}.generated_class_code",
						"execution/isolated", "execution/serial"
		local
			l_repl: REPL_EVALUATOR
		do
			create l_repl
			l_repl.set_last_expression ("1+1")
			assert_strings_equal_diff ("1_plus_1", generated_class_string_1, l_repl.generated_class_code)
		end

feature {NONE} -- Test Support

	generated_class_string_1: STRING = "[
class APPLICATION

create make

feature

	make
		do
			print (1+1)
		end

feature -- Properties

	

end
]"

feature -- Test routines

	generated_class_code_with_declaration_and_assignment_test
			--
		note
			testing:  "covers/{REPL_EVALUATOR}.generated_class_code",
						"execution/isolated", "execution/serial"
		local
			l_repl: REPL_EVALUATOR
		do
			create l_repl
			l_repl.evaluate_and_process ("x:" + {REPL_EVALUATOR}.integer_type_name)
			l_repl.set_last_expression ("x")
			assert_strings_equal ("1_plus_1", generated_class_string_2, l_repl.generated_class_code)
		end

feature {NONE} -- Test Support

	generated_class_string_2: STRING = "[
class APPLICATION

create make

feature

	make
		do
			print (x)
		end

feature -- Properties

	x: INTEGER do Result := 0 end

end
]"

feature -- Test routines

	declaration_test
			-- New test routine
		note
			testing:  "covers/{REPL_EVALUATOR}.evaluate",
						"covers/{REPL_EVALUATOR}.variables",
						"execution/isolated", "execution/serial"
		local
			l_repl: REPL_EVALUATOR
		do
			create l_repl
			l_repl.evaluate_and_process ("x:INTEGER")
		end

	assignment_test
			-- Test of assignment.
		note
			testing:  "covers/{REPL_EVALUATOR}.l_properties_key",
						"execution/isolated", "execution/serial"
		local
			l_repl: REPL_EVALUATOR
		do
			create l_repl
			l_repl.evaluate_and_process ("x:INTEGER")
			l_repl.evaluate_and_process ("x := 5+5")
			if attached l_repl.variables ["x"] as al_var_tuple and then attached al_var_tuple.value as al_value then
				assert_strings_equal ("10", "10", al_value.out)
			end
		end

feature {NONE} -- Test Support

	declare_x_application_e: STRING = "[
class APPLICATION

create make

feature

	make
		do
			print (x)
		end

feature -- Properties

	x: INTEGER
		attribute
			Result := 0
		end

end
]"

end


