class APPLICATION

create make

feature

	make
		do
			print (first + space + last)
		end

feature -- Properties

	a: ARRAY [STRING] do Result := <<"a","b">> end
	first: STRING do Result := "Larry" end
	last: STRING do Result := "Rix" end
	space: STRING do Result := " " end

end