#!/bin/bash
#
# ~~~
# This file is part of the dune-xt-functions project:
#   https://github.com/dune-community/dune-xt-functions
# Copyright 2009-2018 dune-xt-functions developers and contributors. All rights reserved.
# License: Dual licensed as BSD 2-Clause License (http://opensource.org/licenses/BSD-2-Clause)
#      or  GPL-2.0+ (http://opensource.org/licenses/gpl-license)
#          with "runtime exception" (http://www.dune-project.org/license.html)
# Authors:
#   Felix Schindler (2017)
#   René Fritze     (2017 - 2018)
#   Tobias Leibner  (2018)
# ~~~

# ****** THIS FILE IS AUTOGENERATED, DO NOT EDIT **********
# this file is treated as a jinja2 template

set -e
set -x

WAIT="${SUPERDIR}/scripts/bash/travis_wait_new.bash 45"
source ${SUPERDIR}/scripts/bash/retry_command.bash

${SRC_DCTRL} ${BLD} --only=${MY_MODULE} configure
${SRC_DCTRL} ${BLD} --only=${MY_MODULE} bexec ${BUILD_CMD}
if [ x"${TESTS}" == x ] ; then
    ${WAIT} ${SRC_DCTRL} ${BLD} --only=${MY_MODULE} bexec ${BUILD_CMD} test_binaries
else
    ${WAIT} ${SRC_DCTRL} ${BLD} --only=${MY_MODULE} bexec ${BUILD_CMD} test_binaries_builder_${TESTS}
fi

source ${OPTS}
CTEST="ctest -V --timeout ${DXT_TEST_TIMEOUT:-300} -j ${DXT_TEST_PROCS:-2}"

if [ x"${TESTS}" == x ] ; then
    ${SRC_DCTRL} ${BLD} --only=${MY_MODULE} bexec ${CTEST}
    ${SRC_DCTRL} ${BLD} --only=${MY_MODULE} bexec ${BUILD_CMD} headercheck
else
    # with binning headercheck is included in building tests
    ${SRC_DCTRL} ${BLD} --only=${MY_MODULE} bexec ${CTEST} -L "^builder_${TESTS}$"
fi

# clang coverage currently disabled for being to mem hungry
if [[ ${CC} == *"clang"* ]] ; then
    echo "Coverage reporting disabled with Clang"
    exit 0
fi

if [ "${TRAVIS_SECURE_ENV_VARS}" == "false" ] ; then
    echo "Coverage reporting disabled for forked repo/PR"
    exit 0
fi

pushd ${DUNE_BUILD_DIR}/${MY_MODULE}
COVERAGE_INFO=${PWD}/coverage.info
lcov --directory . --output-file ${COVERAGE_INFO} --ignore-errors gcov -c
for d in "dune-common" "dune-pybindxi" "dune-geometry"  "dune-istl"  "dune-grid" "dune-alugrid"  "dune-uggrid"  "dune-localfunctions" ; do
    lcov --directory . --output-file ${COVERAGE_INFO} -r ${COVERAGE_INFO} "${SUPERDIR}/${d}/*"
done
lcov --directory . --output-file ${COVERAGE_INFO} -r ${COVERAGE_INFO} "${SUPERDIR}/${MY_MODULE}/dune/xt/*/test/*"
cd ${SUPERDIR}/${MY_MODULE}
${OLDPWD}/run-in-dune-env pip install codecov
${OLDPWD}/run-in-dune-env codecov -v -X gcov -X coveragepy -F ctest -f ${COVERAGE_INFO} -t ${CODECOV_TOKEN}
popd

# ****** THIS FILE IS AUTOGENERATED, DO NOT EDIT **********
