# SPDX-FileCopyrightText: 2023 - 2024 Chris Rizzitello <sithlord48@gmail.com>
# SPDX-License-Identifier: MIT

# Other Items are Based upon https://github.com/sithlord48/ff7tk
# Modified to more fit a project template.

#Contains Various Macros to be included
#####~~~~~~~~~~~~~~~~~~~~~CREATE_LIBRARY~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
## Creates and install's components
function(create_library)
    set(options
        EXCLUDE_FROM_ALL #If TRUE, Target is excluded from the all target
        FRAMEWORK # If TRUE, Makes a FRAMEWORK on MacOS
        SKIP_ALIAS # If TRUE, Does not Create Alias library with the library
        SKIP_ALIAS_HEADERS # if TRUE, Alias headers will not be created
    )
    set(oneValueArgs
        TARGET # Name of the new Target
        TYPE # Library Type [SHARED, STATIC] When not set uses the Value of ${BUILD_SHARED_LIBS}
        ALIAS # Alias Override, If not set ${CMAKE_PROJECT_NAME}::TARGET will be used
        RC_TEMPLATE # Override the rc template that will be embedded on win32 [_template/libTemplate.rc.in] used as default
        RPATH #Override Install Rpath on linux/mac, if not set will use ${INSTALL_RPATH_STRING} if set otherwise rpath will untouched
        INSTALL_INCLUDEDIR #Path to install the headers into under the ${CMAKE_INSTALL_INCLUDEDIR} default[${CMAKE_PROJECT_NAME}/TARGET]
        COMPATIBILITY # Should be [AnyNewerVersion|SameMajorVersion|SameMinorVersion|ExactVersion] ${CMAKE_PROJECT_COMPATIBILITY} if that is not set will fallback to ExactVersion
    )

    set(multiValueArgs
        SOURCES  # SOURCE FILES FOR THE NEW LIBRARY May Include UI / QRC files
        HEADERS  # HEADERS FOR THE NEW LIBRARY
        PUBLIC_LINKS # Libraries to link publicly
        PRIVATE_LINKS # Libraries to link privately
    )
    cmake_parse_arguments(m "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    ## Sanity Checks
    if(m_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "create_library, Unknown arguments: ${m_UNPARSED_ARGUMENTS}")
    endif()

    if("${m_TARGET}" STREQUAL "")
        message(FATAL_ERROR "create_library, No Target Defined")
    endif()

    if("${m_INSTALL_INCLUDEDIR}" STREQUAL "")
        set(m_INSTALL_INCLUDEDIR "${CMAKE_PROJECT_NAME}/${m_TARGET}")
    endif()

    if("${m_COMPATIBILITY}" STREQUAL "")
        if(NOT "${PROJECT_COMPATIBILITY}" STREQUAL "")
            set(m_COMPATIBILITY ${PROJECT_COMPATIBILITY})
        else()
            set(m_COMPATIBILITY "ExactVersion")
        endif()
    endif()

    if(${m_EXCLUDE_FROM_ALL})
        set(EXCLUDE_FROM_ALL EXCLUDE_FROM_ALL)
    endif()

    add_library(${m_TARGET} ${m_TYPE} ${EXCLUDE_FROM_ALL} ${m_SOURCES} ${m_HEADERS})

    if(NOT m_SKIP_ALIAS)
        if ("${m_ALIAS}" STREQUAL "")
            set(m_ALIAS "${CMAKE_PROJECT_NAME}::${m_TARGET}")
        endif()
        add_library(${m_ALIAS} ALIAS ${m_TARGET})
    endif()

    if(NOT "${m_TYPE}" STREQUAL "STATIC")
        #Generate Export Header
        generate_export_header(${m_TARGET})
        string(TOLOWER ${m_TARGET} m_exportTarget)
        string(APPEND m_exportTarget "_export.h")
        list(FIND "${m_HEADERS}" "${CMAKE_CURRENT_BINARY_DIR}/${m_exportTarget}" _export_included)
        if(${_export_included} LESS 0)
            list(APPEND ${m_HEADERS} ${CMAKE_CURRENT_BINARY_DIR}/${m_exportTarget})
        endif()
        target_sources(${m_TARGET} PRIVATE "${CMAKE_CURRENT_BINARY_DIR}/${m_exportTarget}")
    endif()

    #Embed rc file with Version info
    if(WIN32)
        if ("${m_RC_TEMPLATE}" STREQUAL "")
            set(m_RC_TEMPLATE "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/_template/libTemplate.rc.in")
        endif()
        configure_file(${m_RC_TEMPLATE} ${CMAKE_CURRENT_BINARY_DIR}/${m_TARGET}.rc @ONLY)
        target_sources(${m_TARGET} PRIVATE ${CMAKE_CURRENT_BINARY_DIR}/${m_TARGET}.rc)
    endif()

    #Alias Headers
    if(NOT m_SKIP_ALIAS_HEADERS)
        foreach ( HEADER ${m_HEADERS})
            if(${HEADER} MATCHES "^/" OR ${HEADER} MATCHES "^[A-Za-z]:")
                string(FIND ${HEADER} "/" lastSlash REVERSE)
                string(SUBSTRING ${HEADER} 0 ${lastSlash} RMSTRING)
                string(REPLACE "${RMSTRING}/" "" HEADER ${HEADER})
            endif()
            set(fileContent "#pragma once\n#include<${HEADER}>\n")
            string(REPLACE ".h" "" HEADER ${HEADER})
            file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/${HEADER} ${fileContent})
            list(APPEND ALIASHEADERS ${CMAKE_CURRENT_BINARY_DIR}/${HEADER})
        endforeach()
    endif()

    #Rpath
    if("${m_RPATH}" STREQUAL "")
        set(m_RPATH "${INSTALL_RPATH_STRING}")
    endif()
    if(APPLE)
        if(NOT "${m_RPATH}" STREQUAL "")
            set_target_properties(${m_TARGET} PROPERTIES BUILD_WITH_INSTALL_RPATH TRUE)
        endif()
        if(${m_FRAMEWORK})
            target_include_directories(${m_TARGET} PUBLIC  $<BUILD_INTERFACE:$<TARGET_BUNDLE_CONTENT_DIR:${m_TARGET}>/Headers>)
        endif()
    endif()

    if(UNIX AND NOT "${m_RPATH}" STREQUAL "")
        set_target_properties(${m_TARGET} PROPERTIES INSTALL_RPATH ${INSTALL_RPATH_STRING})
    endif()

    # Properties
    set_target_properties(${m_TARGET} PROPERTIES
        FRAMEWORK ${m_FRAMEWORK}
        FRAMEWORK_VERSION ${PROJECT_VERSION_MAJOR}
        MACOSX_FRAMEWORK_IDENTIFIER com.${PROJECTS_SUPPLIER}.${m_TARGET}
        VERSION "${PROJECT_VERSION}"
        SOVERSION "${PROJECT_VERSION_MAJOR}"
        PUBLIC_HEADER "${m_HEADERS}"
        MAP_IMPORTED_CONFIG_DEBUG RELWITHDEBINFO
        MAP_IMPORTED_CONFIG_RELEASE RELWITHDEBINFO
        MAP_IMPORTED_CONFIG_RELWITHDEBINFO RELWITHDEBINFO
        MAP_IMPORTED_CONFIG_MINSIZEREL RELWITHDEBINFO
    )

    target_include_directories(${m_TARGET} PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
        $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>
        $<INSTALL_INTERFACE:include/${m_INSTALL_INCLUDEDIR}>
    )

    if (NOT ${m_PUBLIC_LINKS} STREQUAL "")
        target_link_libraries (${m_TARGET} PUBLIC ${m_PUBLIC_LINKS} )
    endif()

    if (NOT ${m_PRIVATE_LINKS} STREQUAL "")
        target_link_libraries (${m_TARGET} PRIVATE ${m_PRIVATE_LINKS})
    endif()

    install(TARGETS ${m_TARGET}
        EXPORT ${CMAKE_PROJECT_NAME}Targets
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
            COMPONENT ${CMAKE_PROJECT_NAME}_libraries
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
            COMPONENT ${CMAKE_PROJECT_NAME}_libraries
            NAMELINK_COMPONENT ${CMAKE_PROJECT_NAME}_headers
        FRAMEWORK DESTINATION ${CMAKE_INSTALL_LIBDIR}
            COMPONENT ${CMAKE_PROJECT_NAME}_libraries
        ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
            COMPONENT ${CMAKE_PROJECT_NAME}_headers
        PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${m_INSTALL_INCLUDEDIR}
            COMPONENT ${CMAKE_PROJECT_NAME}_headers
    )

    if(NOT m_SKIP_ALIAS_HEADERS)
        install (
            FILES ${ALIASHEADERS}
            DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${m_INSTALL_INCLUDEDIR}
            COMPONENT ${CMAKE_PROJECT_NAME}_headers
        )
    endif()

    #Generate Cmake Files and install
    write_basic_package_version_file(
        ${CMAKE_CURRENT_BINARY_DIR}/${m_TARGET}ConfigVersion.cmake
        VERSION ${PROJECT_VERSION}
        COMPATIBILITY ${m_COMPATIBILITY}
    )
    if(EXISTS ${CMAKE_CURRENT_BINARY_DIR}/${m_TARGET}Config.cmake.in)
        set(CONFIG_IN ${CMAKE_CURRENT_BINARY_DIR}/${m_TARGET}Config.cmake.in)
    else()
        set(CONFIG_IN ${CMAKE_CURRENT_SOURCE_DIR}/${m_TARGET}Config.cmake.in)
    endif()
    configure_package_config_file(
        ${CONFIG_IN}
        ${CMAKE_CURRENT_BINARY_DIR}/${m_TARGET}Config.cmake
        INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${CMAKE_PROJECT_NAME}
    )

    #setup the debug files and deployment
    if(UNIX)
        if(NOT APPLE)
            add_custom_command(TARGET ${m_TARGET} POST_BUILD
                COMMAND ${CMAKE_OBJCOPY} --only-keep-debug $<TARGET_FILE:${m_TARGET}> $<TARGET_FILE:${m_TARGET}>.dbg
                COMMAND ${CMAKE_STRIP} --strip-debug $<TARGET_FILE:${m_TARGET}>
                COMMAND ${CMAKE_OBJCOPY} --add-gnu-debuglink=$<TARGET_FILE:${m_TARGET}>.dbg $<TARGET_FILE:${m_TARGET}>
            )
        else()
            add_custom_command(TARGET ${m_TARGET} POST_BUILD
                COMMAND dsymutil -f $<TARGET_FILE:${m_TARGET}> -o $<TARGET_FILE:${m_TARGET}>.dbg
            )
        endif()
        install(FILES $<TARGET_FILE:${m_TARGET}>.dbg
            DESTINATION ${CMAKE_INSTALL_LIBDIR}/debug
            COMPONENT ${CMAKE_PROJECT_NAME}_debug
        )
    elseif(WIN32)
        install(FILES ${CMAKE_CURRENT_BINARY_DIR}/$<TARGET_FILE_BASE_NAME:${m_TARGET}>.pdb
            DESTINATION ${CMAKE_INSTALL_BINDIR}
            COMPONENT ${CMAKE_PROJECT_NAME}_debug
        )
    endif()

    install(
        FILES
          ${CMAKE_CURRENT_BINARY_DIR}/${m_TARGET}Config.cmake
          ${CMAKE_CURRENT_BINARY_DIR}/${m_TARGET}ConfigVersion.cmake
        DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${CMAKE_PROJECT_NAME}
        COMPONENT ${CMAKE_PROJECT_NAME}_headers
    )

    install(
        EXPORT ${CMAKE_PROJECT_NAME}Targets
        NAMESPACE ${CMAKE_PROJECT_NAME}::
        DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${CMAKE_PROJECT_NAME}
        COMPONENT ${CMAKE_PROJECT_NAME}_headers
    )

    export(EXPORT ${CMAKE_PROJECT_NAME}Targets FILE ${CMAKE_CURRENT_BINARY_DIR}/${m_TARGET}Targets.cmake)
    set_property(GLOBAL APPEND PROPERTY ${CMAKE_PROJECT_NAME}_targets ${m_TARGET})
