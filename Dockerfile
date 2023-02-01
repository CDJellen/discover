# egh-api (backend)

FROM golang:1.19 AS backend-builder

WORKDIR /build

RUN mkdir backend

COPY ./egh-api/go.mod /build/backend
COPY ./egh-api/go.sum /build/backend

RUN cd backend && go mod download

COPY ./egh-api/ /build/backend/

WORKDIR /build/backend

RUN cd cmd/server/ && go build -o=egh-api -buildvcs=false  

# deploy with frontend

FROM node:latest as deploy

WORKDIR /deploy

COPY --from=backend-builder /build/backend /deploy/backend
COPY ./discover-frontend/ /deploy

RUN npm install
RUN npm prune

EXPOSE 8080
EXPOSE 5173

COPY ./launcher.sh /deploy/launcher.sh
ENTRYPOINT [ "./launcher.sh" ]
