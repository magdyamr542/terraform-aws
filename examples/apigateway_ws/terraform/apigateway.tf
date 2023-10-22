// Permissions for the ws gateway
data "aws_iam_policy_document" "ws_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}



resource "aws_iam_role" "iam_role_for_ws" {
  name               = "iam_role_for_ws"
  assume_role_policy = data.aws_iam_policy_document.ws_assume_role.json
}

resource "aws_iam_role_policy" "iam_role_policy_for_ws" {
  name = "iam_policy_for_ws"
  role = aws_iam_role.iam_role_for_ws.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        // Allow the ws gateway to invoke the function.
        Action    = "lambda:InvokeFunction"
        Effect    = "Allow"
        Resources = [aws_lambda_function.chat_lambda.arn]
      },
    ]
  })
}

// The root resource for the gateway.
resource "aws_apigatewayv2_api" "ws_chat_api" {
  name                       = "ws-chat-api"
  protocol_type              = "WEBSOCKET"
  route_selection_expression = "$request.body.action"
}

// A gateway delegates the processing to an integration. In this case to our lambda.
resource "aws_apigatewayv2_integration" "ws_chat_api_integration" {
  api_id = aws_apigatewayv2_api.ws_chat_api.id
  // AWS_PROXY is used with lambdas.
  integration_type          = "AWS_PROXY"
  integration_uri           = aws_lambda_function.chat_lambda.invoke_arn
  credentials_arn           = aws_iam_role.iam_role_for_ws.arn
  content_handling_strategy = "CONVERT_TO_TEXT"
  passthrough_behavior      = "WHEN_NO_MATCH"
}

// An integration response transforms responses sent from the integration (The lambda) to the clients.
// In this case, our intgration responses pass the payload through (It does nothing).
resource "aws_apigatewayv2_integration_response" "ws_chat_api_integration_response" {
  api_id                   = aws_apigatewayv2_api.ws_chat_api.id
  integration_id           = aws_apigatewayv2_integration.ws_chat_api_integration.id
  integration_response_key = "/200/"
}

// If no other integration response matches, this integration response is chosen and it 
// will process the payload from the integration. This should ideally point to a different lambda function that
// returns an error or logs an error. Something like that.
resource "aws_apigatewayv2_integration_response" "ws_chat_api_integration_response_catch_all" {
  api_id                   = aws_apigatewayv2_api.ws_chat_api.id
  integration_id           = aws_apigatewayv2_integration.ws_chat_api_integration.id
  integration_response_key = "$default"
}

// Setting up the routes.
// When a route matches, it delegates the work to the configured integration.
resource "aws_apigatewayv2_route" "ws_chat_api_default_route" {
  api_id    = aws_apigatewayv2_api.ws_chat_api.id
  route_key = "$default"
  target    = "integrations/${aws_apigatewayv2_integration.ws_chat_api_integration.id}"
}

// WebSocket routes can be configured for two-way or one-way communication. 
// API Gateway will not pass the backend response through to the route response, unless you set up a route response.
// Client makes request -> Route request -> Integration request -> Integration processing -> Integration response -> Route response.
resource "aws_apigatewayv2_route_response" "ws_messenger_api_default_route_response" {
  api_id   = aws_apigatewayv2_api.ws_chat_api.id
  route_id = aws_apigatewayv2_route.ws_chat_api_default_route.id
  // You can only define the $default route response for WebSocket APIs.
  route_response_key = "$default"
}

resource "aws_apigatewayv2_route" "ws_chat_api_connect_route" {
  api_id    = aws_apigatewayv2_api.ws_messenger_api_gateway.id
  route_key = "$connect"
  target    = "integrations/${aws_apigatewayv2_integration.ws_chat_api_integration.id}"
}

resource "aws_apigatewayv2_route_response" "ws_messenger_api_connect_route_response" {
  api_id             = aws_apigatewayv2_api.ws_chat_api.id
  route_id           = aws_apigatewayv2_route.ws_chat_api_connect_route.id
  route_response_key = "$default"
}

resource "aws_apigatewayv2_route" "ws_chat_api_disconnect_route" {
  api_id    = aws_apigatewayv2_api.ws_chat_api.id
  route_key = "$disconnect"
  target    = "integrations/${aws_apigatewayv2_integration.ws_chat_api_integration.id}"
}

resource "aws_apigatewayv2_route_response" "ws_chat_api_disconnect_route_response" {
  api_id             = aws_apigatewayv2_api.ws_chat_api_gateway.id
  route_id           = aws_apigatewayv2_route.ws_chat_api_disconnect_route.id
  route_response_key = "$default"
}

resource "aws_apigatewayv2_route" "ws_chat_api_message_route" {
  api_id    = aws_apigatewayv2_api.ws_chat_api.id
  route_key = "MESSAGE"
  target    = "integrations/${aws_apigatewayv2_integration.ws_chat_api_integration.id}"
}

resource "aws_apigatewayv2_route_response" "ws_chat_api_message_route_response" {
  api_id             = aws_apigatewayv2_api.ws_chat_api.id
  route_id           = aws_apigatewayv2_route.ws_chat_api_message_route.id
  route_response_key = "$default"
}
