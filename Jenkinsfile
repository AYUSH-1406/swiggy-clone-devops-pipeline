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

        stage('Configure Kubeconfig') {
            steps {
                sh "aws eks update-kubeconfig --region ap-south-1 --name swiggy-cluster"
            }
        }

        stage('Initial Setup If Not Exists') {
            steps {
                script {
                    def svcExists = sh(
                        script: "kubectl get svc swiggy-active --ignore-not-found",
                        returnStdout: true
                    ).trim()

                    if (!svcExists) {
                        echo "First time deployment. Creating full infrastructure..."

                        sh """
                        kubectl apply -f k8s/blue-deployment.yaml
                        kubectl apply -f k8s/green-deployment.yaml
                        kubectl apply -f k8s/service.yaml
                        kubectl apply -f k8s/ingress.yaml
                        kubectl apply -f k8s/hpa.yaml
                        """

                        env.FIRST_DEPLOY = "true"
                    } else {
                        env.FIRST_DEPLOY = "false"
                    }
                }
            }
        }

        stage('Blue-Green Deployment') {
            when {
                expression { env.FIRST_DEPLOY == "false" }
            }
            steps {
                script {
                    def activeColor = sh(
                        script: "kubectl get svc swiggy-active -o jsonpath='{.spec.selector.version}'",
                        returnStdout: true
                    ).trim()

                    if (activeColor == "blue") {
                        env.NEW_COLOR = "green"
                    } else {
                        env.NEW_COLOR = "blue"
                    }

                    echo "Active Color: ${activeColor}"
                    echo "Deploying to: ${env.NEW_COLOR}"
                }

                sh """
                kubectl set image deployment/swiggy-${env.NEW_COLOR} \
                swiggy=$DOCKER_IMAGE:$IMAGE_TAG
                """

                sh "kubectl rollout status deployment/swiggy-${env.NEW_COLOR}"

                sh """
                kubectl patch service swiggy-active \
                -p '{"spec":{"selector":{"app":"swiggy","version":"${env.NEW_COLOR}"}}}'
                """
            }
        }

        stage('Deployment Complete') {
            steps {
                echo "🚀 Deployment Successful!"
            }
        }
    }
}
