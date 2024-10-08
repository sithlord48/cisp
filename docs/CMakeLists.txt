# SPDX-FileCopyrightText: 2023 Chris Rizzitello <sithlord48@gmail.com>
# SPDX-License-Identifier: MIT

## Generate Documentation

find_package(Doxygen)
option(DOCS "Build and Install Documents" ${DOXYGEN_FOUND})

if(DOCS)
    set(DOXYGEN_EXTRACT_ALL YES)
    set(DOXYGEN_STRIP_FROM_PATH ${CMAKE_SOURCE_DIR})
    set(DOXYGEN_USE_MDFILE_AS_MAINPAGE mainpage.md)
    set(DOXYGEN_QUIET YES)

    doxygen_add_docs(
        docs
        ${CMAKE_SOURCE_DIR}/docs
        ${CMAKE_SOURCE_DIR}/src
        COMMENT "Generating Documentation"
        ALL
    )

    #This is only to show files used by the documentation
    #within the project tree
    target_sources(docs PRIVATE
        build.md
        mainpage.md
    )

    install (DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/html" DESTINATION ${CMAKE_INSTALL_DOCDIR} COMPONENT ${CMAKE_PROJECT_NAME}_docs)
elseif(NOT DOXYGEN_FOUND)
    message(STATUS:"Doxygen Not Found; Documentation will not be built")
endif()
