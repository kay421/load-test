# load-test

### TL;DR
---
*prerequisits*  
Kubernetes > v1.10.11  
kubectl > v1.10.11  
load test with JMeter 5.1.1

[WIP] I will write someday.

### Make docker image
---
```
./docker_image_create.sh
```

### Make cluster
---
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
---
```
./container_start_test.sh -fsample.jmx
```
If you need specify option for the jmx file.  
You can specied [-G] or [-J] options.  
Please refer to the following for the difference between J option and G option.

[1.4.6 Overriding Properties Via The Command Line](https://jmeter.apache.org/usermanual/get-started.html#override)

e.g. 
```
./container_start_test.sh -fsample2.jmx -GTHREAD=10 -GRAMPUP=10 -GLOOP=1
```

### Get result
---
```
./container_download_result.sh
```
It download result.jtl file to the report directory.  


### scaling
---

#### node

**[todo]** It not support cluster-autoscaling yet.
We need support node scaling.


#### pod
```
kubectl -n [namespace] scale deployment/jmeter-slaves --replicas=4
```
When load test stared, the script get pod IP and set *-R* option to jmeter command line.  
You do not need to look up an IP address or specify it.