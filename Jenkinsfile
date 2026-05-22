
def appname = "test-app"
def repo = "dolev1234"  // Replace with your DockerHub username
def appimage = "${repo}/${appname}"
def apptag = "${appname}:${env.BUILD_NUMBER}"

podTemplate(containers: [
    containerTemplate(
        name: 'jnlp', 
        image: 'jenkins/inbound-agent:latest'
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
        stage('checkout') {
            container('jnlp') {
            sh '/usr/bin/git config --global http.sslVerify false'
	    checkout scm
          }
        } // end checkout
        container('docker') {
        stage('build docker image ${apptag}') {
            
              echo "--------------------------------------------------------------"
              echo "Building docker image..."
              echo "--------------------------------------------------------------"
              sh "echo " docker build -t ${apptag}.""
              sleep 5
              echo "--------------------------------------------------------------"
              echo "Docker image built successfully: ${apptag}"
              echo "--------------------------------------------------------------"

             // sh 'docker run -exec -itd --name ${appname} ${appimage}:${apptag}'
            }
        }
    }
  }
