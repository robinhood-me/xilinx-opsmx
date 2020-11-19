#!/bin/bash

GATE_SERVER='http://34.105.30.37'
UI_SERVER='http://35.230.115.222'
application='xilinxapp'
beginCanaryAnalysisAfterMins='0'
canaryAnalysisIntervalMins='120'
lifetimeHours='2'
minimumCanaryResultScore='70'
canaryResultScore='90'
username='admin'
serviceName='xilinxappsvc'
BASELINE_STARTTIME=1604647800000
BASELINE_LOGID='390116_67569'

GATE_URL="$GATE_SERVER/autopilot/registerCanary"

usage="$(basename "$0") [-help]

-- Example to show how to pass relevant arguments.

USAGE:
$(basename "$0") -baselinestarttime=1604647800000 -newreleasestarttime=1605101326000 -baselinelogid=87655_66480 -newreleaselogid=390116_67569

args:
  -baselinestarttime=<Baseline log start time for analysis>
  -newreleasestarttime=<Newrelease log start time for analysis>
  -baselinelogid=<Value of request_process_id for Baseline log>
  -newreleaselogid=<Value of request_process_id for Newrelease log>"


for i in "$@"
do
case $i in
    -baselinestarttime=*|--baselinestarttime=*)
    baselinestarttime="${i#*=}"
    shift # past argument=value
    ;;
    -newreleasestarttime=*|--newreleasestarttime=*)
    newreleasestarttime="${i#*=}"
    shift # past argument=value
    ;;
    -baselinelogid=*|--baselinelogid=*)
    baselinelogid="${i#*=}"
    shift # past argument=value
    ;;
    -newreleaselogid=*|--newreleaselogid=*)
    newreleaselogid="${i#*=}"
    shift # past argument=value
    ;;
    *)
     echo "$usage";
     exit 1
     ;;
esac
done


if [[ -z "$newreleasestarttime" ]]; then
  echo "Provide newrelease start time";
  echo "$usage";
  exit 1;
fi


if [[ -z "$newreleaselogid" ]]; then
  echo "Provide newrelease log id value";
  echo "$usage";
  exit 1;
fi

baselinestarttime=${baselinestarttime:-$BASELINE_STARTTIME}
baselinelogid=${baselinelogid:-$BASELINE_LOGID}

jsondata="{
    \"application\": \"$application\",
    \"isJsonResponse\": true,
    \"canaryConfig\": {
        \"canaryAnalysisConfig\": {
            \"beginCanaryAnalysisAfterMins\": \"$beginCanaryAnalysisAfterMins\",
            \"canaryAnalysisIntervalMins\": \"$canaryAnalysisIntervalMins\",
            \"notificationHours\": []
        },
        \"canaryHealthCheckHandler\": {
            \"minimumCanaryResultScore\": \"$minimumCanaryResultScore\"
        },
        \"canarySuccessCriteria\": {
            \"canaryResultScore\": \"$canaryResultScore\"
        },
        \"combinedCanaryResultStrategy\": \"AGGREGATE\",
        \"lifetimeHours\": \"$lifetimeHours\",
        \"name\": \"$username\"
    },
    \"canaryDeployments\": [
        {
            \"baseline\": {
                \"log\": {
                    \"$serviceName\": {
                        \"request_process_id\": \"$baselinelogid\"
                    }
                }
            },
            \"baselineStartTimeMs\": $baselinestarttime,
            \"canaryStartTimeMs\": $newreleasestarttime,
            \"canary\": {
                \"log\": {
                    \"$serviceName\": {
                        \"request_process_id\": \"$newreleaselogid\"
                    }
                }
            }
        }
    ]
}"



response=$(curl -k -H  "Content-Type:application/json"  -X POST -d "$jsondata" "$GATE_URL" | jq -r '.canaryId')

# Adding Canary ID to report url
reportUrl="$UI_SERVER/application/deploymentverification/$application/$response"
echo "$reportUrl"