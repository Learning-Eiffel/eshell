note
	description: "eshell application root class"

class
	APPLICATION

inherit
	ARGUMENTS_32

create
	make

feature {NONE} -- Initialization

	make
			-- Run application.
		local
			l_repl: REPL_ENGINE
		do
			create l_repl
			l_repl.process
		end

note
	brainstorm_notes: "[
		Use the Eiffel compiler behind the scenes to compile a generated project
		and a single APPLICATION class.
		
		Simple start: Process expressions as REPL
			R = read (expression)
			E = evaluate (expression)
			P = print (expression Result)
			L = loop (back to read)
			
		Expressions can be:
			Immediate computation (e.g. 5 * 2 + 2)
			Declaration (e.g. x: INTEGER or r: detachable ANY)
			Assignment (e.g. x := 5) (followed by variable being used)
			
		USE CASE #1: Immediate computation
		]"

end
