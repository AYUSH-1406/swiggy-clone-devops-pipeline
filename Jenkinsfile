pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "ayush1406/swiggy-clone"
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        SCANNER_HOME = tool 'sonar-scanner'
    }

    stages {

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonarqube-server') {
                    sh """
                    $SCANNER_HOME/bin/sonar-scanner \
                    -Dsonar.projectKey=swiggy-clone \
                    -Dsonar.sources=.
                    """
                }
            }
        }

        stage("Quality Gate") {
            steps {
                timeout(time: 2, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        // stage('Install Dependencies') {
        //     steps {
        //         sh 'npm install'
        //     }
        // }

        stage('OWASP Dependency Check') {
            steps {
                dependencyCheck additionalArguments: '--scan .',
                odcInstallation: 'dependency-check'

                dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t $DOCKER_IMAGE:$IMAGE_TAG ."
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh """
                    echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                    docker push $DOCKER_IMAGE:$IMAGE_TAG
                    """
                }
            }
        }

     stage('Deploy to EKS') {
    steps {
        sh """
        aws eks update-kubeconfig --region ap-south-1 --name swiggy-cluster

        if kubectl get deployment swiggy-clone > /dev/null 2>&1; then
            echo "Deployment exists. Updating image..."
            kubectl set image deployment/swiggy-clone \
            swiggy=$DOCKER_IMAGE:$IMAGE_TAG
        else
            echo "Deployment not found. Applying manifests..."
            kubectl apply -f k8s/
        fi
        """
    }
}
    }
}
