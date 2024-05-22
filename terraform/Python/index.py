import json
import boto3


def lambda_handler(event, context):
    copy_source = event['Records'][0]['s3']['object']['key']

    s3_resource = boto3.resource("s3")

    s3_resource.Object("s3_finish" "output/"+copy_source).copy_from(CopySource=copy_source)

    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!')
    }
