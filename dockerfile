# adds curl to mongo image and runs setup steps for mongo and elasticsearch

FROM mongo:3.4.4

RUN apt-get update && apt-get install -y curl

COPY ./scripts/setup.sh /scripts/

RUN chmod +x /scripts/setup.sh

CMD ["/bin/bash", "/scripts/setup.sh"]