FROM python:3.9-buster

WORKDIR /usr/src

COPY requirements.txt .
COPY ./.bashrc /root/.bashrc

RUN apt update && \
    apt -y upgrade && \ 
    apt install -y vim 

RUN pip install -r requirements.txt

CMD ["bash"]

