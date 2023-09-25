package api

import "fmt"

type Operation string

const (
	Add      Operation = "add"
	Subtract Operation = "subtract"
	Multiply Operation = "multiply"
	Divide   Operation = "divide"
)

var (
	OperationMap = map[Operation]string{
		Add:      "+",
		Subtract: "-",
		Multiply: "*",
		Divide:   "/",
	}
)

type S3Content struct {
	Operation Operation `json:"operation"`
	Operator1 int       `json:"operator1"`
	Operator2 int       `json:"operator2"`
}

func (e *S3Content) String() string {
	return fmt.Sprintf("%d %s %d", e.Operator1, OperationMap[e.Operation], e.Operator2)
}

type QueuePayload struct {
	Operation string `json:"operation"`
	Result    int    `json:"result"`
}
