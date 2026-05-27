def appname = "test-2"
def repo = "dolev1234" 
def appimage = "${repo}/${appname}"
def apptag = "${env.BUILD_NUMBER}"


def kubernetesurl = "https://kubernetes.default.svc"

podTemplate(cloud: 'kubernetes', containers: [
    containerTemplate(
        name: 'jnlp', 
        image: 'jenkins/inbound-agent:latest'
    ),
    containerTemplate(
        name: 'helm', 
        image: 'alpine/helm:3.14.0',
        command: 'sleep',
        args: '99d'
    ),
    containerTemplate(
        name: 'bandit',
        image: 'pyupio/bandit:latest',
        command: 'sleep',
        args: '99d'
    ),
    containerTemplate(
        name: 'trivy',
        image: 'aquasec/trivy:latest',
        command: 'sleep',
        args: '99d'
    ),
    containerTemplate(
        name: 'docker', 
        image: 'docker:26-dind', 
        privileged: true,      
        args: '--storage-driver=vfs' 
    )], 
  volumes: [
    emptyDirVolume(mountPath: '/var/lib/docker', memory: false) 
  ]) {
    
(Pipeline Stages)
    node(POD_LABEL) {
        
        stage('check SCM ') {
            container('jnlp') {
                echo "Checking out code from Git..."
                checkout scm 
            }
        } 
        stage ('Linting')(
            parallel(
                stage('flask8 check')
                    (
                    echo "flask8 command"
                    )
                stage('Shell check')
                    (
                    echo "Shell command"
                    )
                stage('Hadolint Check')
                    (
                    echo "Hadolint command"
                    )
            )    
        ) //end of 'check code'
            stage('build')
            parallel{ {
                container('docker') { 
                echo "--------------------------------------------------------------"
                echo "Building docker image..."
                echo "--------------------------------------------------------------"
                sh "docker build -t ${appimage}:${apptag} ."
                sleep 5
                echo "--------------------------------------------------------------"
                echo "Docker image built successfully: ${appimage}:${apptag}"
                echo "--------------------------------------------------------------"
            }
            stage ('Security Scanning'){
            parallel{
            container('trivy'){
                stage('Trivy Check')
                {
                sh "trivy image ."
                }
            }
            container('bandit'){
                stage('Bandit Check')
                    {
                    sh "bandit -r ."
                    }
            }   
            }\\ end of Security Scanning
        }   
    }   
}
            container('docker') {  
            stage('push') {
               withCredentials([usernamePassword(
                    credentialsId: 'dockerhub1',
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
            
        stage('helm install') {
            container('helm') {
                echo "--------------------------------------------------------------"
                echo "Running Helm Template..."
                echo "--------------------------------------------------------------"
                sh "helm template ${appname} ./chart"
            }
        } // end of helm
    } // end of label
  }
