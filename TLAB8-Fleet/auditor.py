import boto3  
import json  
  
def lambda_handler(event, context):  
    client = boto3.client('ecr')  
    # REMEDIATED: Aligned with the exact repository name required by the student instructions
    response = client.describe_images(repositoryName='tkh-fleet-vault')  
  
    print(f"Audit Complete. Images found: {len(response['imageDetails'])}")  
    return {  
        'statusCode': 200,  
        'body': json.dumps('Fleet Audit Successful!')  
    }  
