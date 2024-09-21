### PROJECT TEMPLATE
# Works well for libraries with demo applications
## SET A REQUIRED CMAKE VERSION 3.21+ is required to use the features in this template
cmake_minimum_required(VERSION 3.21)

# Allow Cmake to use the cmake or env var <package>_ROOT for find_package calls for <package>
# https://cmake.org/cmake/help/latest/policy/CMP0074.html
cmake_policy(SET CMP0074 NEW)


#Used Modules that can be included before a project call has been made
include(CMakePackageConfigHelpers)
include(GenerateExportHeader)
include(${CMAKE_CURRENT_LIST_DIR}/cmake/projectHelpers.cmake)

###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ PROJECT VARS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# These values are used only before project is called

# After Calling 'project' This becomes the CMAKE_PROJECT_NAME
# The Project name will used in several places thru-out the project
# The project name should not contain spaces or characters that can not be used in file or directory names
# Used in creating a deployment paths on linux
# Used to name the Info class
# Used to generate names the i18n files and more
set(PROJECTS_NAME "cisp")
if("${PROJECTS_NAME}" STREQUAL "")
    message(FATAL_ERROR "You must set a project name")
endif()

#Keep a copy of the project name in lower and upper for later use
string(TOLOWER ${PROJECTS_NAME} PROJECT_LC_NAME)
string(TOUPPER ${PROJECTS_NAME} PROJECT_UC_NAME)

# After Calling 'project' This becomes the CMAKE_PROJECT_DESCRIPTION
# The description should contain a single line of text with a simple description of the project
set(PROJECTS_DESCRIPTION "Libaray to provide the Common Input Sharing Parts used to share input across machines.")

# This used for the 'project' call and tell cmake what languages you plan to use.
set(PROJECTS_LANGUAGES "CXX;C")

# After Calling 'project' This becomes the CMAKE_PROJECT_HOMEPAGE_URL
#The URL of the project
set(PROJECTS_HOMEPAGE_URL "https://github.com/sithlord48/cisp")
if("${PROJECTS_HOMEPAGE_URL}" STREQUAL "")
    message(FATAL_ERROR "You must set a project URL")
endif()
#Below is a macro from projectHelpers.cmake
#It will read Version info from Git Tag vM.m.p
#Should match the last semantic tag in git
# After calling 'project' this will become the CMAKE_PROJECT_VERSION
git_version_from_tag(
    OUTPUT PROJECTS_VERSION
    MAJOR 0
    MINOR 1
    PATCH 0
    TWEAK 0
)

###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ SBOM VARS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#Additional Data needed for sbom creataion

#Set to a valid SPDX License from this list https://spdx.org/licenses/
# Common Ones are MIT, LGPL-3.0-or-later
# For other non spdx use License-Ref-LICENSE
# Copy the main LICENSE into the COPYING.txt In the root of the source dir
# Blank will be filled with "NOASSERTION" OR "NONE"
set(PROJECTS_LICENSE "GPL-2.0")

#The Supplier of this packager A company or person
set(PROJECTS_SUPPLIER "sithlord48")
if("${PROJECTS_SUPPLIER}" STREQUAL "")
    message(FATAL_ERROR "You must set a project supplier")
endif()

# Projet Compatibility Default value to be used for compability of our versions
# Can be AnyNewerVersion SameMajorVersion SameMinorVersion ExactVersion
set(PROJECT_COMPATIBILITY "ExactVersion")
###~~~~~~~~~~~~~~~~~~~~~~~~~PROJECT CALL~~~~~~~~~~~~~~~~~~~~~~~~~

# Do We want to default to Shared LIBS ?
option(BUILD_SHARED_LIBS "Build using shared libraries" ON)

project(${PROJECTS_NAME}
    VERSION ${PROJECTS_VERSION}
    DESCRIPTION ${PROJECTS_DESCRIPTION}
    LANGUAGES ${PROJECTS_LANGUAGES}
    HOMEPAGE_URL ${PROJECTS_HOMEPAGE_URL}
)

#Used Modules that must be included after a project call has been made
include(GNUInstallDirs)

# Attempt to force the use of all cpu cores to build most compilers will do this by default
option(USE_ALL_CPU "Detect and use all cores to build" ON)
if(USE_ALL_CPU)
    cmake_host_system_information(RESULT N QUERY NUMBER_OF_LOGICAL_CORES)
    set(CMAKE_BUILD_PARALLEL_LEVEL ${N})
endif()

#Prevent In-sourcebuild
if(CMAKE_BINARY_DIR STREQUAL CMAKE_SOURCE_DIR)
    message(FATAL_ERROR "In source builds are not allowed; Set a build path")
endif()

# Report to the user Our basic project information
message(STATUS "Building ${CMAKE_PROJECT_NAME}: ${CMAKE_PROJECT_VERSION} Using: ${CMAKE_BUILD_PARALLEL_LEVEL} Threads")

## Setup Project C++ Standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Force Hidden by default for all compilers
set(CMAKE_CXX_VISIBILITY_PRESET hidden)
set(CMAKE_VISIBILITY_INLINES_HIDDEN YES)

# Include the current src/bin dirs when checking relative paths
set(CMAKE_INCLUDE_CURRENT_DIR ON)

