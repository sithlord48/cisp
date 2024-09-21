# About this Directory
This is the `src` dir its contains

  - `CMakeLists.txt`
  - a `core` directory
  - Additional Sub directories for other libraries

## The Core Library
 in core a library named CMAKE_PROJECT_NAMEInfo will be created it will provide version info and location of the i18n files.

### Adding A New Library
 To Add a new library Follow these steps

  1. Decide upon a libaryName (i.e Foo)
  2. In the src directory's `CMakeLists.txt`
      1. Add a new option to the top of the file named with your lib name. Example `option(FOO "Build the Foo Library" ON)`
      2. Towards the bottom add a like that will include your sub dir if the option is on example: `if (FOO) add_subdirectory(foo) endif()`
      3. Document This option in `docs/build.md`
  3. Make a new subdirectory
  4. In the new directory create a `CMakeLists.txt`
     1. Use the core folder for an example
  5. In the new directory create a `FooConfig.cmake.in` Use your library name in place of `Foo`. This file will be used when an applicton or lib looks for your library. Below can be used as a starting point for this file
  ```
    @PACKAGE_INIT@
    include(CMakeFindDependencyMacro)
    #Do this for all other depends / components
    find_dependency(Qt6 ${REQUIRED_QT_VERSION} COMPONENTS Core)
    include("${CMAKE_CURRENT_LIST_DIR}/${CMAKE_PROJECT_NAME}Targets.cmake")
  ```
  6. In your class be sure to
     1. Include the export header `#include <foo_export.h>` This file is generated at build time and will be lowercase the targetname
     2. Use the FOO_EXPORT macro to expose your class ex. `class FOO_EXPORT className ...`

#### Linking your New library
 Your library will be made with an alias of `myProject::foo` foo being the name you have picked

#### Using the create_library Macro
To Create a library use the create_library macro

usage: `create_library(TARGET <name> ...)
Inputs:
   - Options
      - EXCLUDE_FROM_ALL #If TRUE, Target is excluded from the all target
      - FRAMEWORK # If TRUE, Makes a FRAMEWORK on MacOS
      - SKIP_ALIAS # If TRUE, Does not Create Alias library with the library
      - SKIP_ALIAS_HEADERS # if TRUE, Alias headers will not be created
      - SKIP_SBOM # if TRUE, The target will not be added to the generated sbom
      - QML_MODULE # If TRUE, Makes a Qml Module
   - Single Value Arguments
      -  TARGET Required, Name of the new Target
      -  TYPE   Library Type [SHARED, STATIC] When not set uses the Value of ${BUILD_SHARED_LIBS}
      -  RESOURCE_PREFIX  Qml Import Prefix if undefined will use "/qt/qml"
      -  URI URI To be used for module import
      -  ALIAS Alias Override, If not set ${CMAKE_PROJECT_NAME}::TARGET will be used
      -  RC_TEMPLATE Override the rc template that will be embedded on win32 [_template/libTemplate.rc.in] used as default
      -  RPATH Override Install Rpath on linux/mac, if not set will use ${INSTALL_RPATH_STRING} if set otherwise rpath will not be changed
      -  INSTALL_INCLUDEDIR #Path to install the headers into under the ${CMAKE_INSTALL_INCLUDEDIR} default[$-{CMAKE_PROJECT_NAME}/TARGET]
      -  COMPATIBILITY  Should be [AnyNewerVersion|SameMajorVersion|SameMinorVersion|ExactVersion] ${CMAKE_PROJECT_COMPATIBILITY} if that is not set will fallback to ExactVersion
   - List Value Arguments
      -  SOURCES  # SOURCE FILES FOR THE NEW LIBRARY May Include UI / QRC files
      -  HEADERS  # HEADERS FOR THE NEW LIBRARY
      -  QMLFILES # Qml Files used for qml plugins only
      -  QMLDEPENDS # Qml Modules the new Qml Module will Depend on
      -  PUBLIC_LINKS # Libraries to link publicly
      -  PRIVATE_LINKS # Libraries to link privately
#### What is created with the function

  1. A Libary
     - Depending on the compiler the library may be prefixed with "lib"
     - An Alias `${CMAKE_PROJECT_NAME}::${LIB_TARGET}` use this when linking to the library
     - On Windows this libary will have info embedded using the `_templates/libTemplate.rc.in`
     - The library will have it rpath modified based on the INSTALL_RPATH_STRING (set in the main cmakelist)
     - The Library will be publicly linked to the libraries in `PUBLIC_LINKS`
     - The Library will be privately linked to the libraries in `PRIVATE_LINKS`
     - The Library will have all the needed items for cmake to find it as a COMPONENT of the project
     - The Library is added to the list of targets for the sbom.
     - The Library will declare compatibiliy based upon its `COMPATIBILITY`

  2. Debug Info
     - dbg files are created for the librares and are installed

  3. Install Rules
     - The library will be installed to `${CMAKE_INSTALL_LIBDIR}/${CMAKE_PROJECT_NAME}`
     - Library Headers will be installed to `${CMAKE_INSTALL_INCDIR}/${CMAKE_PROJECT_NAME}/${LIB_TARGET}`
     - Alias headers are generated so you can #include with or without the .h
