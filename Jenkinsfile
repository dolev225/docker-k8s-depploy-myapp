def appname = "mydolev"
def repo = "dolev1234"  
def appimage = "docker.io/${repo}/${appname}"
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
        stage('chackout') {
            container('jnlp') {
            sh '/usr/bin/git config --global http.sslVerify false'
	    checkout scm
          }
        } // end chackout
        container('docker') {
        stage('Hello') {
            withCredentials([usernamePassword(credentialsId: 'docker-cred',usernameVariable: 'DOCKER_USER',passwordVariable: 'DOCKER_TOKEN' )])
              sh "docker build -t $appname . "
              sh "docker login ${docker-cred}
              sh "docker push "
        } 
    }
 }
stage('Login and Push') {
                withCredentials([usernamePassword(credentialsId: 'docker-cred',usernameVariable: 'DOCKER_USER',passwordVariable: 'DOCKER_TOKEN' )]) {
                sh """
                    echo $DOCKER_TOKEN | docker login -u $DOCKER_USER --password-stdin
                    docker push $appimage:$apptag
                """
                    
                }
            }
    }
