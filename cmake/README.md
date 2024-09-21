# About this Directory
This is the `cmake` directory it contains, cmake helpers and other items used by cmake.

  - `projectHelpers.cmake` - Contains cmake
  - the `_template` subdirectory

## Before using in your project
 Edit the needed files in the `_template` directory

## Functions and Macros in projectHelpers.cmake

 - `create_library` - Used to create library Targets
 - `MAKE_DEMO` - Used to create Demo applications
 - `MAKE_TEST` - Used to crate Unit tests.
 - `git_version_from_tag` - Used to make generate project version information from semantic versioned git tags.
 - `sbom_generate` - Begins the process of sbom generation
 - `sbom_add` - Add New `TARGET` or `PACKAGE` to the sbom report
 - `sbom_finalize` - Finalize the sbom creation process
