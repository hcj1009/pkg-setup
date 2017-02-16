#!/usr/bin/env bash
#
# setup.sh - a convenient way to quickly deploy package-based projects
# Version: 0.0.1
# Author: Chengjie Huang <hcj1009@vt.edu>
#
# Configure:
# To add package(s), copy the template from "PACKAGE_TEMPLATE" area, and modify
# the fields accordingly. Do NOT remove "C=${#PKG_NAM[@]}+1". Note that packages
# are deployed in the order they are configured in this script. If the setup of
# a target package depends on another base package, the base package should be
# configured before the target package. Below is a description of each field:
#   PKG_NAM: The name of the package.
#   PKG_VER: The version of the package.
#   PKG_DIR: The directory in which the package will be found (or downloaded).
#            If left empty, "." will be used.
#   PKG_FIL: The full filename of the package, including file extensions.
#            If left empty, will skip package check and downloading.
#   PKG_LNK: The URL link to the package. If the package is not found at the
#            specified directory, this will be used to download the package.
#   PKG_CMD: Package specific commands (e.g. unpack, configure). This will be
#            executed at the end of each package setup.
# If not specified above, empty field may cause undefined behavior.
# Extra script can be added at the end of the file if necessary.
#
# Usage:
# It is good practice to put this script in an empty folder before running it.
# To mark this script executable:
#   $ chmod u+x setup.sh
# To run this script:
#   $ ./setup.sh
#


### Package configuration

<<"PACKAGE_TEMPLATE"
C=${#PKG_NAM[@]}+1
PKG_NAM[$C]=""
PKG_VER[$C]=""
PKG_DIR[$C]="."
PKG_FIL[$C]="${PKG_NAM[$C]}-${PKG_VER[$C]}.tar.gz"
PKG_LNK[$C]="http://url.to.package/${PKG_FIL[$C]}"
PKG_CMD[$C]="tar -axvf ${PKG_DIR[$C]}/${PKG_FIL[$C]}"
PACKAGE_TEMPLATE

# Boost.Build
C=${#PKG_NAM[@]}+1
PKG_NAM[$C]="boost-build"
PKG_VER[$C]="2014-10"
PKG_DIR[$C]="./pkg"
PKG_FIL[$C]="${PKG_NAM[$C]}-${PKG_VER[$C]}.tar.bz2"
PKG_LNK[$C]="https://github.com/boostorg/build/releases/download/2014.10/${PKG_FIL[$C]}"
PKG_CMD[$C]="if [[ ! -d ${PKG_NAM[$C]} ]]; then tar -axf ${PKG_DIR[$C]}/${PKG_FIL[$C]}; fi; if [[ -d ${PKG_NAM[$C]} && ! -f '.bjam_bootstrap_flag' ]]; then cd ${PKG_NAM[$C]}; ./bootstrap.sh; cd ..; touch .bjam_bootstrap_flag; fi;"

# Boost
C=${#PKG_NAM[@]}+1
PKG_NAM[$C]="boost"
PKG_VER[$C]="1_63_0"
PKG_DIR[$C]="./pkg"
PKG_FIL[$C]="${PKG_NAM[$C]}_${PKG_VER[$C]}.tar.bz2"
PKG_LNK[$C]="https://downloads.sourceforge.net/project/boost/boost/1.63.0/${PKG_FIL[$C]}"
PKG_CMD[$C]="if [[ ! -d ${PKG_NAM[$C]}_${PKG_VER[$C]} ]]; then tar -axf ${PKG_DIR[$C]}/${PKG_FIL[$C]}; fi; if [[ -d ${PKG_NAM[$C]}_${PKG_VER[$C]} && ! -f '.boost_build_flag' ]]; then cd ${PKG_NAM[$C]}_${PKG_VER[$C]}; ../boost-build/bjam --with-system --build-dir=. link=static; cd ..; touch .boost_build_flag; fi"

# Sodium
C=${#PKG_NAM[@]}+1
PKG_NAM[$C]="libsodium"
PKG_VER[$C]="1.0.11"
PKG_DIR[$C]="./pkg"
PKG_FIL[$C]="${PKG_NAM[$C]}-${PKG_VER[$C]}.tar.gz"
PKG_LNK[$C]="https://github.com/jedisct1/libsodium/releases/download/${PKG_VER[$C]}/${PKG_FIL[$C]}"
PKG_CMD[$C]="if [[ ! -d ${PKG_NAM[$C]}-${PKG_VER[$C]} ]]; then tar -axf ${PKG_DIR[$C]}/${PKG_FIL[$C]}; fi; if [[ -d ${PKG_NAM[$C]}-${PKG_VER[$C]} && ! -f .sodium_configure_flag ]]; then cd ${PKG_NAM[$C]}-${PKG_VER[$C]}; ./configure; cd ..; touch .sodium_configure_flag; fi; if [[ -d ${PKG_NAM[$C]}-${PKG_VER[$C]} && ! -f .sodium_build_flag ]]; then cd ${PKG_NAM[$C]}-${PKG_VER[$C]}; make; cd ..; touch .sodium_build_flag; fi;"

# Scout
C=${#PKG_NAM[@]}+1
PKG_NAM[$C]="scout"
PKG_VER[$C]="unknown"
PKG_DIR[$C]=""
PKG_FIL[$C]=""
PKG_LNK[$C]="https://github.com/hcj1009/scout-linux.git"
PKG_CMD[$C]="if [[ ! -d 'scout-linux' ]]; then git clone --recursive ${PKG_LNK[$C]}; fi"

### End of package configuration

### Main setup
echo "Begin package setup."
echo
for i in `seq 1 ${#PKG_NAM[@]}`
do
	echo "[$i] Processing package: ${PKG_NAM[$i]} @ ${PKG_VER[$i]}"
	if [[ -z "${PKG_DIR[$i]}" ]]
	then
		echo "[$i] Directory not defined. Using \".\"."
		PKG_DIR[$i]="."
	fi
	if [[ -d "${PKG_DIR[$i]}" ]]
	then
		echo "[$i] Package directory found."
	else
		echo "[$i] Package directory not found."
		echo "[$i] Creating directory: ${PKG_DIR[$i]}"
		mkdir "${PKG_DIR[$i]}"
	fi
	
	if [[ ! -z "${PKG_FIL[$i]}" ]]
	then
		if [[ -f "${PKG_DIR[$i]}/${PKG_FIL[$i]}" ]]
		then
			echo "[$i] Package found. Skip."
		else
			echo "[$i] Package not found."
			echo "[$i] Downloading package from: ${PKG_LNK[$i]}"
			wget -O "${PKG_DIR[$i]}/${PKG_FIL[$i]}" ${PKG_LNK[$i]}
		fi
	
		if [[ ! -f "${PKG_DIR[$i]}/${PKG_FIL[$i]}" ]]
		then
			echo "[$i] Download failed. Abort!"
			break
		fi
	else
		echo "[$i] No downloadable package. Skip."
	fi
	
	echo "[$i] Executing package command(s): ${PKG_CMD[$i]}"
	eval ${PKG_CMD[$i]}
	echo "[$i] Done."
	echo
done
echo "Package setup completed."

### End of main setup

### Extra script

### End of extra script
