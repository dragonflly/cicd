### add credentials by jenkins CLI
# github username and password
java -jar jenkins-cli.jar -auth admin:118befc41e873f41075d9d91df39c33812 -s http://localhost:8080/ create-credentials-by-xml system::system::jenkins _ < github.xml

# github token
java -jar jenkins-cli.jar -auth admin:118befc41e873f41075d9d91df39c33812 -s http://localhost:8080/ create-credentials-by-xml system::system::jenkins _ < GITHUB_TOKEN.xml

# dockerhup username and password
java -jar jenkins-cli.jar -auth admin:118befc41e873f41075d9d91df39c33812 -s http://localhost:8080/ create-credentials-by-xml system::system::jenkins _ < DockerHub-UP.xml


### install plugin by jenkins CLI
# Environment Injector
java -jar jenkins-cli.jar -auth admin:118befc41e873f41075d9d91df39c33812 -s http://localhost:8080/ install-plugin envinject

# Git Parameter
java -jar jenkins-cli.jar -auth admin:118befc41e873f41075d9d91df39c33812 -s http://localhost:8080/ install-plugin git-parameter

# Job DSL
java -jar jenkins-cli.jar -auth admin:118befc41e873f41075d9d91df39c33812 -s http://localhost:8080/ install-plugin job-dsl

# Active Choices
java -jar jenkins-cli.jar -auth admin:118befc41e873f41075d9d91df39c33812 -s http://localhost:8080/ install-plugin uno-choice

# build user vars
java -jar jenkins-cli.jar -auth admin:118befc41e873f41075d9d91df39c33812 -s http://localhost:8080/ install-plugin build-user-vars-plugin

# aws steps
java -jar jenkins-cli.jar -auth admin:118befc41e873f41075d9d91df39c33812 -s http://localhost:8080/ install-plugin pipeline-aws

# Sonarqube scanner
java -jar jenkins-cli.jar -auth admin:118befc41e873f41075d9d91df39c33812 -s http://localhost:8080/ install-plugin sonar

# restart jenkins
java -jar jenkins-cli.jar -auth admin:118befc41e873f41075d9d91df39c33812 -s http://localhost:8080/ safe-restart


