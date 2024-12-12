cmake_minimum_required(VERSION 3.12.0)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_INTERPROCEDURAL_OPTIMIZATION_RELEASE TRUE)
if (CMAKE_GENERATOR MATCHES "Visual Studio")
    add_compile_options(/MP /EHsc)
endif()

set(NAME game)

set(DLL_DIR "${CMAKE_SOURCE_DIR}/!thirdParty/dlls")
set(LIB_DIR "${CMAKE_SOURCE_DIR}/!thirdParty/libs")
set(MANIFEST_DIR "${CMAKE_SOURCE_DIR}/!thirdParty/manifest")
set(LIBRAIRIES_DIR "${CMAKE_SOURCE_DIR}/!thirdParty/include")

file(GLOB DLL_LIST "${DLL_DIR}/*.dll")
file(GLOB_RECURSE MANIFEST_FILES "${MANIFEST_DIR}/*.manifest")

set(ALL_INCLUDE_DIR
    #"${LIBRAIRIES_DIR}/glfw-3.4/include"
    #"${LIBRAIRIES_DIR}/glm-1.0.1-light"
    "${LIBRAIRIES_DIR}/ThreadedLoggerForCPP-V0.5.2/libs/include/"
    "${LIBRAIRIES_DIR}"
    "include"
)

message(STATUS "using ${CMAKE_GENERATOR}")
if (CMAKE_GENERATOR STREQUAL "MinGW Makefiles")
    if (NOT MINGW_PATH) 
      message(FATAL_ERROR "MINGW_PATH not set in .env.cmake")
    endif()
    set(USE_MINGW "True")
    set(CMAKE_C_COMPILER ${MINGW_PATH}/bin/gcc.exe)
    set(CMAKE_CXX_COMPILER  ${MINGW_PATH}/bin/g++.exe)
endif()

project(${NAME} VERSION 0.23.0)

# 1. Set VULKAN_SDK_PATH in .env.cmake to target specific vulkan version
if (DEFINED VULKAN_SDK_PATH)
  set(Vulkan_INCLUDE_DIRS "${VULKAN_SDK_PATH}/Include") # 1.1 Make sure this include path is correct
  set(Vulkan_LIBRARIES "${VULKAN_SDK_PATH}/Lib/vulkan-1.lib") # 1.2 Make sure lib file is correct
  set(Vulkan_FOUND "True")
else()
  find_package(Vulkan REQUIRED) # throws error if could not find Vulkan
  message(STATUS "Found Vulkan: $ENV{VULKAN_SDK}")
endif()
if (NOT Vulkan_FOUND)
    message(FATAL_ERROR "Could not find Vulkan library!")
else()
    message(STATUS "Using vulkan lib at: ${Vulkan_LIBRARIES}")
endif()

include_directories(external)

file(GLOB ALL_LIBRARIES_DIR "${LIB_DIR}/*.lib")