endfunction()

#####~~~~~~~~~~~~~~~~~~~~~MAKE_TEST~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
## TODO PORT TO USE GTEST
# MAKE_TEST - Set up a unit test
# NAME - Name of the new Test
# FILE - cpp File for the Test
macro (MAKE_TEST NAME FILE)
    get_filename_component(curDir ${CMAKE_CURRENT_SOURCE_DIR} NAME)
    set(DEP_LIB ${CMAKE_PROJECT_NAME})
    if( NOT ${curDir} MATCHES core)
        string(SUBSTRING ${curDir} 0 1 FIRST_LETTER)
        string(TOUPPER ${FIRST_LETTER} FIRST_LETTER)
        string(REGEX REPLACE "^.(.*)" "${FIRST_LETTER}\\1" curDir_UPPER "${curDir}")
        string(APPEND DEP_LIB "${curDir_UPPER}")
    endif()
    add_executable( ${NAME} ${FILE} )
    target_link_libraries( ${NAME} ${DEP_LIB} Qt::Test)
    add_test(NAME ${NAME} COMMAND $<TARGET_FILE:${NAME}> WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/../../src/${curDir}")
    set_tests_properties(${NAME} PROPERTIES DEPENDS ${DEP_LIB})
    set_property(GLOBAL APPEND PROPERTY ${CMAKE_PROJECT_NAME}_tests ${NAME})
endmacro()


####~~~~~~~~~~~~~~~~~~~~~~git_version_from_tag~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#git_version_from_tag(OUTPUT <var-name> [MAJOR <value>] [MINOR <value>] [PATCH <value>] [TWEAK <value> ])
#This Function will set the variable <var_name> to semantic version value based on the last git tag
#This Requires a tag in the format of vX.Y.Z in order to construct a proper verson
## REQUIRED ARGUMENTS
# OUTPUT <value> - The name of the variable the version will be written into
## OPTIONAL ARGUMENTS
# MAJOR <value> - the MAJOR argument sets the fallback major to use if its unable to be detected [Default: 0]
# MINOR <value> - the MINOR argument sets the fallback minor to use if its unable to be detected [Default: 0]
# PATCH <value> - the PATCH argument sets the fallback patch to use if its unable to be detected [Default: 0]
# TWEAK <value> - the TWEAK argument sets the fallback tweak to use if its unable to be detected [Default: 0]
#Optional MAJOR, MINOR, PATCH should be set when calling they will be used if git can not be found or tag can not be processed.For this reason the MAJOR, MINOR and PATCH should should be synced with semantic tag in git
#The Tweak is auto generated based on the number of commits since the last tag
function(git_version_from_tag)
    set(options)
    set(oneValueArgs
        OUTPUT # The Variable to write into
        MAJOR # Fallback Version Major
        MINOR # Fallback Version Minor
        PATCH # Fallback Version Patch
        TWEAK # Fallback Version Patch
    )
    set(multiValueArgs)
    cmake_parse_arguments(m "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if(m_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "Unknown arguments: ${m_UNPARSED_ARGUMENTS}")
    endif()

    if("${m_OUTPUT}" STREQUAL "")
        message(FATAL_ERROR "No OUTPUT set")
    endif()
    if(NOT m_MAJOR)
        set(m_MAJOR 0)
    endif()

    if(NOT m_MINOR)
        set(m_MINOR 0)
    endif()

    if(NOT m_PATCH)
        set(m_PATCH 0)
    endif()

    if(NOT m_TWEAK)
        set(m_TWEAK 0)
    endif()

    set(VERSION_MAJOR ${m_MAJOR})
    set(VERSION_MINOR ${m_MINOR})
    set(VERSION_PATCH ${m_PATCH})
    set(VERSION_TWEAK ${m_TWEAK})

    if(EXISTS "${CMAKE_SOURCE_DIR}/.git")
        find_package(Git)
        if(GIT_FOUND)
        execute_process(
            COMMAND ${GIT_EXECUTABLE} describe --long --match v* --always
            WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
            OUTPUT_VARIABLE GITREV
            ERROR_QUIET
            OUTPUT_STRIP_TRAILING_WHITESPACE)
            string(FIND ${GITREV} "v" isRev)
            if(NOT isRev EQUAL -1)
                string(REGEX MATCH [0-9]+ MAJOR ${GITREV})
                string(REGEX MATCH \\.[0-9]+ MINOR ${GITREV})
                string(REPLACE "." "" MINOR "${MINOR}")
                string(REGEX MATCH [0-9]+\- PATCH ${GITREV})
                string(REPLACE "-" "" PATCH "${PATCH}")
                string(REGEX MATCH \-[0-9]+\- TWEAK ${GITREV})
                string(REPLACE "-" "" TWEAK "${TWEAK}")
                set(VERSION_MAJOR ${MAJOR})
                set(VERSION_MINOR ${MINOR})
                set(VERSION_PATCH ${PATCH})
                set(VERSION_TWEAK ${TWEAK})
            elseif(NOT ${GITREV} STREQUAL "")
                message(STATUS "Unable to process tag")
            endif()
        endif()
    endif()
    set(${m_OUTPUT} "${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH}.${VERSION_TWEAK}" PARENT_SCOPE)
endfunction()
