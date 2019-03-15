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
#   René Fritze (2017 - 2018)
# ~~~

# ****** THIS FILE IS AUTOGENERATED, DO NOT EDIT **********
# this file is treated as a jinja2 template

WAIT="${SUPERDIR}/scripts/bash/travis_wait_new.bash 45"
source ${SUPERDIR}/scripts/bash/retry_command.bash

if [[ $TRAVIS_JOB_NUMBER == *.2 ]] ; then
    git config --global hooks.clangformat ${CLANG_FORMAT}
    CHECK_DIR=${SUPERDIR}/${MY_MODULE}
    PYTHONPATH=${SUPERDIR}/scripts/python/ python3 -c "import travis_report as tp; tp.clang_format_status(\"${CHECK_DIR}\")"
    ${SRC_DCTRL} ${BLD} --only=${MY_MODULE} configure
    ${SRC_DCTRL} ${BLD} --only=${MY_MODULE} make doc
    ${SUPERDIR}/.ci/init_sshkey.bash ${encrypted_862ca47045d1_key} ${encrypted_862ca47045d1_iv} keys/dune-community/dune-community.github.io
    ${SUPERDIR}/.ci/deploy_docs.sh ${MY_MODULE} "${DUNE_BUILD_DIR}"
fi

${SUPERDIR}/.ci/init_sshkey.bash ${encrypted_862ca47045d1_key} ${encrypted_862ca47045d1_iv} keys/dune-community/dune-xt-functions-testlogs
# retry this step because of the implicated race condition in cloning and pushing with multiple builder running in parallel
retry_command ${SUPERDIR}/scripts/bash/travis_upload_test_logs.bash ${DUNE_BUILD_DIR}/${MY_MODULE}/dune/xt/*/test/

# ****** THIS FILE IS AUTOGENERATED, DO NOT EDIT **********