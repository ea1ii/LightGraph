#!/bin/bash

ME="$(basename "${BASH_ARGV0}")"

# Modifications in /allsky/html/allsky/functions.php
# line 339... added
#
# $suf = substr($file, $file_prefix_len + 9, 1);
# if ($suf === "d") {  
#   $segment = "<i>(day)</i>";
# } else {
#   $segment = "<b>(night)</b>";
# }
#
# down 2 lines changed
# $day</div>
# to
# $day<br>$segment</div>
#
# TODO:
# - check file deletion
# - portal (?)
#

source "${ALLSKY_HOME}/variables.sh"		|| exit 99
source "${ALLSKY_CONFIG}/config.sh"			|| exit 99
source "${ALLSKY_SCRIPTS}/functions.sh"		|| exit 99
source "${ALLSKY_CONFIG}/ftp-settings.sh"	|| exit 99

# get today date
TODAY=$(date +%Y%m%d)

# directory for the day images ('d')
TODAY_DAY="${TODAY}d"

TODAY_DIR = "${ALLSKY_IMAGES}/${TODAY}"

if [ -z "${TODAY_DIR}" ] ; then
    echo -e "${ME}: ${RED}ERROR: '${TODAY}' not found!${NC}"
    exit 2
fi

# directory for the day images ('d')
TODAY_DAY_DIR = "${TODAY_DIR}d"

if [[ ${TIMELAPSE} == "true" ]]; then

    # create the directory for day images a(and thumbnails)
    echo -e "${ME}: ===== Creating Day images directory for ${TODAY}"
    mkdir -p ${TODAY_DAY_DIR}/thumbnails
    RET = $?
    if [[ ${RET} = 0 ]]; then
        echo -e "${ME}: ${RED}ERROR: Could not create directory"
        exit 2
    fi

    # copy images up to now (day ones) to temp dir
    echo -e "${ME}: ===== Copying Day images for ${TODAY}"
    cp -r ${TODAY_DIR}/. ${TODAY_DAY_DIR}
    RET = $?
    if [[ ${RET} = 0 ]]; then
        echo -e "${ME}: ${RED}ERROR: Could not copy images"
        exit 2
    fi

    # generate day timelapse
    echo -e "${ME}: ===== Generating Day timelapse ${TODAY}"
    "${ALLSKY_SCRIPTS}/generateForDay.sh" -t "${TODAY_DAY}"
    RET = $?
    if [[ ${RET} = 0 ]]; then
        echo -e "${ME}: ${RED}ERROR: Could not copy images"
        exit 2
    else
        echo -e "${ME}: ${RED} ===== Timelapse complete"
        if [[ ${UPLOAD_VIDEO} == "true" ]]: then
            # upload day timelapse
            "${ALLSKY_SCRIPTS}/generateForDay.sh" --upload -t "${TODAY_DAY}"
        fi

        # remove day images (TBD)
        # leave images there if daily timelapse is activated and you also want a full timelapse
        # instead of the 'normal' nightly timelapse, that you will get if images so far today are removed
        # only remove contents, there's the night left
        rm -r ${TODAY_DIR}/*
    fi  


    # remove the directory
    #rm -r ${IMG_DIR}/${TODAY_D}
fi