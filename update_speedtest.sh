#!/bin/bash

DOWNLOAD_URL='http://c.speedtest.net/mini/mini.zip'
WORK_DIR='/var/www'

CUR_PATH="${WORK_DIR}/speedtest"
PREV_PATH="${WORK_DIR}/speedtest_prev"
ZIP_PATH="${WORK_DIR}/speedtest_mini.zip"


if [ -e "${ZIP_PATH}" ]; then
	echo "Speedtest already downloaded. Will compare with the latest version."

	echo -n "Checking local version file size: "
	LOCAL_SIZE=$(du -b "${ZIP_PATH}" | grep -o '^[0-9]\+') || exit 1
	echo "Done. Local version file size: ${LOCAL_SIZE}B"

	echo -n "Checking latest version file size: "
	DOWNLOAD_SIZE=$(curl -s -I "${DOWNLOAD_URL}" | grep '^Content-Length:' | grep -o '[0-9]\+') || exit 1
	echo "Done. Latest version file size: ${DOWNLOAD_SIZE}B"

	if [ "${DOWNLOAD_SIZE}" -eq "${LOCAL_SIZE}" ]; then
		echo "Local version file size matches latest version, skipping update."
		exit 0
	else
		echo "New version available." >&2
	fi
fi


echo -n "Downloading latest version: " >&2
curl -s "${DOWNLOAD_URL}" -o "${ZIP_PATH}" || exit 1
echo "Done." >&2


if [ -e "${CUR_PATH}" ]; then
	if [ -e "${PREV_PATH}" ]; then
		echo -n "Previus version already exists. Deleting: " >&2
		rm -rf "${PREV_PATH}" || exit 1
		echo "Done." >&2
	fi

	echo -n "Current version exists. Backing up: " >&2
	mv -n "${CUR_PATH}" "${PREV_PATH}" || exit 1
	echo "Done." >&2
fi

echo -n "Extracting new version: " >&2
mkdir -p "${CUR_PATH}/speedtest" || exit 1
unzip -q -j -d "${CUR_PATH}" "${ZIP_PATH}" 'mini/crossdomain.xml' 'mini/index-php.html' 'mini/speedtest.swf' 'mini/swfobject.js' || exit 1
unzip -q -j -d "${CUR_PATH}/speedtest" "${ZIP_PATH}" 'mini/speedtest/expressInstall.swf' 'mini/speedtest/random*.jpg' 'mini/speedtest/swfobject.js' 'mini/speedtest/upload.php' || exit 1
echo "test=test" > "${CUR_PATH}/speedtest/latency.txt" || exit 1
echo "Done." >&2
