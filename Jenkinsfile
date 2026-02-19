pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "ayush1406/swiggy-clone"
        IMAGE_TAG = "${env.BUILD_NUMBER}"
    }

    stages {

     stage('SonarQube Analysis') {
    steps {
        script {
            def scannerHome = tool 'sonar-scanner'
            withSonarQubeEnv('sonarqube-server') {
                sh """
                ${scannerHome}/bin/sonar-scanner \
                -Dsonar.projectKey=swiggy-clone \
                -Dsonar.sources=. 
                """
            }
        }
    }
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
                kubectl set image deployment/swiggy-clone \
                swiggy=$DOCKER_IMAGE:$IMAGE_TAG
                """
            }
        }
    }
}
