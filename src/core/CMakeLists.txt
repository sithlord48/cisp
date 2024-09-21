# SPDX-FileCopyrightText: Chris Rizzitello <sithlord48@gmail.com>
# SPDX-License-Identifier: MIT

find_package(Qt6 ${REQUIRED_QT_VERSION} REQUIRED NO_MODULE COMPONENTS
    Core
)

file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_PROJECT_NAME}Config.cmake.in
    "
    \@PACKAGE_INIT\@
    include(CMakeFindDependencyMacro)
    #Do this for other depends / components
    include(\"\${CMAKE_CURRENT_LIST_DIR}/${CMAKE_PROJECT_NAME}Targets.cmake\")
    "
)

configure_file(Info.h.in ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_PROJECT_NAME}Info.h @ONLY)

create_library(
    TARGET ${CMAKE_PROJECT_NAME}
    INSTALL_INCLUDEDIR ${CMAKE_PROJECT_NAME}
    HEADERS ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_PROJECT_NAME}Info.h
)
