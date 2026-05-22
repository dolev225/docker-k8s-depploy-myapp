def appname = "test-app"
def repo = "dolev1234"  
def appimage = "${repo}/${appname}" // dolev1234/test-app
def apptag = "${env.BUILD_NUMBER}"  // רק מספר הבילד (למשל: 24)

pipeline {
    agent {
        node {
            label 'agent2' // רץ על הסוכן הקבוע שלך
        }
    }
    
    stages {
        stage('Checkout') {
            steps {
                sh '/usr/bin/git config --global http.sslVerify false'
            }
        }
        
        stage('Build & Push Docker Image') {
            steps {
                script {
                    echo "--------------------------------------------------------------"
                    echo "Building docker image: ${appimage}:${apptag}"
                    echo "--------------------------------------------------------------"                    
                    
                    // הרצה ישירה על ה-Node מונעת את התקיעה
                    sh "docker build -t ${appimage}:${apptag} ."
                    
                    sleep 5
                    echo "--------------------------------------------------------------"
                    echo "Docker image built successfully: ${appimage}:${apptag}"
                    echo "--------------------------------------------------------------"
                    echo "Connecting to Docker Hub..."

                    withCredentials([usernamePassword(
                        credentialsId: 'dockerhub1',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_TOKEN'
                    )]) {
                        sh """
                            echo "\$DOCKER_TOKEN" | docker login -u "\$DOCKER_USER" --password-stdin
                            echo "--------------------------------------------------------------"
                            echo "Connection successful"
                            echo "--------------------------------------------------------------"
                            echo "Pushing image ${appimage}:${apptag} to the hub..."
                            echo "--------------------------------------------------------------"
                            
                            sh "docker push ${appimage}:${apptag}"
                            
                            echo "--------------------------------------------------------------"
                            echo "Push to docker hub successful"
                            echo "--------------------------------------------------------------"
                        """
                    }
                }
            } 
        }

        stage('Deploy with Helm') {
            steps {
                script {
                    echo "------------------------ Running inside HELM container ------------------------"
                    
                    // מרימים קונטיינר זמני וממפים בצורה מפורשת את ה-WORKSPACE של ג'נקינס
                    sh "docker run --rm -v ${WORKSPACE}:/apps -w /apps alpine/helm:3.14.0 version"
                    
                    // פקודת ה-deploy העתידית שלך תיראה ככה בהמשך:
                    // sh "docker run --rm -v ${WORKSPACE}:/apps -w /apps -v /home/jenkins/.kube:/root/.kube alpine/helm:3.14.0 upgrade --install ${appname} ./charts --set image.tag=${apptag}"
                }
            } 
        }
    }
}
