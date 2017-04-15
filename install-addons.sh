#!/bin/bash -x

ABSOLUTE_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
ADDONS_LIST="$(dirname ${ABSOLUTE_PATH})/addons.conf"

PROFILE_DIR="${1}"
test -n "${PROFILE_DIR}" || exit 1

EXTENSIONS_DIR="${PROFILE_DIR}/extensions"
test -d "${EXTENSIONS_DIR}" || mkdir "${EXTENSIONS_DIR}"

cd "${EXTENSIONS_DIR}"
for URL in $(grep -v '^#' ${ADDONS_LIST} | cut -d: -f2-); do
    # TODO check sha hash
    TMPNAME="tmp-$RANDOM-$RANDOM"
    mkdir ${TMPNAME}
    cd ${TMPNAME}
    curl -Ls "${URL}" -o "${TMPNAME}.xpi"
    if ! test $? -eq 0; then
	echo "failed: curl -Ls ${URL} -o ${TMPNAME}.xpi"
	exit ${LINENO}
    fi

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
    mv ${TMPNAME}/${TMPNAME}.xpi ${ADDON_ID}.xpi
    rm -rf ${TMPNAME}
done
