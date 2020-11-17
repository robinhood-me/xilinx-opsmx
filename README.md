# xilinx-opsmx

this repo: https://github.com/robinhood-me/xilinx-opsmx
application we deploy in this pipeline repo: https://github.com/OpsMx/issue-generator

Image link to show application landing page here.

Demo app for Xilinx

Description. Deploy an application that generates issues for testing purposes.

Prerequisites: Spinnaker 1.2x.y deployed on Kubernetes 1.16x, access to spinnaker ui.
Access to kubectl command line. In a local Kubernetes cluster this might be on your kubernetes master node. In GCP this is through the gcloud SDK installed locally or via the GCP console in the terminal window. Elasticsearch,prometheus and kibana are also available.

Table of Contents
Stages:
stage 0: Configuration
stage 1: build
stage 2: dockerstage
stage 3: Deploy
stage 4: load
stage 5: check the Issue Generator application via external IP.

stage 0: Configuration

Note: saves time to find the lastest github repo commit ID and enter it under parameters section. Otherwise each time you execute the pipeline you have to enter it manually.

github repo with application: 

Tool integrations and secrets needed:

NOTE: There are places in the manifests that need to have values changed
- the environment name that you have Spinnaker deployed to, Kubernetes defaults to `default` but you might have specified an environment when you deployed spinnaker.
- 

