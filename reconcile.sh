#!/bin/bash

wait=5
attempts=6

for i in $(seq 1 $attempts); do
    echo "Finding Pending pods with no image pull secrets..."
    pods=$(oc get po --all-namespaces --field-selector=status.phase==Pending -o go-template='{{range .items}}{{.metadata.namespace}} {{.metadata.name}} {{ len .metadata.ownerReferences }} {{ len .spec.imagePullSecrets }}{{"\n"}}{{end}}')
    
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
            fi
        fi
    done <<< "$pods"

    if [ "$i" -lt "$attempts" ]; then
        echo "Checking again in $wait seconds"
        sleep $wait
    fi
done

echo "Completed removing pods without image pull secrets"