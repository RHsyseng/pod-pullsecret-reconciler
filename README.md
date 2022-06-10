# pod-pullsecret-reconciler
A Helm chart to delete pods stuck in a pending state without image pull secrets

# Purpose
[As noted in the OpenShift documentation](https://docs.openshift.com/container-platform/4.10/openshift_images/managing_images/using-image-pull-secrets.html#images-allow-pods-to-reference-images-across-projects_using-image-pull-secrets), service accounts must be fully provisioned with an image pull secret before being used by pods to pull images from the internal cluster registry. If pods are created before the image pull secret exists, the pod will be stuck in an ImagePullBackOff state until it is deleted.

It is recommended to verify the service account is provisioned with secrets before creating deployments, but this chart is intended for cases where that is not feasible.

This chart is intended to be run after any needed application charts have been deployed to
an OpenShift cluster. The chart will create RBAC resources and deploy a job using the `openshift4/ose-cli` image. The job runs a Bash script that uses kubectl to identify pods stuck pending without image pull secrets, and deletes them. The script searches for pods multiple times to ensure deployment controllers have ample time to create pods.

# Deployment
This chart can be installed directly from a release archive or by cloning this repo locally.
```bash
$ helm install -n pod-reconciler --create-namespace pod-reconciler ./pod-pullsecret-reconciler.tgz
```
