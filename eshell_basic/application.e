class APPLICATION

create make

feature

	make
		do
			print (x + y)
		end

feature -- Properties

	x: INTEGER do Result := 5 end
	y: INTEGER do Result := 10 end

end