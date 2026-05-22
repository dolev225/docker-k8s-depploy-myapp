
def appname = "dolev-test"
def repo = "dolev1234"  // Replace with your DockerHub username
def appimage = "${repo}/${appname}"
def apptag = "${env.BUILD_NUMBER}"

podTemplate(cloud: 'kubernetes', containers: [
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
        stage('build docker image ${appimage}:${apptag}') {
            
              echo "--------------------------------------------------------------"
              echo "Building docker image..."
              echo "--------------------------------------------------------------"
              sh " docker build -t ${appimage}:${apptag} ."
              sleep 5
              echo "--------------------------------------------------------------"
              echo "Docker image built successfully: ${appimage}:${apptag}"
              echo "--------------------------------------------------------------"

             // sh 'docker run -exec -itd --name ${appname} ${appimage}:${apptag}'
            }
            
        stage('Login and Push') {
                withCredentials([usernamePassword(
                    credentialsId: 'docker-cred',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_TOKEN'
                )]) {

                sh """
                    echo $DOCKER_TOKEN | docker login -u $DOCKER_USER --password-stdin
                    docker push $appimage:$apptag
                """
                    
                }
            }
            
        
        }
    }
  }
