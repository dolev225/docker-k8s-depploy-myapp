def branch = env.BRANCH_NAME
def build = env.BUILD_NUMBER
def DEBUG = true
def DEPLOY = false


def kubernetesurl = "https://kubernetes.default.svc"


podTemplate(cloud: 'kubernetes', containers: [
    containerTemplate(
        name: 'jnlp', 
        image: 'jenkins/inbound-agent:latest'
    ),
    containerTemplate(
        name: 'helm', 
        image: 'alpine/helm:3.14.0'
    ),
     containerTemplate(
        name: 'docker', 
        image: 'docker:26-dind', // Use the latest stable DinD image
        privileged: true,      // Essential for Docker daemon to run
        args: '--storage-driver=vfs' // VFS is safest for K8s, though slower
    )], 
  volumes: [
    emptyDirVolume(mountPath: '/var/lib/docker', memory: false) // Q: Why do we need this volume?
  ]) {
    node(POD_LABEL) {
        stage('chackout') {
            container('jnlp') {
                echo "checkout"
          }
        } // end chackout
        stage('build') {
            container('docker'){
             echo "--------------------------------------------------------------"
                echo "Building docker image..."
                echo "--------------------------------------------------------------"
                sh " docker build -t ${appimage}:${apptag} ."
                sleep 5
                echo "--------------------------------------------------------------"
                echo "Docker image built successfully: ${appimage}:${apptag}"
                echo "--------------------------------------------------------------"
                }
        stage (push){

                withCredentials([usernamePassword(credentialsId: 'docker-cred',usernameVariable: 'DOCKER_USER',passwordVariable: 'DOCKER_TOKEN')]) 

                echo "--------------------------------------------------------------"
                echo "Docker login" 
                echo "--------------------------------------------------------------"
                sh "echo $DOCKER_TOKEN | docker login -u $DOCKER_USER --password-stdin"
                echo "--------------------------------------------------------------"
                echo "Docker login successfully"
                echo "--------------------------------------------------------------"
                echo "--------------------------------------------------------------"
                echo "Docker push to docker hub "
                echo "--------------------------------------------------------------"
                sh    "docker push $appimage:$apptag"
                echo "--------------------------------------------------------------"
                echo "Docker image built successfully: ${appimage}:${apptag}"
                echo "--------------------------------------------------------------"
                }
            }
    } //end build

        stage('helm install') 
        container('helm'){
             {
                sh """ 
                apk add --no-cache curl bash
                curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4 
                chmod 700 get_helm.sh 
                ./get_helm.sh
                helm template ${appname} helm-charts/
                """
             }
           }
} //end deploy
