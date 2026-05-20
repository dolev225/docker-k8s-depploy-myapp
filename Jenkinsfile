def appname = "webapi"
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

        stage('Hello') {
            container('docker') {
              sh "docker build -it $appname . "
              sh "echo docker push ${appimage} ${env.BUILD_NUMBER}"
            }
        } //end hello
    }
}
