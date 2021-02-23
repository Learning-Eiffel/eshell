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