#Pick a faster linker based on the compiler for linux
if (UNIX AND NOT APPLE)
    if(${CMAKE_CXX_COMPILER_ID} MATCHES Clang)
        string(REPLACE "." ";" VERSION_LIST ${CMAKE_CXX_COMPILER_VERSION})
        list(GET VERSION_LIST 0 CLANG_VERSION_MAJOR)
        find_program(LLD_PROGRAM_MATCH_VER lld-${CLANG_VERSION_MAJOR})
        find_program(LLD_PROGRAM lld)
        if (LLD_PROGRAM_MATCH_VER)
            message(STATUS "Set linker to LLD: ${LLD_PROGRAM_MATCH_VER}")
            add_link_options("-fuse-ld=lld-${CLANG_VERSION_MAJOR}")
        elseif(LLD_PROGRAM)
            message(STATUS "Set linker to LLD: ${LLD_PROGRAM}")
            add_link_options("-fuse-ld=lld")
        endif()
    elseif(${CMAKE_CXX_COMPILER_ID} MATCHES GNU)
        find_program(GNU_GOLD_PROGRAM gold)
        if (GNU_GOLD_PROGRAM)
            message(STATUS "Set linker to GNU gold")
            add_link_options("-fuse-ld=gold;LINKER:--threads,--thread-count=${CMAKE_BUILD_PARALLEL_LEVEL}")
        endif(GNU_GOLD_PROGRAM)
    endif()
endif()

# We Want to build our Library in RelWithDebInfo as a default
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE RelWithDebInfo CACHE STRING "" FORCE)
endif()

# Setup the SBOM to be generated during install.
sbom_generate(
        OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/sbom-${PROJECT_NAME}-${PROJECT_VERSION}.spdx
        LICENSE ${PROJECTS_LICENSE}
        SUPPLIER ${PROJECTS_SUPPLIER}
        SUPPLIER_URL ${CMAKE_PROJECT_HOMEPAGE_URL}
)

endif()

#For Every Dependency we must call sbom_add(PACKAGE ) with a package a version
# The package name will not always match the name of the libary may instead be the parent project name
# Check the NVD package search https://nvd.nist.gov/vuln/search
# To Be sure you have the correct name
# Qt Example
#sbom_add(PACKAGE Qt VERSION ${Qt6Core_VERSION})

### PLACE ANY PROJECT LEVEL FIND PACKAGES HERE

#~~~~~~~~~~~~~~~~~~~~~~Set the Rpath for our libs.
# Prevents the need for LD_LIBRARY path in most cases
if(UNIX)
    if(NOT APPLE)
        set(INSTALL_RPATH_STRING "\${ORIGIN}:\$ORIGIN/../lib:/lib:/usr/lib:/usr/local/lib:\$HOME/.local/lib:\$HOME/.local/usr/lib")
    else()
        set(INSTALL_RPATH_STRING "@loader_path/../Frameworks @loader_path @executable_path @executable_path/../Frameworks")
    endif()
endif()

#These properties will be used to track the targets and tests the pojects creates
define_property(GLOBAL PROPERTY ${CMAKE_PROJECT_NAME}_targets BRIEF_DOCS "Defined Non-Test Targets" FULL_DOCS "Dynamicly Generated list of Targets Tests")
define_property(GLOBAL PROPERTY ${CMAKE_PROJECT_NAME}_tests BRIEF_DOCS "Defined Tests" FULL_DOCS "Dynamicly Generated list of Defined Tests")

# Include any subdirectories
add_subdirectory(docs)
add_subdirectory(src)

option(TESTS "Run UnitTests" ON)
if(TESTS)
    ## TODO
    #add_subdirectory(unittests)
endif()

#Always add packaging last
option(PACKAGE "Allow Packaging" ON)
if(PACKAGE)
    add_subdirectory(packaging)
endif()

#Install the COPYING.TXT Files as our license
install (FILES "${CMAKE_CURRENT_SOURCE_DIR}/COPYING.TXT" DESTINATION ${CMAKE_INSTALL_DATADIR}/licenses/${CMAKE_PROJECT_NAME} RENAME LICENSE COMPONENT ${CMAKE_PROJECT_NAME}_libraries)

# uninstall target
if(NOT TARGET uninstall)
  configure_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake/_template/uninstall.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/uninstall.cmake"
    IMMEDIATE @ONLY)

  add_custom_target(uninstall
    COMMAND ${CMAKE_COMMAND} -P "${CMAKE_CURRENT_BINARY_DIR}/uninstall.cmake")
endif()

option(SBOM_LINT "Verify Generated SBOM is NTIA Compliant" OFF)
if (NOT SBOM_LINT)
    set(NO_VERIFY "NO_VERIFY")
endif()

option(SBOM_GRAPH "Create a Graph of the SBOM" OFF)
if(SBOM_GRAPH)
    set(GRAPH "GRAPH ${CMAKE_CURRENT_BINARY_DIR}/sbom-${CMAKE_PROJECT_NAME}-${CMAKE_PROJECT_VERSION}-spdx.png")
endif()

# Finalize must be called last
sbom_finalize(${NO_VERIFY} ${GRPAH})

#Install our sbom file
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/sbom-${CMAKE_PROJECT_NAME}-${CMAKE_PROJECT_VERSION}.spdx DESTINATION share/${CMAKE_PROJECT_NAME} COMPONENT ${CMAKE_PROJECT_NAME}_libraries)

#if we made a graph install the graph
if(SBOM_GRAPH)
    install(FILES ${CMAKE_CURRENT_BINARY_DIR}/sbom-${CMAKE_PROJECT_NAME}-${CMAKE_PROJECT_VERSION}-spdx.png DESTINATION share/${CMAKE_PROJECT_NAME} COMPONENT ${CMAKE_PROJECT_NAME}_libraries)
endif()
