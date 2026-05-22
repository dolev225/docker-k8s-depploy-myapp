def appname = "test-app"
def repo = "kfire312"  
def appimage = "${repo}/${appname}"
def apptag = "${env.BUILD_NUMBER}"

pipeline {
    agent {
        node {
            label 'agent2' 
        }
    }
    
    stages {
        stage('Checkout') {
            steps {
                sh '/usr/bin/git config --global http.sslVerify false'
            }
        }
        
        stage('Build & Push Image') {
            steps {
                script {
                    // הדרך הנכונה למנוע תקיעות בקונטיינר מקונן:
                    docker.image('docker:26-dind').inside('--privileged -v /var/run/docker.sock:/var/run/docker.sock') {
                        echo "------------------------ Running Inside ------------------------"
                        sh 'docker --version'
                        // כאן ה-build שלך יעבוד בלי להיתקע
                    }
                }
            }
        }
    }
}
