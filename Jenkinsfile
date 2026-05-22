def appname = "test-app"
def repo = "dolev1234"  
def appimage = "${repo}/${appname}"
def apptag = "${env.BUILD_NUMBER}" 

pipeline {
    agent {
        node {
            label 'agent2' // מתחיל על ה-slave
        }
    }
    
    stages {
        stage('Checkout') {
            steps {
                sh '/usr/bin/git config --global http.sslVerify false'
            }
        }
        
        stage('Build & Push Docker Image Inside Container') {
            steps {
                script {
                    echo "--------------------------------------------------------------"
                    echo "Opening a new Docker container to run the build..."
                    echo "--------------------------------------------------------------"                    
                    
                    // ה-slave פותח קונטיינר חדש של docker:26, ומריץ את ה-build בתוכו!
                    // אנחנו ממפים את ה-WORKSPACE כדי שהקונטיינר החדש יראה את קבצי ה-Git שלך
                    sh """
                        docker run --rm \
                        -v ${WORKSPACE}:/apps \
                        -v /var/run/docker.sock:/var/run/docker.sock \
                        -w /apps \
                        docker:26 docker build -t ${appimage}:${apptag} .
                    """
                    
                    echo "--------------------------------------------------------------"
                    echo "Opening container for Login and Push..."
                    echo "--------------------------------------------------------------"

                    withCredentials([usernamePassword(
                        credentialsId: 'dockerhub1',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_TOKEN'
                    )]) {
                        // ה-slave פותח קונטיינר חדש, מבצע login ו-push מתוכו, ונסגר
                        sh """
                            docker run --rm \
                            -v /var/run/docker.sock:/var/run/docker.sock \
                            docker:26 sh -c '
                                echo "$DOCKER_TOKEN" | docker login -u "$DOCKER_USER" --password-stdin
                                docker push ${appimage}:${apptag}
                            '
                        """
                    }
                }
            } 
        }

        stage('Deploy with Helm Inside Container') {
            steps {
                script {
                    echo "--------------------------------------------------------------"
                    echo "Opening a new Helm container to run the deploy..."
                    echo "--------------------------------------------------------------"
                    
                    // ה-slave פותח קונטיינר חדש של Helm, מריץ את הפקודה בתוכו, ונסגר
                    sh "docker run --rm -v ${WORKSPACE}:/apps -w /apps alpine/helm:3.14.0 version"
                }
            } 
        }
    }
}
