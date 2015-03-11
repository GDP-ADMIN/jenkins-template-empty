FROM debian:wheezy

RUN apt-get update && apt-get install -y \
  curl \
  git \
  unzip \
  wget \
  zip \
  openjdk-7-jdk \
  ant \
  jq

# Install PHP5 and PHP QA Tools
COPY php-qa.sh /usr/local/bin/php-qa.sh

RUN echo "deb http://packages.dotdeb.org wheezy-php56 all" > /etc/apt/sources.list.d/dotdeb.list && curl http://www.dotdeb.org/dotdeb.gpg | apt-key add -

RUN apt-get update && apt-get install -y \
  php5-cli \
  php5-fpm \
  php5-dev \
  php5-mysql \
  php5-mcrypt \
  php5-gd \
  php5-curl \
  php-pear \
  && php-qa.sh

RUN rm -rf /var/lib/apt/lists/* 

ENV JENKINS_HOME /var/jenkins_home
ENV JAVA_HOME /usr/lib/jvm/java-7-openjdk-amd64
ENV JAVA_OPTS -Dmail.smtp.starttls.enable=true

# Jenkins is ran with user `jenkins`, uid = 1000
# If you bind mount a volume from host/vloume from a data container, 
# ensure you use same uid
RUN useradd -d "$JENKINS_HOME" -u 1000 -m -s /bin/bash jenkins

RUN mkdir -p /usr/share/jenkins/ref/init.groovy.d
COPY init.groovy /usr/share/jenkins/ref/init.groovy.d/tcp-slave-angent-port.groovy
COPY jenkins.sh /usr/local/bin/jenkins.sh

ENV JENKINS_VERSION 1.596.1
RUN curl -L http://mirrors.jenkins-ci.org/war-stable/$JENKINS_VERSION/jenkins.war -o /usr/share/jenkins/jenkins.war

RUN chown -R jenkins "$JENKINS_HOME" /usr/share/jenkins/ref

# for main web interface:	
EXPOSE 8080

# will be used by attached slave agents:
EXPOSE 50000

VOLUME /var/jenkins_home
USER jenkins

ENTRYPOINT ["/usr/local/bin/jenkins.sh"]
