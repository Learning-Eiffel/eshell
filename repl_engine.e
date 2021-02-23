class
	REPL_ENGINE

feature -- Basic Operations

	process
			-- REPL Loop
		note
			description: "[
				REPL = Read -> Evaluate -> Process -> Loop
				]"
		do
			from
				print (eshell_header)
			until
				io.laststring.same_string (exit_command)
			loop
				print (prompt)
				io.readline
				if not io.laststring.same_string (exit_command) then
					evaluator.evaluate_and_process (io.laststring)
				end
			end
		end

	evaluator: REPL_EVALUATOR
			--
		once
			create Result
		end

feature -- Constants

	exit_command: STRING = "/exit"

	prompt: STRING = ">>>"

feature {NONE} -- Constants

	eshell_header: STRING = "[
Eshell version 0.1

]"

end