JENKINS
Jenkins to apply load. \
Have jenkins configured
Configure Jenkins for load: https://spinnaker.io/setup/ci/jenkins/
Configure Autopilot
App - HelloWorld, create app diff from Spinnaker
Service - template we create that references it. So autopilot can do verification, it’s a monitor. 
Datasource, prometheus`
Configure configmaps

KANIKO SECRET





Name of the persistent volume claim created in the cluster needs to match that in the configure stage manifest. ??

Spinnaker configuration: via halyard
 kubectl -n spin get pods | grep halyard-0

 kubectl -n spin cp orca-local.yml <halyard pod name>:/home/spinnaker/default/profiles

Copy orca-local.yml to the /home/spinnaker/default/profiles directory in halyard pod.

 kubectl exec -it <halyard pod name> bash
  hal deploy apply

Configure orca-local for docker stage.

 kubectl get pods -w
Run hal deploy apply inside halyard pod. Wait for the pod to restart.


Create Application and Pipeline:

Use default namespace of default kubernetes account for this example.

Step 0. To create necessary config maps, secrets,and pvc, please edit the username and password fields in the secret before applying.

kubectl apply -f build-cm-pvc-secret.yml ( sent separately as attachment)

Step 1. Go to https://demo.opsmx.com/#/applications , click on Create Application button.
The following pop up appears…



Step 2. Fill in the name of the application, email address and choose kubernetes as the cloud provider. Click on Create.


Step 3. Click on the Pipelines tab, and click on the create button to create a new pipeline.










Step 4. The following pop up appears


Fill in the name of the pipeline. Click on Create.

Step 5. Click on drop down, Pipeline Actions, and choose Edit as json option as shown.



Step 6. Replace parameters in the pipeline json sent to you, according to the doc editing json.
Replace multiclouddemo ( in four places) with the name given to the application created above
Replace github.com/OpsMx/issue-generator.git with your clone of this repo
Replace http://autopilot-demo.opsmx.com:8090 with the url for your autopilot.
Replace OpsMxUser with a user that has permissions to run autopilot.


Step 7.
Replace the json in the pop-up window with the pipeline json edited in the previous step..




Ste 8. Click on Update Pipeline button. Then click on Save Changes button (bottom right).

Step 9. From the pipeline tab, click on Start Manual Execution to start the pipeline.

Step 10. Click on each stage to find the progress and status.

EFK Installation:
https://github.com/OpsMx/EFK-On-Docker

Autopilot Configuration:
Create Elastic Datasource: https://docs.opsmx.com/autopilot/analysis-setup/data-sources
Add Application: https://docs.opsmx.com/autopilot/analysis-setup/applications
Add log template: https://docs.opsmx.com/autopilot/analysis-setup/templates/log-template


MISC
My Notes

Personal Github access token for Spinnaker trigger artifact constraints field
ef3768104031e102bb0a997adb8a7d93d54189db
kubectl -n robin exec -it oes32-spinnaker-halyard-0 -- /bin/bash
/home/spinnaker/.hal/token

DEMO

Setup prerequisites
- Create a Persistent Volume and Persistent Volume Claim (name must match
- Create NFS server in docker container which shares 
- https://github.com/OpsMx/spinnakersummit-2020/tree/main/nfs

Open ITerm2 window
gcloud alpha cloud-shell ssh
gcloud config set project robin-opsmx-oes
kubectl get pods -n robin
gcloud auth login
- copy link, paste it into browser, get code and paste in ITerm2 window
helm repo add stable https://kubernetes-charts.storage.googleapis.com/
helm install -n nfs nfs-server stable/nfs-server-provisioner --set persistence.enabled=true,persistence.size=10Gi

kubectl apply -f - <<EOF
apiVersion: v1
kind: PersistentVolume
metadata:
  name: robin-pv-volume
  labels:
    type: local
spec:
  storageClassName: nfs
  capacity:
    storage: 4Gi
  accessModes:
    - ReadWriteMany
  hostPath:
    path: "/mnt/data"
EOF

helm repo add stable https://kubernetes-charts.storage.googleapis.com/
helm repo list
NAME  	URL
opsmx 	https://helmcharts.opsmx.com/
stable	https://kubernetes-charts.storage.googleapis.com/
helm install -n nfs nfs-server stable/nfs-server-provisioner --set persistence.enabled=true,persistence.size=1Gi

helm install -n robin github-stable/nfs-server-provisioner --set persistence.enabled=true,persistence.size=1Gi

helm repo add github-stable https://charts.helm.sh/stable

 helm repo update
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "opsmx" chart repository
...Successfully got an update from the "stable" chart repository
...Successfully got an update from the "github-stable" chart repository

 helm install -n robin github-stable/nfs-server-provisioner --set persistence.enabled=true,persistence.size=1Gi --generate-name
WARNING: This chart is deprecated
NAME: nfs-server-provisioner-1605564922
LAST DEPLOYED: Mon Nov 16 22:15:26 2020
NAMESPACE: robin
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
The NFS Provisioner service has now been installed.

A storage class named 'nfs' has now been created
and is available to provision dynamic volumes.

You can use this storageclass by creating a `PersistentVolumeClaim` with the
correct storageClassName attribute. For example:

    ---
    kind: PersistentVolumeClaim
    apiVersion: v1
    metadata:
      name: test-dynamic-volume-claim
    spec:
      storageClassName: "nfs"
      accessModes:
        - ReadWriteMany
      resources:
        requests:
          storage: 100Mi




ARTIFACTORY
https://opsmx1.jfrog.io/
username=robin
Goyanks#2416


changing namespace to your cluster namespace (e.g. from robin to your Spinnaker namespace)

JENKINS
The jenkins stage is just for running tests, 
opsmx jenkins creds
url : http://jenkins.opsmx.net:8181/jenkins/
   username: opsmxspin
   password:  Bumblebee@321$

hal config ci jenkins enable
echo $APIKEY | hal config ci jenkins master add my-jenkins-master \ --address $BASEURL \ --username $USERNAME \ --password # api key will be read from STDIN to avoid appearing 
# in your .bash_history 
hal config ci jenkins enable

117a7ea3dcf1be7844d304c1aab7d4935e

echo $APIKEY | hal config ci jenkins master add my-jenkins-master \ --address http://jenkins.opsmx.net:8181/jenkins/ \ --username opsmxspin \ --password 

 hal config ci jenkins master get my-jenkins-master
+ Get current deployment
  Success
+ Get the my-jenkins-master master
  Success
Validation in default:
? https://www.spinnaker.io/community/releases/versions/

JenkinsMaster(address=http://jenkins.opsmx.net:8181/jenkins/, username=opsmxspin, password=117a7ea3dcf1be7844d304c1aab7d4935e, csrf=null, trustStore=null, trustStoreType=null, trustStorePassword=null)

kubectl apply -f - <<EOF
---
    kind: PersistentVolumeClaim
    apiVersion: v1
    metadata:
      name: robin-pvc-claim
      namespace: robin
    spec:
      storageClassName: "nfs"
      accessModes:
        - ReadWriteMany
      resources:
        requests:k
          storage: 100Mi
EOF

 k get pvc -n robin
NAME                                       STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
data-nfs-server-provisioner-1605564922-0   Bound    pvc-41912333-84f3-4b30-9c8f-0a8ad5a45044   1Gi        RWO            standard       22m
halyard-home-oes32-spinnaker-halyard-0     Bound    pvc-784b076f-9455-4b6b-ad19-09d57a17c607   10Gi       RWO            standard       5d12h
oes-db-postgresql-oes-db-0                 Bound    pvc-fd59717d-bd64-4ae8-9450-72af1ff4ac50   8Gi        RWO            standard       5d12h
oes32-minio                                Bound    pvc-84cc6d3d-490b-4a68-b95d-b2d80184f87d   10Gi       RWO            standard       4d22h
oes32-openldap                             Bound    pvc-a6edc3f0-6a1f-4335-b131-2c34bec15b94   8Gi        RWO            standard       4d22h
redis-data-oes32-redis-master-0            Bound    pvc-02971af1-1b2f-434a-8610-95913ee67382   8Gi        RWO            standard       5d12h
robin-pvc-claim                            Bound    pvc-455bb4ba-74f4-4166-ac01-3395753df55f   100Mi      RWX            nfs            12s

the latest commit OpsMx/issue-generator
d94f5f48ffb37dd3a54f001a65550e11618658a9

kubectl delete pods <pod> --grace-period=0 --force
kubectl delete -n robin pods gradle-issugen-3fe7c07feb66fa35-x62f5 --grace-period=0 --force
etc

Name of the persistent volume claim created in the cluster needs to match that in the configure stage manifest.

cut from Analytics pipeline config manifest bottom

 - configMap:
            defaultMode: 420
            name: issugen-gradle-script
          name: initscript

robin_hood@cloudshell:~ (robin-opsmx-oes)$ k logs -n robin -f  gradle-issugen-3fdec7fce9f46c66-4nqrm

change values in orca.yml
CREATE KANIKO SECRET
echo -n robinhoodhooe:r007007R | base64
create config.json with object block locally

{
	"auths": {
		"https://index.docker.io/v1/": {
			"auth": "cm9iaW5ob29kaG9vZTpyMDA3MDA3Ug=="
		}
	}

kubectl -n robin create secret generic kaniko --from-file=config.json=config.json

k get secret -n robin -o yaml kaniko

k -n robin cp orca-local.yml oes32-spinnaker-halyard-0:/home/spinnaker/.hal/default/profiles/

create a dockerjob-claim

apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: dockerjob-claim
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 3Gi
  storageClassName: default
  volumeMode: Filesystem

d94f5f48ffb37dd3a54f001a65550e11618658a9
d94f5f48ffb37dd3a54f001a65550e11618658a9

k -n robin get endpoints

service and replicaset is connected by selector app=kubecanary

AUTOPILOT  
Our Autopilot app
https://oes-demo.opsmx.com/policymanagement Admin/opsmx@123

Template
- service
- datasource
- log template
- Also available is Elasticsearch and kibana

