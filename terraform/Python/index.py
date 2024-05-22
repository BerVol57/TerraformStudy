import json
import boto3

src_bucket_path = 's3_start'
src_file_name = 'source/source.txt'
tgt_bucket_path = 's3_finish'
tgt_file_name = 'target/target.txt'


def lambda_handler(event, context):
    print("I dunno")