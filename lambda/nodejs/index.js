const AWS = require("aws-sdk");

const dynamo = new AWS.DynamoDB.DocumentClient();
const TABLE_NAME = process.env.TABLE_NAME;

exports.handler = async (event) => {
  let body = {};

  try {
    body = event.body ? JSON.parse(event.body) : {};
  } catch {
    return respond(400, { error: "Invalid JSON format" });
  }

  const method = event.httpMethod;
  const id = event.queryStringParameters?.id || body.id;

  switch (method) {

    // CREATE
    case "POST":
      await dynamo.put({
        TableName: TABLE_NAME,
        Item: body
      }).promise();

      return respond(200, {
        message: "Item Created",
        item: body
      });

    // READ
    case "GET":
      if (!id) return respond(400, { error: "id is required" });

      const result = await dynamo.get({
        TableName: TABLE_NAME,
        Key: { id }
      }).promise();

      return respond(200, result.Item || {});

    // UPDATE
    case "PUT":
      if (!id || !body.info)
        return respond(400, { error: "id & info required" });

      await dynamo.update({
        TableName: TABLE_NAME,
        Key: { id },
        UpdateExpression: "SET info = :info",
        ExpressionAttributeValues: {
          ":info": body.info
        }
      }).promise();

      return respond(200, { message: "Item Updated" });

    // DELETE
    case "DELETE":
      if (!id) return respond(400, { error: "id is required" });

      await dynamo.delete({
        TableName: TABLE_NAME,
        Key: { id }
      }).promise();

      return respond(200, { message: "Item Deleted" });

    default:
      return respond(400, { error: "Unsupported HTTP method" });
  }
};

function respond(statusCode, body) {
  return {
    statusCode,
    body: JSON.stringify(body)
  };
}

