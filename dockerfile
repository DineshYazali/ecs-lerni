FROM centos:7    	

COPY files.tar.gz  /

RUN  yum update -y &&\
     curl -sL https://rpm.nodesource.com/setup_13.x | bash -  &&\
     yum install nodejs -y  && mkdir /code &&\
     mv files.tar.gz  /code  && cd /code &&\
     tar -xvf files.tar.gz  &&\
     cd express && npm install

CMD node /code/express/index.js
