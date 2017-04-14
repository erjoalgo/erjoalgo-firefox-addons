#!/bin/bash -x

ABSOLUTE_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
ADDONS_LIST="$(dirname ${ABSOLUTE_PATH})/addons.list"

PROFILE_DIR="${1}"
test -n "${PROFILE_DIR}" || exit 1

EXTENSIONS_DIR="${PROFILE_DIR}/extensions"
test -d "${EXTENSIONS_DIR}" || mkdir "${EXTENSIONS_DIR}"

cd "${EXTENSIONS_DIR}"
for URL in $(cut -d: -f2- < ${ADDONS_LIST}); do
    XPI_URL=$(curl -LIs ${URL} | grep Location | cut -d' ' -f2- \
		     | sed 's/?.*//')
    FILENAME=$(basename ${XPI_URL})
    # TODO check sha hash
    curl -s "${XPI_URL}" -o "${FILENAME}"
done
