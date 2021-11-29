pipeline{
agent {
    node {
        label 'node1'
        customWorkspace '/home/ec2-user/slave'
    }
 }
 
  environment {
	REPOSITORY_URL = '494989341217.dkr.ecr.us-east-2.amazonaws.com/ecsrepo'
        TASK_DEFINITION_NAME = 'lerni'
        CLUSTER_NAME = 'mycluster'
        SERVICE_NAME = 'myecsservice'
        IMAGE_TAG = 'e5a811bb'
        TASK_ROLE_ARN = 'arn:aws:iam::494989341217:role/ecsTaskExecutionRole'
        AWS_DEFAULT_REGION = 'us-east-2'

      }
    
    stages {
         stage('install') {
            steps {
              sh '''
	      sudo amazon-linux-extras install epel -y
              sudo yum install jq -y
              sudo yum install unzip -y
              curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
              unzip awscliv2.zip
              sudo ./aws/install
              aws --version
	      '''
	      }

	   }
stage ('scm') {
              steps {
	   git 'https://github.com/DineshYazali/ecs-lerni.git'
	     }
	  }


stage('build') {
            steps {
                
                withAWS(credentials: 'AWS CREDS', region: 'us-east-2') {
	        sh '''
		docker login --username AWS -p $(aws ecr get-login-password --region us-east-2) 494989341217.dkr.ecr.us-east-2.amazonaws.com
		echo "Building image..."
                docker build -t $REPOSITORY_URL:latest .
                echo "Tagging image..."
                docker tag $REPOSITORY_URL:latest $REPOSITORY_URL:v4
                echo "Pushing image..."
                docker push $REPOSITORY_URL:latest
                docker push $REPOSITORY_URL:v4
                
                '''
            }
        }
}
	   
    
    stage('Deploy') {
        steps {
            withAWS(credentials: 'AWS CREDS', region: 'us-east-2') {
            sh '''
            echo $REPOSITORY_URL:$IMAGE_TAG
            TASK_DEFINITION=$(aws ecs describe-task-definition --task-definition "$TASK_DEFINITION_NAME" --region "${AWS_DEFAULT_REGION}")
            NEW_CONTAINER_DEFINTIION=$(echo $TASK_DEFINITION | jq --arg IMAGE "$REPOSITORY_URL:$IMAGE_TAG" '.taskDefinition.containerDefinitions[0].image = $IMAGE | .taskDefinition.containerDefinitions[0]')
            echo "Registering new container definition..."
            aws ecs register-task-definition --region "${AWS_DEFAULT_REGION}" --family "${TASK_DEFINITION_NAME}" --container-definitions "${NEW_CONTAINER_DEFINTIION}" --memory 512 --cpu 256 --requires-compatibilities FARGATE --network-mode awsvpc --task-role-arn "${TASK_ROLE_ARN}" --execution-role-arn "${TASK_ROLE_ARN}"
            echo "Updating the service..."
            aws ecs update-service --region "${AWS_DEFAULT_REGION}" --cluster "${CLUSTER_NAME}" --service "${SERVICE_NAME}"  --task-definition "${TASK_DEFINITION_NAME}"
            
            '''
        }
    }
    
    }
    
    }
    
}    
