def appname = "test-app"
def repo = "dolev1234"  
def appimage = "${repo}/${appname}"
def apptag = "${env.BUILD_NUMBER}"

pipeline {
    stages {
        stage('Checkout') {
            steps {
                sh '/usr/bin/git config --global http.sslVerify false'
            }
        }
        
        stage('Build & Push Image') {
            steps {
                script {
                    sh 'ehco ${repo}'
                    
                }
            }
        }
    }
}
