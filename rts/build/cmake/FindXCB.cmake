# This file is part of the Spring engine (GPL v2 or later), see LICENSE.html

if (NOT WIN32)
	if (XCB_LIBRARIES)
		SET(XCB_FIND_QUIETLY TRUE)
	endif ()

	FIND_LIBRARY(XCB_LIBRARIES
		NAMES
			xcb libxcb
		PATHS
			${PROJECT_BINARY_DIR}/lib64
			${PROJECT_BINARY_DIR}/lib
			${PROJECT_SOURCE_DIR}/lib64
			${PROJECT_SOURCE_DIR}/lib
			$ENV{LD_LIBRARY_PATH}
			$ENV{LIBRARY_PATH}
			/usr/lib64
			/usr/lib
			/usr/local/lib64
			/usr/local/lib
		NO_DEFAULT_PATH
		)

	include(FindPackageHandleStandardArgs)
	FIND_PACKAGE_HANDLE_STANDARD_ARGS(XCB DEFAULT_MSG XCB_LIBRARIES)

	MARK_AS_ADVANCED(XCB_LIBRARIES)
endif ()
