def appname = "test-app"
def repo = "dolev1234"  
def appimage = "${repo}/${appname}"
def apptag = "${appimage}:${env.BUILD_NUMBER}" 

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
        
        stage('Build & Push Docker Image') {
            agent {
                docker {
                    image 'docker:26'
                    args '-v /var/run/docker.sock:/var/run/docker.sock'
                }
            }
            steps {
                script {
                    echo "--------------------------------------------------------------"
                    echo "Building docker image..."
                    echo "--------------------------------------------------------------"
                    sh " docker build -t ${apptag} ."
                    sleep 5
                    echo "--------------------------------------------------------------"
                    echo "Docker image built successfully:${apptag}"
                    echo "--------------------------------------------------------------"
                    echo "connting to docker hub"

                    withCredentials([usernamePassword(
                        credentialsId: 'dockerhub1',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_TOKEN'
                    )]) {
                        sh '''
                            echo "$DOCKER_TOKEN" | docker login -u "$DOCKER_USER" --password-stdin
                            echo"--------------------------------------------------------------"
                            echo" connectoin successfully"
                            echo "--------------------------------------------------------------"
                            echo "pushing image ${apptag} to the hub "
                            docker push ${appimage}:${apptag}
                        '''
                    }
                }
            } 
        }

        // Helm
        stage('Deploy with Helm') {
            agent {
                docker {
                    image 'alpine/helm:3.14.0' // אימג' רשמי שמכיל את הפקודות של Helm
                    // אם ה-Helm שלך צריך לגשת לקלאסטר, לרוב ממפים פה את תיקיית ה-kubeconfig. לדוגמה:
                    // args '-v /home/jenkins/.kube:/root/.kube'
                }
            }
            steps {
                echo "------------------------ Running inside HELM container ------------------------"
                // הפקודה הזו תרוץ בתוך קונטיינר ה-Helm שזה עתה נפתח
                sh 'helm version'
                
                // כאן תבוא פקודת ה-deploy האמיתית שלך, למשל:
                // sh "helm upgrade --install ${appname} ./charts --set image.tag=${apptag}"
            } // כאן ג'נקינס אוטומטית סוגר ומכבה את קונטיינר ה-Helm!
        }
    }
}
