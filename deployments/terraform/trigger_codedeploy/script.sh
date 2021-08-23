#!/bin/bash

set -e

get_running_deployment () {
  RUNNING_DEPLOYMENT_ID=$(aws deploy list-deployments --application-name "$APPLICATION_NAME" --deployment-group "$DEPLOYMENT_GROUP_NAME" --include-only-statuses Created Queued InProgress Baking | jq -r '.deployments | .[]')
  if [ -n "$RUNNING_DEPLOYMENT_ID" ]; then
    echo "running deployment = $RUNNING_DEPLOYMENT_ID"
  fi
}

get_deployment_status () {
  if [ -n "$RUNNING_DEPLOYMENT_ID" ]; then
    DEPLOYMENT_TARGET=$(aws deploy list-deployment-targets --deployment-id "$RUNNING_DEPLOYMENT_ID"  | jq -cr '.targetIds | .[] ')
    echo "deployment target $DEPLOYMENT_TARGET"
  fi

  if [ -n "$DEPLOYMENT_TARGET" ]; then
    DEPLOYMENT_STATUS=$(aws deploy get-deployment-target --deployment-id "$RUNNING_DEPLOYMENT_ID" --target-id "$DEPLOYMENT_TARGET" | jq -cr '.deploymentTarget.ecsTarget.status')
    echo "deployment status $DEPLOYMENT_STATUS"
  fi
}

get_running_deployment

wait_counter=0

while [ -n "$RUNNING_DEPLOYMENT_ID" ]; do
  get_deployment_status

  if [[ "$DEPLOYMENT_STATUS" == "Succeeded" ]]; then
    echo "Terminating previous task set."
    aws deploy continue-deployment --deployment-id "$RUNNING_DEPLOYMENT_ID" --deployment-wait-type TERMINATION_WAIT

    echo "Waiting 10 seconds."
    sleep 10
    break
  else
    ((wait_counter=wait_counter+1))

    if [ "$wait_counter" -ge 9 ]; then
      echo "After waiting 5+ minutes, the previous deployment has still not succeeded. (status = $DEPLOYMENT_STATUS) Exiting."
      exit 1
    fi

    echo "The still-running previous deployment has not succeeded yet. (status = $DEPLOYMENT_STATUS) Waiting 30 seconds. (wait counter = $wait_counter)"
    sleep 30
  fi
done


echo "Creating new deployment!"

REVISION=$(cat <<EOT
{
  "revisionType": "AppSpecContent",
  "appSpecContent": {
    "content": "{
      \"version\": 0,
      \"Resources\": [{
        \"TargetService\": {
          \"Type\": \"AWS::ECS::Service\",
          \"Properties\": {
            \"TaskDefinition\": \"${TASK_DEFINITION_ARN}\",
            \"LoadBalancerInfo\": {
              \"ContainerName\": \"${CONTAINER_NAME}\",
              \"ContainerPort\": \"${CONTAINER_PORT}\"
            }
          }
        }
      }]
    }"
  }
}
EOT
)
REVISION=$(echo $REVISION | sed 's/\n//')

aws deploy create-deployment \
  --region=us-east-1 \
  --application-name="$APPLICATION_NAME" \
  --deployment-group-name="$DEPLOYMENT_GROUP_NAME" \
  --revision="$REVISION"
  
