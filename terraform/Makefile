build-lambdas:
	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o tf_generated/lambda1/binary ../cmd/lambda1
	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o tf_generated/lambda2/binary ../cmd/lambda2
