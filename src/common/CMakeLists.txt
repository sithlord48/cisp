# SPDX-FileCopyrightText: 2024 Chris Rizzitello <sithlord48@gmail.com>
# SPDX-License-Identifier: MIT

configure_file(version.h.in ${CMAKE_CURRENT_BINARY_DIR}/version.h)

create_library(
    TARGET common
    TYPE STATIC
    SKIP_ALIAS_HEADERS
    HEADERS
        ${CMAKE_CURRENT_BINARY_DIR}/version.h
        common.h

)
set(CMAKE_INCLUDE_CURRENT_DIR ON)
set_target_properties(common PROPERTIES LINKER_LANGUAGE CXX)
