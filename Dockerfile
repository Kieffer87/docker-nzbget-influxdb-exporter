FROM alpine:3.15.2

RUN apk update && \
    apk add --no-cache bash py3-pip python3

ADD run.sh /
ADD requirements.txt /
ADD export.py /

RUN ["chmod", "+x", "/run.sh"]

RUN pip3 install -r requirements.txt && \
    rm -rf /tmp/pip_build_root/

ENV CRON_SCHEDULE $CRON_SCHEDULE

# NZBGet Variables
ENV NZBGET_USERNAME $NZBGET_USERNAME
ENV NZBGET_PASSWORD $NZBGET_PASSWORD
ENV NZBGET_URL $NZBGET_URL
ENV NZBGET_URL_SSL $NZBGET_URL_SSL
ENV NZBGET_PORT $NZBGET_PORT
ENV NZBGET_VALUES_TO_RETURN $NZBGET_VALUES_TO_RETURN

# InfluxDB Variables
ENV INFLUXDB_TOKEN $INFLUXDB_TOKEN
ENV INFLUXDB_ORG $INFLUXDB_ORG
ENV INFLUXDB_URL $INFLUXDB_URL
ENV INFLUXDB_URL_SSL $INFLUXDB_URL_SSL
ENV INFLUXDB_PORT $INFLUXDB_PORT
ENV INFLUXDB_BUCKET $INFLUXDB_BUCKET

ENTRYPOINT ["/run.sh"]
CMD ["start"]
