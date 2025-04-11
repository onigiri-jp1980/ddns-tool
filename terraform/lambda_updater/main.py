import boto3
import os


def lambda_handler(event, context):
    lambda_client = boto3.client('lambda')

    function_name = os.environ["FUNCTION_NAME"]
    image_uri = os.environ["IMAGE_URI"]

    print(f"Updating {function_name} to {image_uri}")

    response = lambda_client.update_function_code(
        FunctionName=function_name,
        ImageUri=image_uri,
        Publish=True
    )

    print("Update response:", response)
    return response
