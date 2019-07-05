return if Rails.env.test?

# rubocop:disable LineLength
S3_BUCKET_URL = "https://s3-#{ENV.fetch('AWS_REGION')}.amazonaws.com/#{ENV.fetch('S3_BUCKET_NAME')}".freeze
# rubocop:enable LineLength
FILES_PREFIX = ENV['FILES_PREFIX'] || 'imports/'

# :nocov:
ClimateWatchEngine.s3_bucket_name = ENV.fetch('S3_BUCKET_NAME')
aws_access_key_id = ENV.fetch('AWS_ACCESS_KEY_ID') {}
aws_secret_access_key = ENV.fetch('AWS_SECRET_ACCESS_KEY') {}

if aws_access_key_id.present? && aws_secret_access_key.present?
  credentials = Aws::Credentials.new(aws_access_key_id, aws_secret_access_key)
  Aws.config.update(
    region: ENV.fetch('AWS_REGION'),
    credentials: credentials,
    endpoint: 'https://s3.amazonaws.com'
  )
end
# :nocov:
