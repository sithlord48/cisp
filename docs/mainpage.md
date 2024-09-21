
CISP Documentation Main Page
===
Info about the project can go here
The License, authors etc..


## Using the Installers
### PROJECTS_NAME installer
You can use the `PROJECTS_NAME <version>-installer` to install PROJECTS_NAME, when using them its recommended to install to one of following paths.
 - Windows:
   - `C:\Program Files\PROJECTS_NAME`
   - `C:\Program Files\PROJECTS_NAME-<VERSION#>`
 - Mac OS
   - `~/Applications/PROJECTS_NAME`
   - `~/Applications/PROJECTS_NAME-<VERSION#>`
   - `/Applications/PROJECTS_NAME`
   - `/Applications/PROJECTS_NAME-<VERSION#>`
 - Linux
   - `/opt/PROJECTS_NAME`
   - `/opt/PROJECTS_NAME-VERSION`
   - `~/.local/opt/PROJECTS_NAME`
   - `~/.local/opt/PROJECTS_NAME-<VERSION#>`

### Adding PROJECTS_NAME to the path
  Depending on your os and how you install you may want to also add the install path explicitly to your "PATH"

  - Windows
    - [Windows_Add to_path]
    - Developers may also want to add `<install_path>/lib/cmake/PROJECTS_NAME` to the path so cmake can easily find PROJECTS_NAME.

  - Linux / Mac os
    - [Linux_Add_to_path]
    - Make a new file /etc/ld.so.d/PROJECTS_NAME that contains the path to the PROJECTS_NAME libs, then run `ldconfig`

## Building with PROJECTS_NAME
 - [Building]


[Building]:build.md
[Windows_Add to_path]:https://docs.microsoft.com/en-us/previous-versions/office/developer/sharepoint-2010/ee537574(v=office.14)
[Linux_Add_to_path]:https://stackabuse.com/how-to-permanently-set-path-in-linux/
