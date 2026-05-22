def appname = "test-app"
def repo = "dolev1234"  
def appimage = "${repo}/${appname}"

// שימוש במרכאות כפולות כדי שהערך של BUILD_NUMBER יתורגם כראוי
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
        
        stage('Build Image') {
            steps {
                script {
                    echo "--------------------------------------------------------------"
                    echo "Building docker image..."
                    echo "--------------------------------------------------------------"
                    
                    // בניית האימג' עם השם והתג הנכונים
                    sh "docker build -t ${appimage}:${apptag} ."
                    
                    sleep 5
                    echo "--------------------------------------------------------------"
                    echo "Docker image built successfully: ${appimage}:${apptag}"
                    echo "--------------------------------------------------------------"
                }
            }
        }

        stage('Login and Push') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub1',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_TOKEN'
                )]) {
                    // הפרדה של הפקודות ושימוש ב-Double Quotes בשביל משתני ה-Credentials
                    sh """
                        echo "${DOCKER_TOKEN}" | docker login -u "${DOCKER_USER}" --password-stdin
                        docker push ${appimage}:${apptag}
                    """
                }
            }
        }
    }
}
