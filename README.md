# kube
A kubernetes example
A little kubernetes demo on a windows host.

## Setup
 - Startup Docker Quickstart Terminal
 - Build a kubectl image as there's no windows native client:
```shell
docker build -t kubectl .
```

## Startup Kubernetes
To start kubernetes use the following 3 commands (startkube.sh):
```shell
docker run --net=host -d gcr.io/google_containers/etcd:2.0.12 //usr/local/bin/etcd --addr=127.0.0.1:4001 --bind-addr=0.0.0.0:4001 --data-dir=//var/etcd/data
docker run \
    --volume=//:/rootfs:ro \
    --volume=//sys:/sys:ro \
    --volume=//dev:/dev \
    --volume=//var/lib/docker/:/var/lib/docker:ro \
    --volume=//var/lib/kubelet/:/var/lib/kubelet:rw \
    --volume=//var/run:/var/run:rw \
    --net=host \
    --pid=host \
    --privileged=true \
    -d \
    gcr.io/google_containers/hyperkube:v1.0.1 \
    //hyperkube kubelet --containerized --hostname-override="127.0.0.1" --address="0.0.0.0" --api-servers=http://localhost:8080 --config=//etc/kubernetes/manifests	
docker run -d --net=host --privileged gcr.io/google_containers/hyperkube:v1.0.1 //hyperkube proxy --master=http://127.0.0.1:8080 --v=2
```
## Download windows client (kubectl)
https://storage.googleapis.com/kubernetes-release/release/v1.1.7/bin/windows/amd64/kubectl.exe

#### Setup ssh tunnel for kubectl and kube-ui
docker-machine.exe ssh default -f -L 8080:localhost:8080 -N

## Example image
Start example image with 2 instances (manual):
```shell
kubectl run hello --image=hello --replicas=2 --port=8080
kubectl expose rc hello --port=8080 --type=NodePort
kubectl get svc -o json
```
or from file descriptor (preferred):
```shell
kubectl create -f hello_rc.yml
kubectl create -f hello_svc.yml
kubectl get svc -o json
```
The last lines shows how the service looks like (and also gives you the external port)

## Kube-UI
```shell
kubectl --namespace=kube-system create -f kube_ui_rc.yml
kubectl --namespace=kube-system create -f kube_ui_svc.yml
kubectl cluster-info
```

## Rolling Update
This is my favorite!
Be sure to define a readinessProbe:
```yml
        readinessProbe:
          httpGet:
            path: /hello/v1/hello
            port: 8080
          initialDelaySeconds: 20
          timeoutSeconds: 1
```
```shell
kubect rolling-update hello --image=hello:v2
```
