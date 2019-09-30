# The load test with k8s cluster

It can get a load test env with JMeter.  
It is inspire to [GoogleCloudPlatform/distributed-load-testing-using-kubernetes](https://github.com/GoogleCloudPlatform/distributed-load-testing-using-kubernetes) and refer to [kaarolch/kubernetes-jmeter](https://github.com/kaarolch/kubernetes-jmeter).


**prerequisits**  
Kubernetes > v1.10.11  
kubectl > v1.10.11  
eksctl v0.6.0 (or Docker for mac v2.0.0.3)



### Build docker image
---
The following script it is build jmeter master image and jmeter slave image.
If you want to use without local, you must register image somewhere registry service.
 e.g.) ECR,DockerHub
```
./command_docker_image_create.sh
```

### Build EKS with eksctl command
---

Install eksctrl with refer to the guide.
[Getting Started with eksctl
](https://docs.aws.amazon.com/ja_jp/eks/latest/userguide/getting-started-eksctl.html)


```
eksctl create cluster --name <CLUSTER_NAME> \
--region ap-northeast-1 \
--version 1.13 \
--nodegroup-name <WORKER_NODE_NAME> \
--node-type <NODE_INSTANCE_TYPE> \
--nodes <DESIRED_NODES> \
--nodes-min <MINIMUM_NODES> \
--nodes-max <MAX_NODES> \
--node-ami auto \
--vpc-private-subnets=<PRIVARE_SUBNETS_COMMA_SEPARATED>\
--vpc-public-subnets=<PUBLIC_SUBNETS_COMMA_SEPARATED> \
--node-private-networking \
--ssh-public-key=<SSH_KEY>
```

#### ※ cleaning up eks cluster
At first If you attach IAM policy by aws-cli it remove it.  Because eksctl dploy as cloudformaion and it occured the draft.   
※ If you using command_cluster_autoscaler_role_attach.sh, the policy name should be "ASG-Policy-For-Worker".
```
eksctl delete cluster --name <CLUSTER_NAME>
```


### Build JMeter cluster
---
The following script is make namespace (you must specified it), create node, slave replicas and service, and master deployment.

If you want to specify an ECR Image.
You can change this.

L:21 in jmeter_master_deploy.yaml 
```
        image: jmeter-master:latest
```
L:21 in jmeter_slaves_deploy.yaml 
```
        image: jmeter-master:latest
```

create JMeter cluster
```
./command_jmeter_cluster_create.sh
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

#### ※ remove JMeter cluster
The following script delete resource in namespace.
You can delete resources created by command_jmeter_cluster_create.sh

```
./command_jmeter_cluster_delete.sh
```


### Run load test
---
```
./container_start_test.sh -fsample.jmx
```
It need specify jmx file path with [-f] option.  
And If you need specify option for the test scenario.  
You can specied [-G] or [-J] options. 
Please refer to the following for the difference between J option and G option.

[1.4.6 Overriding Properties Via The Command Line](https://jmeter.apache.org/usermanual/get-started.html#override)

e.g. 
```
./container_start_test.sh -fsample.jmx -GTHREAD=10 -GRAMPUP=10 -GLOOP=1
```

### Get the result
---
```
./command_container_download_result.sh
```
It download result.jtl file to the report directory.  


### Scaling 
---

*The settings below uses EKS as prerequisits.*  

#### ※ If you don't need autoscaling the following settings are not required. The node ASG provides when deploy EKS cluster. You can change manualy node number without cluster autoscaling.  
  
If you set the following, it will be possible to auto scaling of nodes by detecting changes in number of pods.  

1.set cluster autoscaler for auto discover  

get cluster autoscaler manifest template
```
wget https://raw.githubusercontent.com/kubernetes/autoscaler/master/cluster-autoscaler/cloudprovider/aws/examples/cluster-autoscaler-autodiscover.yaml
```

change L:148 in cluster-autoscaler-autodiscover.yaml  
```
 --node-group-auto-discovery=asg:tag=k8s.io/cluster-autoscaler/enabled,k8s.io/cluster-autoscaler/<YOUR CLUSTER NAME>
```

You must add asg tag for auto-discovery. It is ok just key.
```
 k8s.io/cluster-autoscaler/enabled
 k8s.io/cluster-autoscaler/<YOUR CLUSTER NAME>
```

change cluster name L:4 in cluster_autoscaler_role_attach.sh  
```
cluster_name="<YOUR CLUSTER NAME>"
```

attach role to nodegroup IAM  
```
./command_cluster_autoscaler_role_attach.sh
```

deploy cluster autoscaler  
```
kubectl apply -f cluster-autoscaler-autodiscover.yaml
```

#### scaling pods
The cluster autoscaler detect "Pending" state of pod or excess and deficiency.
Just change the number of replicas.
```
kubectl -n [namespace] scale deployment/jmeter-slaves --replicas=4
```