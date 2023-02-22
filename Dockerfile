FROM node:16-alpine AS frontend

WORKDIR /build

COPY discover-frontend/package*.json ./

RUN npm i -g npm
RUN npm install --silent

COPY discover-frontend/ .

ENV PUBLIC_WRITE_FOOTER=true
ENV PUBLIC_API_ENDPOINT=http://localhost:8080/api/v1

RUN touch .env
RUN printenv > .env

RUN npm run build


FROM golang:1.19-alpine as backend

WORKDIR /build/src/server

RUN apk update && apk add git gcc musl-dev ca-certificates

COPY egh-api/go.mod ./
COPY egh-api/go.sum ./

ENV GO111MODULE=on

RUN go mod download

COPY egh-api/ ./

RUN CGO_ENABLED=0 GOOS=linux go build -o=server -buildvcs=false ./cmd/server


FROM scratch

WORKDIR /app

COPY --from=frontend /build/frontend /app/frontend/
COPY --from=backend /build/src/server/server /app/cmd/server/
COPY --from=backend /build/src/server/swagger /app/swagger

COPY --from=backend /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

ENV PORT 8080
EXPOSE 8080

ENTRYPOINT [ "/app/cmd/server/server" ]
CMD ["--store=mem"]
