import boto3
import json
import logging
import os

logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Whitelist that allows you to pick buckets you dont want to revoke public permissions
WHITELIST = ''.join(os.getenv('S3_WHITELIST').split()).split(',')


def get_aws_account_id():
    """
    This retrieves the AWS account ID.
    We use this to set S3 bucket policy rules which are only accessible by your account.

    Returns:
        str -- The string of the account ID
    """

    sts = boto3.client('sts')
    user_arn = sts.get_caller_identity()['Arn']
    return user_arn.split(':')[4]


def update_policy(bucket, new_policy):
    """
    Replaces bucket policy with the new one

    Arguments:
        bucket {Str} -- name of the bucket
        new_policy {json.dumps(jsonobj)} -- json policy

    Returns:
        obj -- response
    """

    logger.info(f'Setting bucket policy for {bucket} back to:\n{json.dumps(new_policy)}')
    s3 = boto3.client('s3')
    response = s3.put_bucket_policy(
        Bucket=bucket,
        ConfirmRemoveSelfBucketAccess=True,
        Policy=json.dumps(new_policy)
    )
    return response


def bucket_acl_allows_public(bucket):
    """
    Determines whether the requested bucket's ACLs allow public access

    Arguments:
        bucket {str} -- the name of the bucket

    Returns:
        boolean
    """

    logger.info(f'Checking ACLs for {bucket}...')
    s3 = boto3.client('s3')
    response = s3.get_bucket_acl(Bucket=bucket)

    is_public = False

    public_groups = [
        'http://acs.amazonaws.com/groups/global/AuthenticatedUsers',
        'http://acs.amazonaws.com/groups/global/AllUsers'
    ]

    for grant in response['Grants']:
        if grant['Grantee'].get('Type') == 'Group':
            if grant['Grantee'].get('URI') in public_groups:
                is_public = True
                break

    return is_public


def update_acl(bucket):
    """
    Sets a bucket ACL to private

    Arguments:
        bucket {str} -- the name of the bucket

    Returns:
        json -- response object
    """

    logger.info(f'Setting ACLs for {bucket} back to private...')
    s3 = boto3.client('s3')
    response = s3.put_bucket_acl(
        Bucket=bucket,
        ACL='private'
    )
    return response


def lambda_handler(event, context):
    bucket = event['detail']['requestParameters']['bucketName']

    # Try to see if bucket in whitelist
    if bucket in WHITELIST:
        logger.info(f'{bucket} found in whitelist: {WHITELIST} - skipping.')
        return
    else:
        logger.info(f'{bucket} not found in whitelist: {WHITELIST} - validating permissions...')

    # If the event is PutBucketPolicy
    if event['detail']['eventName'] == 'PutBucketPolicy':

        policy_updated = False

        # Get the policy
        policy = event['detail']['requestParameters']['bucketPolicy']

        # Create a principal ID by getting the current account id
        principal = {'AWS': f'arn:aws:iam::{get_aws_account_id()}:root'}

        read_permissions = [
            's3:GetObject',
            's3:ListBucket'
        ]

        # Set the principal to the new_principal if permissions are open
        for statement in policy['Statement']:

            # If the principal is 'anyone'
            if statement['Principal'] == '*':

                # Iterate the various read permissions
                for read_permission in read_permissions:
                    if read_permission in statement['Action']:
                        statement['Principal'] = principal
                        policy_updated = True

        # Update the policy
        if policy_updated:
            api_response = update_policy(bucket, policy)
            return api_response

    # If the event is PutBucketAcl
    elif event['detail']['eventName'] == 'PutBucketAcl':

        # If the bucket ACL is public
        if bucket_acl_allows_public(bucket):

            # Set the bucket ACL to private
            api_response = update_acl(bucket)
            return api_response

    else:
        return None
