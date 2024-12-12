# GenerateCompileCommands.cmake

# List of all include directories
set(ALL_INCLUDE_DIR     
    "${CMAKE_SOURCE_DIR}/lib/vendor/glm"
    "${CMAKE_SOURCE_DIR}/lib/vendor/imgui"
    "${CMAKE_SOURCE_DIR}/lib/vendor/imgui/backends"
    "${CMAKE_SOURCE_DIR}/lib/entt"
    "${CMAKE_SOURCE_DIR}/lib/vendor/glfw/include"
    "${CMAKE_SOURCE_DIR}/lib/vendor/stb_image"
    "${CMAKE_SOURCE_DIR}/lib/vendor/yaml-cpp/include"
)

# Common compile options
set(common_compile_options
    -std=c++${CMAKE_CXX_STANDARD}
    -Wall 
    -compilerandversion=${CMAKE_CXX_COMPILER_ID}-${CMAKE_CXX_COMPILER_VERSION}
    -Wmicrosoft 
    -Wno-invalid-token-paste 
    -Wno-unknown-pragmas 
    -Wno-unused-value 
    -fsyntax-only 
    "\\\"-D_MT\\\"" 
    "\\\"-D_DLL\\\"" 
    "\\\"-DWIN32\\\"" 
    "\\\"-D_WINDOWS\\\"" 
    "\\\"-DCMAKE_INTDIR=/\\\"Debug/\\\"\\\"" 
    "\\\"-D_DEBUG_FUNCTIONAL_MACHINERY\\\""   
)

# Add each include directory to the compilation options
foreach(INCLUDE_DIR ${ALL_INCLUDE_DIR})
    list(APPEND common_compile_options -I\\\"${INCLUDE_DIR}\\\")
endforeach()

# Add an extra quote to the last element
list(LENGTH ALL_INCLUDE_DIR INCLUDE_DIR_COUNT)
math(EXPR LAST_INDEX "${INCLUDE_DIR_COUNT} - 1")
list(GET ALL_INCLUDE_DIR ${LAST_INDEX} LAST_INCLUDE_DIR)
string(CONCAT LAST_INCLUDE_DIR_WITH_QUOTE ${LAST_INCLUDE_DIR} "\"")
list(POP_BACK common_compile_options)
list(APPEND common_compile_options ${LAST_INCLUDE_DIR_WITH_QUOTE})

# Convert the list to a string with spaces between the options
string(REPLACE ";" " " common_compile_options_string "${common_compile_options}")

# Filter the source files to keep only .cpp and .hpp files
list(FILTER SOURCES INCLUDE REGEX "\\.(cpp|hpp|h|c)$")

# Initialize compile_commands as an empty JSON array
set(compile_commands "[")

# Create a JSON entry for each source file
foreach(SOURCE_FILE ${SOURCES})
    string(APPEND compile_commands
        "    {\n"
        "        \"directory\": \"${CMAKE_CURRENT_BINARY_DIR}\",\n"
        "        \"command\": \"\\\"${CMAKE_CXX_COMPILER}\\\" -x c++ \\\"${SOURCE_FILE}\\\""
    )

    foreach(OPTION ${common_compile_options})
        string(APPEND compile_commands " ${OPTION}") 
    endforeach()

    string(APPEND compile_commands
        ",\n"
        "        \"file\": \"${SOURCE_FILE}\"\n"
        "    },\n"
    )
endforeach()

# Remove the final comma and close the JSON array
string(REGEX REPLACE ",\n$" "" compile_commands "${compile_commands}")
string(APPEND compile_commands "\n]")

# Write the JSON array to compile_commands.json
file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/compile_commands.json "${compile_commands}")

# Add a custom target to generate compile_commands.json
add_custom_target(generate_compile_commands
    DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/compile_commands.json
    COMMENT "Generating compile_commands.json"
)
