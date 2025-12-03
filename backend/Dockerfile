FROM golang:1.25.4

WORKDIR /university-app

COPY go.mod go.sum ./

RUN go mod download

COPY . .

RUN go build -o university-app ./cmd/main.go

EXPOSE 3333

CMD ["./university-app"]
