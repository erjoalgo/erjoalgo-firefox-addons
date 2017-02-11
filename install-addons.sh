#!/bin/bash -x

ABSOLUTE_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
ADDONS_LIST="$(dirname ${ABSOLUTE_PATH})/addons.list"

PROFILE_DIR="${1}"
test -n "${PROFILE_DIR}" || exit 1

EXTENSIONS_DIR="${PROFILE_DIR}/extensions"
test -d "${EXTENSIONS_DIR}" || exit 1

cd "${EXTENSIONS_DIR}"
for URL in $(grep 'https://' "${ADDONS_LIST}"); do
    # wget --content-disposition "${URL}"
    # curl -JOL "${URL}"
    curl -LIs "${URL}"
done
