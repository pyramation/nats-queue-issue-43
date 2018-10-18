FROM mhart/alpine-node:10.11.0

RUN apk --no-cache add curl \
    && echo "Pulling watchdog binary from Github." \
    && curl -sSLf https://github.com/openfaas-incubator/of-watchdog/releases/download/0.4.0/of-watchdog > /usr/bin/fwatchdog \
    && chmod +x /usr/bin/fwatchdog \
    && apk del curl --no-cache

RUN addgroup -S app && adduser -S -g app app
RUN mkdir -p /home/app
RUN chown app:app /home/app
WORKDIR /home/app

USER app

COPY package.json .
COPY src /home/app/src
ENV NODE_ENV production
ENV NPM_CONFIG_LOGLEVEL warn
RUN npm install --production

ENV cgi_headers="true"
ENV fprocess="node src/index.js"
ENV mode="http"
ENV PORT 10101
ENV upstream_url="http://127.0.0.1:10101"

ENV exec_timeout="20s" 
ENV write_timeout="25s" 
ENV read_timeout="25s" 

HEALTHCHECK --interval=1s CMD [ -e /tmp/.lock ] || exit 1
CMD ["fwatchdog"]