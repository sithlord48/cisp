# Building cisp

To build CISP you will a minimum of:
    - [cmake] 3.21+


A Default Build of CISP will build:
     - A Required Core Library
     - All Additional Libraries
     - Headers for the libraries so you can link to them
     - Required CMake parts to find it post install.
     - Documentation if [doxygen] was found on your system
     - Unit Test that will be run as part of the build process.

## Configuration
CISP Supports Several Build options
Build Options:
         Option          |            Description                  |   Default Value    | Addtional Requirments |
:-----------------------:|:---------------------------------------:|:------------------:|:---------------------:|
CMAKE_BUILD_TYPE         | Type of Build that is produced          | ReleaseWithDebInfo | |
BUILD_SHARED_LIBS        | Sets if libs default to shared          | ON                 | |
DOCS                     | Build Documentation                     | ON                 | [doxygen] |
PACKAGE                  | Enable Package target                   | ON                 | |
FRAMEWORKS               | Build as Frameworks (EXPERMANTAL)       | OFF                | Mac Os Only |
TESTS                    | Build and run unit tests                | ON                 | |
SPLITPACKAGES            | Create Split Packages                   | OFF                | |

Example cmake configuration.
`cmake -S. -Bbuild -DCMAKE_INSTALL_PREFIX=<INSTALLPREFIX>`

## Build
After Configuring you Should be able to run make to build all targets.

`cmake --build build`

## Install
 To test installation run `DESTDIR=<installDIR> cmake --install build` to install into `<installDir>/<CMAKE_INSTALL_PREFIX>` <br>
 Running `cmake --install build` will install to the `CMAKE_INSTALL_PREFIX`

## Making CISP packages
 CISP can generate several packages using cpack
 To generate packages build the `package` or `package_source` target
 example ` cmake --build build --target package package_source` would generate both package and package source packages.
 Installing the Qt Installer Framework will allow CISP to create a QtIFW installer.
 
# Using CISP in your project

After installing you can use in your cmake project by simply adding 
`find_project(cisp)` link with `cisp::cisp`

## CISP version info
 CISP Versions are based on its git info. Failing this the project version is updated on every release.
 include the file cisp.h and use the function(s)
  - cisp::version() To get version info in to form of Major.minor.patch.tweak
   -- If patch or rev are empty they are excluded from the version number
   -- tweak is Number of commits since the last tag release

### CISP version compatibility
 CISP versions with the same major and minor version are compatible. Building your project with an incompatible version can lead to API issues for this reason its HIGHLY recommend any CI jobs use a Release or specific COMMIT HASH when pulling ff7tk.

## Deploying CISP with your app
 When using CISP your project needs to ship the libraries cisp needs to run its recommended to run windepoyqt / macdeployqt on the CISP libs being used when you pack your application to be sure to get all the libs needed are deployed.
 
### Item Depends
LIST OF YOUR LIBRARIES WITH THEIR DEPENDS 
  - exampleLibrary
    -- QtCore, QtXml, QtSvg, Svg Image plugin, Core5Compat
  

[doxygen]:http://www.stack.nl/~dimitri/doxygen/
[cmake]:https://cmake.org/
