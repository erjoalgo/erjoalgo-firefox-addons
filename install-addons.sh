#!/bin/bash -x

set -euo pipefail

command -v xmllint || sudo apt-get install -y libxml2-utils

command -v unzip || sudo apt-get install -y unzip

ABSOLUTE_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
ADDONS_LIST="$(dirname ${ABSOLUTE_PATH})/addons.conf"

PROFILE_DIR="${1}"
test -d "${PROFILE_DIR}"

EXTENSIONS_DIR="${PROFILE_DIR}/extensions"
mkdir -p "${EXTENSIONS_DIR}"

cd "${EXTENSIONS_DIR}"
TMPDIR=/tmp/install-addons
mkdir -p ${TMPDIR}
which xmllint

for URL in $(grep -v '^#' ${ADDONS_LIST} | cut -d: -f2-); do
    # TODO check sha hash
    cd ${TMPDIR}
    TMPNAME="tmp-$RANDOM-$RANDOM"
    mkdir ${TMPNAME} && cd ${TMPNAME}
    HTTP_CODE=$(curl "${URL}" -o "${TMPNAME}.xpi" -w "%{http_code}" -s -L)
    test 200 -eq ${HTTP_CODE}

    file ${TMPNAME}.xpi | grep -i Zip
    unzip ${TMPNAME}.xpi

    # ADDON_ID=$(grep -oE '[{][a-z0-9-]+}' install.rdf)
    cp install.{rdf,xml}
    # remove namespace stuff
    sed -i  's/xmlns.*"//g' install.xml;
    sed -i  's/\(em\|RDF\)://g' install.xml;

    ADDON_ID=$(xmllint install.xml --xpath 'string(/RDF/Description/id)')
    if ! test $? -eq 0 || test -z "${ADDON_ID}"; then
	ADDON_ID=$(xmllint install.xml --xpath 'string(/RDF/Description/@id)')
	# if test -z "${ADDON_ID}"; then
	if ! test $? -eq 0  || test -z "${ADDON_ID}"; then
	    read "couldn't parse ID from $(pwd)/install.rdf..."
	    exit 1;
	fi
    fi

    cd ..
    mv ${TMPNAME}/${TMPNAME}.xpi "${EXTENSIONS_DIR}/${ADDON_ID}.xpi"
    rm -rf ${TMPNAME}
done