file(GLOB_RECURSE SOURCES ${PROJECT_SOURCE_DIR}/src/*.cpp)

set(SOURCES_MANUAL
    "${LIBRAIRIES_DIR}/ThreadedLoggerForCPP-V0.5.2/src/LoggerThread.cpp"
)

add_executable(${PROJECT_NAME} ${SOURCES} ${SOURCES_MANUAL})

target_compile_features(${PROJECT_NAME} PUBLIC cxx_std_17)

set_property(TARGET ${PROJECT_NAME} PROPERTY VS_DEBUGGER_WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}/build")

if (WIN32)
  message(STATUS "CREATING BUILD FOR WINDOWS")

  if (USE_MINGW)
    target_include_directories(${PROJECT_NAME} PUBLIC
      ${MINGW_PATH}/include
      ${ALL_INCLUDE_DIR}
    )
    target_link_directories(${PROJECT_NAME} PUBLIC
      ${MINGW_PATH}/lib
    )
  endif()

  target_include_directories(${PROJECT_NAME} PUBLIC
    ${PROJECT_SOURCE_DIR}/src
    ${Vulkan_INCLUDE_DIRS}
    ${TINYOBJ_PATH}
    ${GLM_PATH}
    ${ALL_INCLUDE_DIR}
    )

  target_link_libraries(${PROJECT_NAME} ${ALL_LIBRARIES_DIR} ${Vulkan_LIBRARIES})
elseif (UNIX)
    message(STATUS "CREATING BUILD FOR UNIX")
    target_include_directories(${PROJECT_NAME} PUBLIC
      ${PROJECT_SOURCE_DIR}/src
      ${TINYOBJ_PATH}
    )
    target_link_libraries(${PROJECT_NAME} ${Vulkan_LIBRARIES})
endif()


# Copy DLLs after build if they don't exist already
foreach(DLL ${DLL_LIST})
    file(TO_NATIVE_PATH "${DLL}" NATIVE_DLL_PATH)
    get_filename_component(DLL_NAME "${DLL}" NAME)
    set(DESTINATION_PATH "$<TARGET_FILE_DIR:${PROJECT_NAME}>/${DLL_NAME}")
    add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "${NATIVE_DLL_PATH}"
        "${DESTINATION_PATH}"
        VERBATIM
        )
endforeach()

# Copier chaque fichier manifest dans le répertoire de build correspondant au niveau de build
foreach(MANIFEST_FILE ${MANIFEST_FILES})
    get_filename_component(MANIFEST_NAME ${MANIFEST_FILE} NAME)
    set(DESTINATION "${CMAKE_BINARY_DIR}/$<CONFIG>/${MANIFEST_NAME}")
    add_custom_command(TARGET ${PROJECT_NAME} PRE_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
        ${MANIFEST_FILE}
        ${DESTINATION}
        COMMENT "Copying ${MANIFEST_NAME} to $<CONFIG> directory"
    )
endforeach()

set(dest_dir "${CMAKE_BINARY_DIR}/$<CONFIG>/resources")


# Create a custom target to run the compile script
add_custom_target(run_compile_script
    COMMAND ${CMAKE_COMMAND} -E echo "Running shader compilation script..."
    COMMAND ${CMAKE_COMMAND} -E chdir ${CMAKE_SOURCE_DIR}/resources/shaders/ cmd /c compile.bat
    COMMENT "Compiling shaders"
)

# Ensure resources are prepared before building the main target
add_dependencies(${NAME} copy_resources)
# Copy resources (models, shaders, textures)
add_custom_target(copy_resources ALL
    COMMAND echo start copying models and shaders at && date /T && echo The current time is: %TIME%
    COMMAND ${CMAKE_COMMAND} -E make_directory ${dest_dir}/models
    COMMAND ${CMAKE_COMMAND} -E make_directory ${dest_dir}/shaders
    COMMAND ${CMAKE_COMMAND} -E make_directory ${dest_dir}/tex
    COMMAND for /R ${CMAKE_SOURCE_DIR}/resources/models %%G in (*.obj *.png *.meta *.mtl *.png.meta) do (
        ${CMAKE_COMMAND} -E copy_if_different %%G ${dest_dir}/models/%%~nxG
    )
    COMMAND for /R ${CMAKE_SOURCE_DIR}/resources/shaders %%G in (*.frag *.spv *.vert) do (
        ${CMAKE_COMMAND} -E copy_if_different %%G ${dest_dir}/shaders/%%~nxG
    )
    COMMAND for /R ${CMAKE_SOURCE_DIR}/resources/tex %%G in (*.jpg *.png) do (
      ${CMAKE_COMMAND} -E copy_if_different %%G ${dest_dir}/tex/%%~nxG
  )
    COMMAND echo Copy completed at && date /T && echo The current time is: %TIME%
    COMMAND echo Start removing files at && date /T && echo The current time is: %TIME%
    COMMAND for /R ${dest_dir}/models %%G in (*.obj *.png *.meta *.mtl *.png.meta) do @if not exist ${CMAKE_SOURCE_DIR}/resources/models/%%~nxG (
        echo Deleting %%G & del /Q %%G
    )
    COMMAND for /R ${dest_dir}/shaders %%G in (*.frag *.spv *.vert) do @if not exist ${CMAKE_SOURCE_DIR}/resources/shaders/%%~nxG (
        echo Deleting %%G & del /Q %%G
    )
    COMMAND for /R ${dest_dir}/tex %%G in (*.jpg *.png) do @if not exist ${CMAKE_SOURCE_DIR}/resources/tex/%%~nxG (
      echo Deleting %%G & del /Q %%G
  )
    COMMAND echo Remove completed at && date /T && echo The current time is: %TIME%
)

# Ensure shaders are compiled before resources are copied
add_dependencies(copy_resources run_compile_script)

add_custom_command(TARGET ${NAME} POST_BUILD
                   COMMAND ${CMAKE_COMMAND} -E echo "Post build step completed.")

include(${CMAKE_SOURCE_DIR}/GenerateCompileCommands.cmake)
