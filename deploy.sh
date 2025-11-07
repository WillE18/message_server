#!/bin/bash

# Variables
KEY_PATH=~/.ssh/will_cloud_deployment.pem
EC2_HOST=ec2-user@3.10.175.99
REMOTE_DIR=/home/ec2-user/message-server

# Copy necessary files
echo "> Uploading files to EC2"
scp -i $KEY_PATH app.py requirements.txt Dockerfile $EC2_HOST:$REMOTE_DIR

# Connect and run container
ssh -i $KEY_PATH $EC2_HOST << EOF
  cd message-server
  docker build -t message-server .
  docker stop message-server || true
  docker rm message-server || true
  docker run -p 5002:5002 \
    -e APP_ENV=PRODUCTION \
    -e POSTGRES_USER='${{ secrets.POSTGRES_USER }}' \
    -e POSTGRES_PASSWORD='${{ secrets.POSTGRES_PASSWORD }}' \
    -e POSTGRES_HOST='${{ secrets.POSTGRES_HOST }}' \
    -e POSTGRES_DB='postgres' \
    message-server
EOF

echo "✅ Deployment complete! Visit: http://<your-ec2-ip>:5002"
