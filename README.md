# load-test

### Prerequisits
Kubernetes > v1.10.11
kubectl > v1.10.11
load test with JMeter 5.1.1

### TL;DR
[WIP] I will write someday.

### Make docker image
```
./docker_image_create.sh
```

### Make cluster
The following script is make namespace (you must specified it) ,create node, slave replicas and service, and master deployment.
It must fix If you already have cluster.

```
./jmeter_cluster_create.sh
```

Result:

(You can get same result with this command
```
kubectl get -n [namespace] all
```

```
NAME                                 READY     STATUS              RESTARTS   AGE
pod/jmeter-master-XX1-xxx   0/1       ContainerCreating   0          1s
pod/jmeter-slaves-XX2-xxx    0/1       ContainerCreating   0          1s
pod/jmeter-slaves-XX2-xxx    0/1       ContainerCreating   0          1s

NAME                        TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)              AGE
service/jmeter-slaves-svc   ClusterIP   None         <none>        1099/TCP,50000/TCP   1s

NAME                            DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/jmeter-master   1         1         1            0           1s
deployment.apps/jmeter-slaves   2         2         2            0           1s

NAME                                       DESIRED   CURRENT   READY     AGE
replicaset.apps/jmeter-master-XX1   1         1         0         1s
replicaset.apps/jmeter-slaves-XX2    2         2         0         1s
```

### Run load test
```
./container_start_test.sh sample.jmx
```