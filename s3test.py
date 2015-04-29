import boto
import boto.s3.connection
access_key = '123'
secret_key = '456'

conn = boto.connect_s3(
        aws_access_key_id = access_key,
        aws_secret_access_key = secret_key,
        host = '86.50.168.111',
        is_secure=False,
        calling_format = boto.s3.connection.OrdinaryCallingFormat(),
        )
#bucket = conn.create_bucket('test1')
conn.delete_bucket('test1')
for bucket in conn.get_all_buckets():
        print "{name}\t{created}".format(
                name = bucket.name,
                created = bucket.creation_date,
        )

