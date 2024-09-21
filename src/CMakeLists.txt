#TODO add more optional stuff.

if(FRAMEWORKS AND APPLE)
    set(BUILD_FRAMEWORKS TRUE)
else()
    set(BUILD_FRAMEWORKS FALSE)
endif()

add_subdirectory(core)

install(
    EXPORT
        ${CMAKE_PROJECT_NAME}Targets
    DESTINATION
        ${CMAKE_INSTALL_LIBDIR}/cmake/${CMAKE_PROJECT_NAME}
    FILE
        ${CMAKE_PROJECT_NAME}Targets.cmake
    NAMESPACE
        ${CMAKE_PROJECT_NAME}::
    COMPONENT ${CMAKE_PROJECT_NAME}_headers
)
