# SPDX-FileCopyrightText: 2024 Chris Rizzitello <sithlord48@gmail.com>
# SPDX-License-Identifier: MIT

create_library(
    TARGET io
    TYPE STATIC
    SKIP_ALIAS_HEADERS
    HEADERS
        filesystem.h
        IStream.h
        StreamBuffer.h
        StreamFilter.h
        XIO.h
    SOURCES
        filesystem.cpp
        StreamBuffer.cpp
        StreamFilter.cpp
        XIO.cpp
    PUBLIC_LINKS
        cisp::base
)
set(CMAKE_INCLUDE_CURRENT_DIR ON)
