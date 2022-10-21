### ssh to jenkins server by baston host, clone cicd repo
git clone https://github.com/dragonflly/cicd.git
cd cicd/aws/tools/config-jenkins

### unlock jenkins from web console
jenkins.ning-cicd.click
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
install suggested plugins

### create jenkins admin token
admin -> configure -> API Token -> add new token
118befc41e873f41075d9d91df39c33812

### replace jenkins token in jenkins-CLI.sh

### download jenkins-cli.jar
wget http://localhost:8080/jnlpJars/jenkins-cli.jar

### replace token, and restart jenkins
java -jar jenkins-cli.jar -auth admin:118befc41e873f41075d9d91df39c33812 -s http://localhost:8080/ safe-restart

### run scripts to config jenkins server
./jenkins-CLI.sh
Check 3 new created credentials, and 7 plugins

