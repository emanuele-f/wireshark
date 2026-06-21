# Create macros for using the lemon parser generator.

SET(LEMON_DEP "")

if( LEMON_BIN )
   # Use externally provided lemon binary (e.g. for cross-compilation)
   SET(LEMON_DEP "")
elseif (CMAKE_CROSSCOMPILING AND EXISTS /usr/share/lemon/lempar.c)
   # If we're cross-compiling and /usr/share/lemon/lempar.c exists, try to
   # find the system lemon and use it.
   find_program(LEMON_EXECUTABLE lemon)
   if(LEMON_EXECUTABLE)
      SET(LEMON_BIN ${LEMON_EXECUTABLE})
   endif()
endif()

if(LEMON_BIN)
	macro(generate_lemon_file _out _in)
		add_custom_command(
			OUTPUT
				${_out}.c
				# These files are generated as side-effect
				${_out}.h
				${_out}.out
			COMMAND "${LEMON_BIN}"
				-T${CMAKE_SOURCE_DIR}/tools/lemon/lempar.c
				-d.
				${_in}
			DEPENDS
				${_in}
				${LEMON_DEP}
				${CMAKE_SOURCE_DIR}/tools/lemon/lempar.c
		)
	endmacro()
	add_custom_target(lemon)
else()
	# Compile bundled lemon with support for -- to end options
	macro(generate_lemon_file _out _in)
		add_custom_command(
			OUTPUT
				${_out}.c
				# These files are generated as side-effect
				${_out}.h
				${_out}.out
			COMMAND $<TARGET_FILE:lemon>
				-T${CMAKE_SOURCE_DIR}/tools/lemon/lempar.c
				-d.
				--
				${_in}
			DEPENDS
				${_in}
				lemon
				${CMAKE_SOURCE_DIR}/tools/lemon/lempar.c
		)
	endmacro()
endif()

macro(ADD_LEMON_FILES _source _generated)

	foreach (_current_FILE ${ARGN})
		get_filename_component(_in ${_current_FILE} ABSOLUTE)
		get_filename_component(_basename ${_current_FILE} NAME_WE)

		set(_out ${CMAKE_CURRENT_BINARY_DIR}/${_basename})

		generate_lemon_file(${_out} ${_in})

		list(APPEND ${_source} ${_in})
		list(APPEND ${_generated} ${_out}.c)
	endforeach(_current_FILE)
endmacro(ADD_LEMON_FILES)
