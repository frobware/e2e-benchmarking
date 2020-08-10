#!/usr/bin/env bash
datasource="elasticsearch"
tool="uperf"
function="compare"
_es=${ES_SERVER:-search-cloud-perf-lqrf3jjtaqo7727m7ynd2xyt4y.us-west-2.es.amazonaws.com}
_es_port=${ES_PORT:-80}

if [[ ${ES_SERVER} ]] && [[ ${ES_PORT} ]] && [[ ${ES_USER} ]] && [[ ${ES_PASSWORD} ]]; then
  _es=${ES_USER}:${ES_PASSWORD}@${ES_SERVER}
  _es_port=${ES_PORT}
elif [[ ${ES_SERVER} ]] && [[ ${ES_PORT} ]]; then
  _es=${ES_SERVER}
  _es_port=${ES_PORT}
fi

_es_baseline=${ES_SERVER_BASELINE:-$_es}
_es_baseline_port=${ES_PORT_BASELINE:-$_es_port}

if [[ ${ES_SERVER_BASELINE} ]] && [[ ${ES_PORT_BASELINE} ]] && [[ ${ES_USER_BASELINE} ]] && [[ ${ES_PASSWORD_BASELINE} ]]; then
  _es_baseline=${ES_USER_BASELINE}:${ES_PASSWORD_BASELINE}@${ES_SERVER_BASELINE}
  _es_baseline_port=${ES_PORT_BASELINE}
elif [[ ${ES_SERVER_BASELINE} ]] && [[ ${ES_PORT_BASELINE} ]]; then
  _es=${ES_SERVER_BASELINE}
  _es_port=${ES_PORT_BASELINE}
fi

if [[ ${COMPARE} != "true" ]]; then
  compare_uuid=$1
else
  base_uuid=$1
  compare_uuid=$2
fi

python3 -m venv ./venv
source ./venv/bin/activate
pip3 install git+https://github.com/cloud-bulldozer/touchstone
if [[ $? -ne 0 ]] ; then
  echo "Unable to execute compare - Failed to install touchstone"
  exit 1
fi
set -x
touchstone_compare $tool $datasource ripsaw -url $_es:$_es_port $_es_baseline:$_es_baseline_port -u $base_uuid $compare_uuid -o yaml | tee ../compare_output_${!#}p.yaml
if [[ $? -ne 0 ]] ; then
  echo "Unable to execute compare - Failed to run touchstone"
  exit 1
fi
deactivate
rm -rf venv
