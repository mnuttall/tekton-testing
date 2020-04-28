A super-simple Tekton pipeline with only one Task. 

Note that the PipelineResources point to an inaccessible source repo and docker registry - that's not important. By default this PipelineRun will create a Pod with a persistent volume claim. On Kubernetes systems with no default storage provider this will cause the pod to hang:

```
Volumes:
  docker-socket:
    Type:          HostPath (bare host directory volume)
    Path:          /var/run/docker.sock
    HostPathType:
  simple-pipelinerun-pvc:
    Type:       PersistentVolumeClaim (a reference to a PersistentVolumeClaim in the same namespace)
    ClaimName:  simple-pipelinerun-pvc
    ReadOnly:   false
  tools:
    Type:    EmptyDir (a temporary directory that shares a pod's lifetime)
    Medium:
  workspace:
    Type:    EmptyDir (a temporary directory that shares a pod's lifetime)
    Medium:
  home:
    Type:    EmptyDir (a temporary directory that shares a pod's lifetime)
    Medium:
  default-token-xznrj:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  default-token-xznrj
    Optional:    false
QoS Class:       BestEffort
Node-Selectors:  <none>
Tolerations:     node.kubernetes.io/not-ready:NoExecute for 300s
                 node.kubernetes.io/unreachable:NoExecute for 300s
Events:
  Type     Reason            Age                    From               Message
  ----     ------            ----                   ----               -------
  Warning  FailedScheduling  2m25s (x2 over 2m25s)  default-scheduler  pod has unbound immediate PersistentVolumeClaims (repeated 2 times)
```

The simple-pipelinerun-pvc volume is not listed in the `Mount` section of any build step container. It is however unbound, preventing the pod from starting:

```
k describe pvc simple-pipelinerun-pvc -n ktest
Name:          simple-pipelinerun-pvc
Namespace:     ktest
StorageClass:
Status:        Pending
Volume:
Labels:        <none>
Annotations:   <none>
Finalizers:    [kubernetes.io/pvc-protection]
Capacity:
Access Modes:
Events:
  Type       Reason         Age                  From                         Message
  ----       ------         ----                 ----                         -------
  Normal     FailedBinding  9s (x16 over 3m13s)  persistentvolume-controller  no persistent volumes available for this claim and no storage class is set
Mounted By:  simple-pipelinerun-build-simple-nngql-pod-70de35
```

https://github.com/tektoncd/pipeline/issues/617 suggests that "a PVC is created [w]hen a user wants to link Pipeline Task outputs and inputs." However in this case a pvc is created even when there is only on Task. A pvc is created if no GCS storage bucket is set, as per https://github.com/tektoncd/pipeline/blob/master/docs/install.md. As a workaround, a storage bucket may be configured:

```
apiVersion: v1
data:
  bucket.service.account.secret.key: account.json
  bucket.service.account.secret.name: pipelines-gs-credentials
  location: gs://tekton-pipelines
kind: ConfigMap
metadata:
  name: config-artifact-bucket
  namespace: tekton-pipelines
```

The secret `pipelines-gs-credentials` does not have to exist: simply creating the ConfigMap is enough to prevent the PVC creation, allowing the Pod to start. 
