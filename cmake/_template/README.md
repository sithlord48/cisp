# About this Directory
This is the `_templates` directory it contains templates that are used when creating various items for the project.

#### Project wide:
  - `sbom-document.in` - Template to be used for generating the sbom file
  - `uninstall.cmake.in` - Creates a `make uninstall` step for testing

#### Library Specific:
Fallback items used with the libary does not provide its own copy within its source directory.

  - `libTemplate.rc.in` - File "properties" data for windows


## Before using in your project
  - Edit `demoTemplate.rc.in` and place the copyright info in the file
  - Edit `libTemplate.rc.in` and place the copyright info in the file
