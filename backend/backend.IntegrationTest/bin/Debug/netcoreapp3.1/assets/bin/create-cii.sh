#!/bin/bash
#*******************************************************
#  Copyright 2016 Rockwell Collins Inc.
#  ALL RIGHTS RESERVED.
#  The contents of this medium may not be reproduced in
#  whole or in part without the written consent of
#  Rockwell Collins, except as authorized by
#  section 117 of the U.S. Copyright law.
#*******************************************************

#
# auto-generate CII from Release Configuration file
#

# defaults

# CII tag constants
XML_DECLARATION='<?xml version="1.0" encoding="UTF-8"?>'
CII_START='<cii>'
CII_END='</cii>'
CIIFILENAME_START='<ciifilename>'
CIIFILENAME_END='</ciifilename>'
PARENT811_START='<parent_811'
PARENT811_END='</parent_811>'
SWRELEASE_START='<software_release>'
SWRELEASE_END='</software_release>'
HWPARTNUMBER_START='<hwpartnumbers>'
HWPARTNUMBER_END='</hwpartnumbers>'
PARTNUMBER_START='<partnumber>'
PARTNUMBER_END='</partnumber>'
DESCRIPTION_START='<description>'
DESCRIPTION_END='</description>'
FILENAME_START='<filename>'
FILENAME_END='</filename>'
MD5_START='<md5>'
MD5_END='</md5>'
BUILD_START='<build>'
BUILD_END='</build>'

echo "*   1: ${1}" 
echo "*   2: ${2}" 
echo "*   3: ${3}" 
echo "*   4: ${4}" 
echo "*   5: ${5}" 
echo "*   6: ${6}" 


PARENT_TAR=${6}"_"${4}"_"${5}".tgz";
OUTPUT_CII=${2}".cii"


RELEASE_DIR=${1}
DIR_CII=${1}
PATH_ADD_SIG_JAR=${3}
PART_PARENT_CPN=${4}
BUILD_NUM=${5}
RELEASE_DESCRIPTION="ASXi Configuration Delivery"
#SW_RELEASE_NUMBER=${4}
PKG_TYPE=${6}
# ==== Get Parent data ====
echo ""
echo "* CII processing" 
echo "*   parent tar: ${PARENT_TAR}" 
echo "*   cii output: ${OUTPUT_CII}" 

# IS_PARENT_ONLY: true  = no children, parent only
#                 false = has children
# if [ -n "$PARENT_TAR_PARTS" ]; then
    # IS_PARENT_ONLY="false"
# else
    # IS_PARENT_ONLY="true"
# fi

IS_PARENT_ONLY="true"

# calc parent md5
md5_output=$(md5sum "${RELEASE_DIR}/${PARENT_TAR}")
PARENT_MD5=${md5_output:1:32}

echo "create-cii.sh(enter) PKG_TYPE=${PKG_TYPE}"

# === write CII xml ===
(
    echo "${XML_DECLARATION}"
    echo "${CII_START}"
    echo "  ${CIIFILENAME_START}${OUTPUT_CII}${CIIFILENAME_END}"

    # write parent section of CII
    echo "  ${PARENT811_START} type=\"${PKG_TYPE}\" cpn=\"${PART_PARENT_CPN}\" primitive=\"${IS_PARENT_ONLY}\">"
    echo "    ${FILENAME_START}${PARENT_TAR}${FILENAME_END}"
    echo "    ${MD5_START}${PARENT_MD5}${MD5_END}"
    echo "    ${BUILD_START}${BUILD_NUM}${BUILD_END}"
    echo "    ${DESCRIPTION_START}${RELEASE_DESCRIPTION}${DESCRIPTION_END}"
    echo "    ${SWRELEASE_START}${SW_RELEASE_NUMBER}${SWRELEASE_END}"

    # process hardware part numbers 
    echo "    ${HWPARTNUMBER_START}"

    for partnumber in $HW_PARTNUMBERS; do
        echo "        ${PARTNUMBER_START}${partnumber}${PARTNUMBER_END}"
    done # end for partnumber in HW_PARTNUMBERS
    echo "    ${HWPARTNUMBER_END}"

    # finish CII
    echo "  ${PARENT811_END}"
    echo "${CII_END}"

) > "${DIR_CII}/${OUTPUT_CII}"

# add signature: appends signature to the end of the cii file - use relative path, cygwin frowns on absolute for some reason
if [ "$ON_CYGWIN" = "yes" ] || [ "$ON_CYGWIN" = "YES" ] ; then
    echo THIS IS JAVA ON CYGWIN --------------------------
    java -jar $(cygpath -w  ${PATH_ADD_SIG_JAR_REL})   ${DIR_CII_REL}/${OUTPUT_CII}
else
    echo THIS IS JAVA ON LINUX  --------------------------
    java -jar ${PATH_ADD_SIG_JAR} ${DIR_CII}/${OUTPUT_CII}
fi;

echo "CII generated to ${DIR_CII}/${OUTPUT_CII}"

