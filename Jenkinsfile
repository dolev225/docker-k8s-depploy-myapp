def appname = "mydolev"
def repo = "dolev1234"  
def appimage = "docker.io/${repo}/${appname}"
def apptag = "${env.BUILD_NUMBER}"

podTemplate(cloud: 'kubernetes', containers,helm: [
    containerTemplate(
        name: 'jnlp', 
        image: 'jenkins/inbound-agent:latest'
    ),
    containerTemplate(
        name: 'docker', 
        image: 'docker:26-dind', 
        privileged: true,      
        args: '--storage-driver=vfs' 
    )
    containerTemplate(
        name: 'helm',
        image: 'alpine/helm:3.14.0',
        ttyEnabled: true,
        command: 'cat'
    )
    ], 
  volumes: [
    emptyDirVolume(mountPath: '/var/lib/docker', memory: false) 
  ]) {
    
    node(POD_LABEL) {
        
        stage('Checkout') {
            container('jnlp') {
                sh 'git config --global http.sslVerify false'
                checkout scm
            }
        } 

        stage('Docker Build') {
            container('docker') {
                // Tagging it with the full registry name so it can be pushed later
                sh "docker build -t ${appimage}:${apptag} ."
            } 
        }

        stage('Docker Push') {
            container('docker') {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_TOKEN')]) {
                    sh """
                    echo \$DOCKER_TOKEN | docker login -u \$DOCKER_USER --password-stdin
                    docker push ${appimage}:${apptag}
                    """
                } 
            }
        }

        stage('Helm Install') {
            container('helm') {
                 sh "helm upgrade --install ${appname} ./chart"
            }
        }
    } // end node
} // end podTemplate
