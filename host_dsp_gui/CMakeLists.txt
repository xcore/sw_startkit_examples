cmake_minimum_required (VERSION 2.8) 
project (host_dsp_gui)
enable_testing()

set (CMAKE_PREFIX_PATH "/Users/andy/Qt5.2.1/5.2.1/clang_64")
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY bin)

include_directories( src )

file(GLOB_RECURSE GUI_INCLUDES "src/*.h" )

file(GLOB_RECURSE GUI_SRC "src/*.cpp" )

file(GLOB_RECURSE GUI_UI "src/*.ui" )

# Find includes in corresponding build directories
set(CMAKE_INCLUDE_CURRENT_DIR ON)
# Instruct CMake to run moc automatically when needed.
set(CMAKE_AUTOMOC ON)

# Find the QtWidgets library
find_package(Qt5Widgets)

qt5_wrap_ui(host_dsp_gui_FORMS_HEADERS ${GUI_UI})

message(STATUS ${host_dsp_gui_FORMS_HEADERS})
message(STATUS ${GUI_SRC})
message(STATUS ${GUI_INCLUDES})

add_executable (host_dsp_gui ${GUI_INCLUDES} ${GUI_SRC} ${host_dsp_gui_FORMS_HEADERS})

# Use the Widgets module from Qt 5.
qt5_use_modules(host_dsp_gui Widgets)