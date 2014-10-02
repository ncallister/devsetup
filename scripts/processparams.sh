#!/bin/bash

# Process command line parameters
#
# This script segment is designed to be included in other bash scripts using the dot or include notation.
# 
# Before including this script the following variables need to be established:
#
# PARAMETERS: Array
# An array of strings where each string represents a parameter that needs to be processed.
# For each element, "NAME", in the array there must be also a blank variable placeholder and an associative array
# named "DEF_NAME" with the following elements:
#  * VARIABLE: The name of the placeholder variable
#  * LONG: The long form parameter identifier
#  * SHORT: The short (single character) form parameter identifier
#  * TAKES_VALUE: "true" or "false" to indicate whether the parameter is simply present or absent or wether another
#                 value is expected to follow the parameter identifier.
#  * REQUIRED: Whether or not the parameter is required to be present in order for the script to be valid.
#
# Example parameter definition:
# # -s --server
# SERVER=""
# declare -A DEF_SERVER=(["VARIABLE"]="SERVER" ["LONG"]="server" ["SHORT"]="s" ["TAKES_VALUE"]="true" ["REQUIRED"]="true")
# declare -a PARAMETERS=("SERVER")
#
# The script that uses this script also needs to have defined a method named "show_help" that will print the help /
# usage message if the parameters are considered invalid.


LONG_OPTIONS=""
SHORT_OPTIONS=""


FIRST="true"
for PARAM in "${PARAMETERS[@]}"; do
  eval LONG="\${DEF_${PARAM}["LONG"]}"
  eval SHORT="\${DEF_${PARAM}["SHORT"]}"
  eval TAKES_VALUE="\${DEF_${PARAM}["TAKES_VALUE"]}"

  if $FIRST; then
    FIRST="false"
  else
    LONG_OPTIONS="${LONG_OPTIONS},"
  fi
	LONG_OPTIONS="${LONG_OPTIONS}${LONG}"
	SHORT_OPTIONS="${SHORT_OPTIONS}${SHORT}"
	if ${TAKES_VALUE}; then
		LONG_OPTIONS="${LONG_OPTIONS}:"
		SHORT_OPTIONS="${SHORT_OPTIONS}:"
	fi
done

# Evaluate the command line options
TEMP=`getopt -l "${LONG_OPTIONS}" -o "${SHORT_OPTIONS}" -- "$@"`

# Check for invalid options ($? gives the exit code of the previously executed command)
if [ $? != 0 ]; then
  show_help >&2
  exit 1
fi

# Transpose the parameters as the output of getopt
eval set -- "$TEMP"

# parse the paramters into their variables
while true; do
  # Grab the next option
  OPT="$1"
  shift

  #exit clause
  if test "$OPT" = "--"; then
  	break
  fi

  FOUND="false"

  for PARAM in "${PARAMETERS[@]}"; do
    eval LONG="\${DEF_${PARAM}["LONG"]}"
    eval SHORT="\${DEF_${PARAM}["SHORT"]}"
    eval TAKES_VALUE="\${DEF_${PARAM}["TAKES_VALUE"]}"
    eval VARNAME="\${DEF_${PARAM}["VARIABLE"]}"
    eval LIST="\${DEF_${PARAM}["LIST"]}"

  	if test "$OPT" = "--${LONG}" || test "$OPT" = "-${SHORT}"; then
  		FOUND="true"
      VAL="true"
  		if test "${TAKES_VALUE}" = "true"; then
  			VAL="$1"
  			shift
  		fi

      if test "${LIST}" = "true"; then
        eval "${VARNAME}+=(\"\$VAL\")"
      else
        eval ${VARNAME}="\$VAL"
      fi
  	fi
  done

  if test "$FOUND" != "true"; then
    echo "Unrecognised parameter $OPT" >&2
    show_help >&2
  	exit 1
  fi
done

# Check required variables
for PARAM in "${PARAMETERS[@]}"; do
  eval VARNAME="\${DEF_${PARAM}["VARIABLE"]}"
  eval REQUIRED="\${DEF_${PARAM}["REQUIRED"]}"
  eval LIST="\${DEF_${PARAM}["LIST"]}"

  if test "$LIST" = "true"; then
    eval VALUE="\${${VARNAME}[@]}"
  else
    eval VALUE="\${${VARNAME}}"
  fi

  if ${REQUIRED} && test -z "${VALUE}"; then
    echo "A value must be provided for parameter ${VARNAME}" >&2
    show_help >&2
    exit 1
  fi
done