# Place executables and shared libs under "build-dir/",
# instead of under "build-dir/rts/"
# This way, we have the build-dir structure more like the install-dir one,
# which makes testing spring in the builddir easier, eg. like this:
# cd build-dir
# SPRING_DATADIR=$(pwd) ./spring
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_LIBRARY_OUTPUT_DIRECTORY}")


### Assemble libraries
find_package(SDL2 REQUIRED)
set(engineIncludes ${SDL2_INCLUDE_DIR})
set(engineLibraries ${SDL2_LIBRARY})
if("${SDL2_VERSION_STRING}" VERSION_LESS "2")
	message(FATAL_ERROR "Found SDL v${SDL2_VERSION_STRING} while 2 is required!")
endif ()


set(OpenGL_GL_PREFERENCE LEGACY)
find_package_static(OpenGL REQUIRED)
find_package_static(GLEW 1.5.1 REQUIRED)
list(APPEND engineLibraries ${OPENGL_gl_LIBRARY} ${OPENGL_glu_LIBRARY} ${GLEW_LIBRARIES})
list(APPEND engineIncludes ${GLEW_INCLUDE_DIR})

find_package_static(FONTCONFIG)
if    (FONTCONFIG_FOUND)
	list(APPEND engineIncludes ${FONTCONFIG_INCLUDE_DIR})
	if    (NOT EXISTS "${FONTCONFIG_INCLUDE_DIR}/fontconfig/fontconfig.h")
		message(FATAL_ERROR "FontConfig was found and will be used, but headers are missing!")
	endif ()
	list(APPEND engineLibraries ${FONTCONFIG_LIBRARIES})
	add_definitions(-DUSE_FONTCONFIG)
	if    (PREFER_STATIC_LIBS)
		prefer_static_libs()
		find_library(EXPAT_LIBRARY expat)
		unprefer_static_libs()
		list(APPEND engineLibraries ${EXPAT_LIBRARY})
	endif ()
endif ()

find_freetype_hack() # hack to find different named freetype.dll
find_package_static(Freetype REQUIRED)
foreach(f ${FREETYPE_INCLUDE_DIRS})
	list(APPEND engineIncludes ${f})
endforeach(f)
if    (NOT EXISTS "${FREETYPE_INCLUDE_DIR_ft2build}/ft2build.h")
	message(FATAL_ERROR "FreeType 2 was found and will be used, but (at least some) headers are missing (ft2build.h)!")
endif ()
list(APPEND engineLibraries ${FREETYPE_LIBRARY})

if    (PREFER_STATIC_LIBS)
	# dependencies of FreeType
	find_package_static(BZip2 REQUIRED)
	list(APPEND engineLibraries ${BZIP2_LIBRARIES})
endif ()

if    (UNIX)
	find_package(X11 REQUIRED)
	list(APPEND engineLibraries ${X11_Xcursor_LIB} ${X11_X11_LIB})
endif ()

if (APPLE)
	find_library(COREFOUNDATION_LIBRARY Foundation)
	list(APPEND engineLibraries ${COREFOUNDATION_LIBRARY})
endif ()

list(APPEND engineLibraries ${sound-impl})
list(APPEND engineLibraries engineSystemNet)
list(APPEND engineLibraries ${engineCommonLibraries})
list(APPEND engineLibraries engineaGui)
list(APPEND engineLibraries ${SPRING_SIM_LIBRARIES})
list(APPEND engineLibraries engineSim)
list(APPEND engineLibraries pr-downloader_static)

### Assemble external incude dirs
list(APPEND engineIncludes ${OPENAL_INCLUDE_DIR})
list(APPEND engineIncludes ${ENGINE_SRC_ROOT_DIR}/lib/asio/include)
list(APPEND engineIncludes ${ENGINE_SRC_ROOT_DIR}/lib/slimsig/include)

include_directories(${engineIncludes})

### Build the executable
add_executable(engine-opengl4 ${EXE_FLAGS} ${engineSources} ${ENGINE_ICON} ${engineHeaders})
target_link_libraries(engine-opengl4 ${engineLibraries})


### Install the executable
install(TARGETS engine-opengl4 DESTINATION ${BINDIR})

create_engine_build_and_install_target(opengl4)
