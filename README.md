# Jishu's Shop — Static Website

This is a small static site scaffold for a shop. It lives in `my-aws-website` and is ready to serve locally or be deployed to AWS S3 as a static website.

Quick commands (PowerShell):

```powershell
# Serve locally on port 8000
cd 'D:\Python Chaptor 1\my-aws-website'
python -m http.server 8000

# Open http://localhost:8000 in your browser
```

Deploy to AWS S3 (one-time setup requires `aws configure` with credentials):

```powershell
# create a bucket (bucket name must be globally unique)
aws s3 mb s3://your-unique-bucket-name --region us-east-1

# sync files and make them public
aws s3 sync . s3://your-unique-bucket-name --delete --acl public-read

# enable static website hosting
aws s3 website s3://your-unique-bucket-name --index-document index.html --error-document index.html

# the website will be available at http://your-unique-bucket-name.s3-website-us-east-1.amazonaws.com
```

Notes:
- Images use `picsum.photos` placeholders. Replace them with your product images in `index.html`/`js/script.js`.
- If you want a shopping cart or backend, I can add a simple JSON API or integrate Stripe for payments.
