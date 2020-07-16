# CloudFront Invalidation
A script I created to make it easy to invalidate a given CloudFront distribution from the terminal.

A pre-requisite is to have aws cli installed and IAM keys configured with access to list Route53 resources. Another option is to run it from an EC2 instance that has an IAM role with Route53 list permissions.

Another requisite is to have jq installed as it is being used to parse some JSON output.

## cloudfront_invalidation.sh

For this one, change its permissions to be executable and then run it. It requires paramaters to be passed in.
```
chmod 755 cloudfront_invalidation.sh
./cloudfront_invalidation.sh
```
### Parameters
```
-h - Help
-l Lists all distribution info
-i Invalidate Distribution
```
### Examples
```
cloudfront_invalidation.sh -i <distroid> '<paths>' - The paths must be quoted and separated by commas.

./Route53_param.sh -i Z123145667 '/*'

```
