# SPDX-FileCopyrightText: 2024 Chris Rizzitello <sithlord48@gmail.com>
# SPDX-License-Identifier: MIT

#TODO add more optional stuff.

if(FRAMEWORKS AND APPLE)
    set(BUILD_FRAMEWORKS TRUE)
else()
    set(BUILD_FRAMEWORKS FALSE)
endif()

add_subdirectory(base)
add_subdirectory(common)
add_subdirectory(io)

install(
    EXPORT cispTargets
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/cisp
    FILE cispTargets.cmake
    NAMESPACE cisp::
    COMPONENT cisp_headers
)
