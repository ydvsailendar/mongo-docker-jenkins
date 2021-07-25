#!/usr/bin/env groovy
pipeline {
    agent any
    environment {
      DOCKER_TAG = getVersion()
    }
    stages{
        stage("SCM"){
            steps{
                git 'https://github.com/ydvsailendar/mongo-docker-jenkins'
            }
        }
        stage("Docker Build"){
            steps{
                sh "docker build . -t task:${DOCKER_TAG}"
            }
        }
        stage("Docker Run"){
            steps{
                sh "docker run -d --net=host -p 5000:5000 task:${DOCKER_TAG}"
            }
        }
        stage("Docker Image Cleanup"){
            steps{
                sh "docker image prune -a --force --filter 'until=1h'"
            }
        }
    }
}

def getVersion(){
    def commitHash = sh returnStdout: true, script: 'git rev-parse --short HEAD'
    return commitHash
}

