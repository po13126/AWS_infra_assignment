FROM ubuntu:latest
MAINTAINER poojamishra1312@gmail.com
RUN apt-get update -y && \
    apt-get install -y python3-pip python-dev
EXPOSE 5000
RUN mkdir /app
WORKDIR /app
COPY . /app
RUN pip3 install -r requirements.txt
ENTRYPOINT [ "python3" ]
CMD [ "routes.py" ]
