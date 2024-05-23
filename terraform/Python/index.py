import json
import boto3


def lambda_handler(event, context):
    # return f"This event: {event}"
    s3 = boto3.resource('s3')

    src_bucket = s3.Bucket("s3-start")
    dst_bucket = "s3-finish"

    for obj in src_bucket.objects.filter(Prefix=''):
        # This prefix will got all the files, but you can also use:
        # (Prefix='images/',Delimiter='/') for some specific folder
        print(obj.key)
        copy_source = {'Bucket': "s3-start", 'Key': obj.key}

        # and here define the name of the object in the destination folder

        dst_file_name = obj.key  # if you want to use the same name
        s3.meta.client.copy(copy_source, dst_bucket, dst_file_name)