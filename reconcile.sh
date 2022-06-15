#!/bin/bash

# wait interval (seconds) between checks
: "${WAIT_INTERVAL:=30}"

while true; do
    echo "Finding Pending pods with no image pull secrets..."
    pods=$(oc get po --all-namespaces --field-selector=status.phase==Pending -o go-template='{{range .items}}{{.metadata.namespace}} {{.metadata.name}} {{with .metadata.ownerReferences}}{{len .}}{{else}}0{{end}} {{with .spec.imagePullSecrets}}{{len .}}{{else}}0{{end}}{{"\n"}}{{end}}')

    count=0
    # loop over all pending pods
    while IFS= read -r line; do
        if [ ! -z "$line" ]; then
            ns="$(echo $line | cut -d ' ' -f 1)"
            name="$(echo $line | cut -d ' ' -f 2)"
            owners="$(echo $line | cut -d ' ' -f 3)"
            imgpull="$(echo $line | cut -d ' ' -f 4)"

            # if pod has an owner and no image pull secrets, delete it
            if [ "$owners" -gt 0 ] && [ "$imgpull" -lt 1 ]; then
                oc delete po -n $ns $name
                ((count++))
            fi
        fi
    done <<< "$pods"

    if [ "$count" -eq 0 ]; then
        echo "No matching pods found"
    fi

    # pause before checking again
    sleep $WAIT_INTERVAL
done
