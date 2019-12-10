#!/bin/bash
# set -uex -o pipefail
set -ue

working_dir="`pwd`"

#Get namesapce variable
tenant=`awk '{print $NF}' "$working_dir/tenant_export"`

usage_exit() {
    echo "Usage: $0 [-G JMETER_PROPERTY] [-J JMETER_PROPERTY] [-f SCENARIO_FILE_NAME]" >&2
    exit 1
}

global_properties=()
jmeter_properties=()
SCENARIO_FILE_NAME=${SCENARIO_STARTPOINT_FILE_NAME:-benchmark_plan.jmx}

while getopts G:J:f:h OPT
do
    case $OPT in
        G)
            global_properties+=( "$OPTARG" )
            ;;
        J)
            jmeter_properties+=( "$OPTARG" )
            ;;
        f)
            SCENARIO_FILE_NAME="$OPTARG"
            ;;
        h)
            usage_exit
            ;;
        :)
            usage_exit
            ;;
        \?)
            usage_exit
            ;;
    esac
done

jmx=$SCENARIO_FILE_NAME
[ -n "$jmx" ] || read -p 'Enter path to the jmx file ' jmx

if [ ! -f "$jmx" ];
then
    echo "Test script file was not found in PATH"
    echo "Kindly check and input the correct file path"
    exit
fi

jmeter_options=()

for prop in "${jmeter_properties[@]+"${jmeter_properties[@]}"}"; do
    jmeter_options+=( -J"$prop" )
done
for prop in "${global_properties[@]+"${global_properties[@]}"}"; do
    jmeter_options+=( -G"$prop" )
done

test_name="$(basename "$jmx")"

#Get Master pod details

master_pod=`kubectl get po -n $tenant | grep jmeter-master | grep Running | awk '{print $1}'`

kubectl cp "$jmx" -n $tenant "$master_pod:/$test_name"

# Echo Starting Jmeter load test

kubectl exec -ti -n $tenant $master_pod -- /bin/bash /load_test "$test_name" ${jmeter_options[@]}
