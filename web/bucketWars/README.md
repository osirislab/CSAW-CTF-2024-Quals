## BUCKET WARS

### MOTIVATION
Understand how overpermissioned READ policies of versioned files on public S3 buckets can leak sensitive data

### INFRA 
A cloudfront CDN is used along side a static  S3 bucket as origin

### SOLVING 
***The challenge is only deployed (ie playable) for the duraction of quals***

1.  Using burp, or just playing with the website, notice that searching for non-existing pages leaks that the site is hosted on public S3 buckets


2. Using AWS CLI (no ACCESS KEY required) search for earlier versions of the `index_v1.html` file. The versions leak the S3 address of another public bucket serving the `sand-pit-1345726_640.jpg` image, and also leaks a key. 

3. Use the key along with the steghide extract utility on the sand-pit image to get the flag 

