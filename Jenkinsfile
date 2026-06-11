

properties([
    parameters([
        choice(
            name: 'TARGET_ENV',
            choices: ['dev', 'qa', 'prod'],
        )
    ])
])




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
        image: 'cytopia/bandit:latest', 
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
    
    node(POD_LABEL) {
        
        stage('check SCM') {
            container('jnlp') {
                echo "Checking out code from Git..."
                checkout scm 
            }
        } 
        
        stage('Linting') {
            parallel(
                'flake8 check': {
                    echo "Running flake8 command..."
                },
                'Shell check': {
                    echo "Running Shell check..."
                },
                'Hadolint Check': {
                    echo "Running Hadolint command..."
                }
            )
        }
        
        stage('Build & Security (Parallel)') {
            parallel(
                'Docker Build': {
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
                },
                'Trivy Scan': {
                    container('trivy') {
                        echo "Running Trivy File System Scan..."
                        sh "trivy fs . --exit-code 0"
                    }
                },
                'Bandit Scan': {
                    container('bandit') {
                        echo "Running Bandit Scan "
                        sh "bandit -r . -s B311,B104"
                    }
                }
            )// end of parallel
        } 
        
        stage('Push Image') {
            container('docker') {  
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub1',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_TOKEN'
                )]) {
                    sh """
                        echo \$DOCKER_TOKEN | docker login -u \$DOCKER_USER --password-stdin
                        docker push ${appimage}:${apptag}
                    """
                }
            }
        } // end of push image
            
        stage('Helm Install') {
            container('helm') {
                echo "--------------------------------------------------------------"
                echo "Running Helm Template..."
                echo "--------------------------------------------------------------"
                sh "helm template ${appname} ./chart"
            }
        }// end of helm install
        
        stage('push to argoCD') {
            container('helm') {
                def selectedEnv = params.TARGET_ENV
                echo "Deploying to environment: ${selectedEnv}"

                withCredentials([usernamePassword(
                    credentialsId: 'github-argoCD',
                    usernameVariable: 'git_USER',
                    passwordVariable: 'git_TOKEN'
                )]) {
                    sh "helm template ${appname} ./chart --set image.repository=${repo}/${appname} --set image.tag=${BUILD_NUMBER} > devops-template.yaml"
                    sh "git clone https://github.com/dolev225/argoCD.git"
            dir('argoCD') {
                sh "mv ../devops-template.yaml ./${selectedEnv}/devops-template.yaml"
                
                sh "git config --global user.name 'Jenkins Bot'"
                sh "git config --global user.email 'jenkins-bot@example.com'"
                sh "git config --global --add safe.directory \$(pwd)"
                
                sh "git add ${selectedEnv}/devops-template.yaml"
                sh """git commit -m "Deploy version ${env.BUILD_NUMBER} to ${selectedEnv}" || echo "No changes to commit" """
                sh "git push https://x-access-token:${git_TOKEN}@github.com/dolev225/argoCD.git HEAD:main"
                    }
                }
            }
        } // end of push to argoCD
    } // end of node
} // end of podTemplate
