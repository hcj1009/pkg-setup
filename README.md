# Package Setup (setup.sh)
######A convenient way to quickly deploy package-based projects.######

----
## Configure
To add package(s), copy the template from `PACKAGE\_TEMPLATE` area, and modify
the fields accordingly. Do **NOT** remove `C=${#PKG\_NAM[@]}+1`. Note that packages
are deployed in the order they are configured in this script. If the setup of
a target package depends on another base package, the base package should be
configured before the target package. Below is a description of each field:

* **PKG_NAM**: The name of the package.
  
* **PKG_VER**: The version of the package.

* **PKG_DIR**: The directory in which the package will be found (or downloaded).
           If left empty, "." will be used.
           
* **PKG_FIL**: The full filename of the package, including file extensions.
           If left empty, will skip package check and downloading.
           
* **PKG_LNK**: The URL link to the package. If the package is not found at the
           specified directory, this will be used to download the package.
           
* **PKG_CMD**: Package specific commands (e.g. unpack, configure). This will be
           executed at the end of each package setup.
           
If not specified above, empty field may cause undefined behavior.
Extra script can be added at the end of the file if necessary.

----
## Usage
It is good practice to put this script in an empty folder before running it.

* To mark this script executable:
`$ chmod u+x setup.sh`

* To run this script:
`$ ./setup.sh`
