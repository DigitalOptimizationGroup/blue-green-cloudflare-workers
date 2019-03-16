# Blue / Green Deployments for Cloudflare Workers

This is a working example of Blue / Green deployments with Canary releasing for Cloudflare Workers.

Features:

- Blue / Green workers
- Proxy worker implementing Canary releasing and A/B testing with [`cloudflare-edge-proxy`](https://github.com/DigitalOptimizationGroup/cloudflare-edge-proxy)
- Optional release versioning and history with AWS S3 bucket
- Infrastructure as code - deployed with Terraform (you just need to manually point your nameservers at Cloudflare) - nothing is done through the Cloudflare UI
- Convenient bash scripts for deploying

## Example

A running demo is currently deployed at https://edge-stack.org/. When visiting the site you will be assigned to either the blue or green backend. If you continue to delete your cookies and refresh the page you will, at some random point, also become assigned to the other backend. Without deleting your cookies you will continue to be assigned to the same backend.

The high level domain, in this case `edge-stack.org`, hosts a Worker proxy and two other domains are used to deploy the blue / green versions of the app.

The app in this example is a simple Hello World rendered in a Worker, but could easily be replaced with a full Worker rendered Progressive Web App like this one: https://github.com/DigitalOptimizationGroup/cloudflare-worker-preact-pwa

## Usage

#### Initial Configuration and Setup

You can run your own version of this setup by following the instructions below.

#### Setup a `.env` file in the project root

If you do not already have a Cloudflare account, you will need to create one. You will also need to enable Workers in your account (min $5.00 per month)

You will then need to get you Cloudflare Global API Key. This is available in your account under My Profile > API Keys > Global API Key. Add this in your `.env` file as `ACCOUNT_AUTH_KEY`. You will also need your account email address, add that as `ACCOUNT_EMAIL`.

You will need three domains to run this setup. The free plan on Cloudflare does not allow workers to be run on subdomains, so you'll need three high level domains. We use domains like `edge-stack.org`, `blue-edge-stack.org`, and `green-edge-stack.org`. You will also need some origin, even an s3 bucket works fine, to set a root level CNAME. Cloudflare seems to need this to enable Workers for a domain. No traffic should ever hit this domain (maybe we're wrong that this is needed?).

```bash
# Domains - replace with your domains
PROXY_DOMAIN=edge-stack.org
BLUE_DOMAIN=blue-edge-stack.org
GREEN_DOMAIN=green-edge-stack.org
DEFAULT_ORIGIN=

# Cloudflare Keys
ACCOUNT_AUTH_KEY=
ACCOUNT_EMAIL=

# Optional S3 Bucket for Release History - create your own bucket name
S3_BUCKET_NAME=edge-stack-org-demo
WORKER_VERSION=0.0.1
PROXY_VERSION=0.0.1
```

#### Setup Terraform

You don't need to know anything about Terraform to use this stack. You'll just need to run the commands. All you have to do is make sure you have it installed.

If you do not already have Terraform installed, you'll need to install it.
https://learn.hashicorp.com/terraform/getting-started/install.html

#### Running the scripts

There are two bash script with all the needed commands for deploying. You may need to give them executable permissions `chmod u+x commands.sh` and `chmod u+x s3deploy.sh`. The second script you will only use if you choose to save versioned releases to s3.

**Initialize the Terraform files** by running

```
./commands.sh init
```

**Deploy the three domains** into Cloudflare

```
./commands.sh setup_cloudflare
```

This command should take less than a minute to complete and will create Cloudflare zones for each of your domains.

When this command runs it will output (into the console) the nameservers that Cloudflare has assigned to your zones. You will need to update your domains with these nameservers before continuing. You can check if the nameserver updates have propagated by running something like `dig your-domain.com`.

**Deploy the root records** into your Cloudflare zones.

This seems to be needed to enable workers, no traffic should ever go to this record as workers will be responding to all requests. The command will fail if the nameservers have not been updated. You can keep trying to run it without any problems, once they are updated it will succeed.

```
./command.sh records
```

### Deploy your workers

There are two options for deploying workers. The first version just deploys from the local build script. The second version uses an s3 bucket to version and save each release (see docs further down this page).

#### Deploy Blue / Green worker

Run the `deploy_worker` command passing it one argument of your desired deployment target, either `blue` or `green`. If you're just testing this out, deploy both. For demonstration purposes, the app is configured to take in the color as a variable, so you'll be able to see a difference between the two deploys.

```
./command.sh deploy_worker blue
```

```
./command.sh deploy_worker green
```

#### Deploy / Update Proxy

Update the Proxy config here: `/worker-proxy/src/config.js`. You can refer to the documentation for `cloudflare-edge-proxy` to enable A/B Testing and Gatekeeping: https://github.com/DigitalOptimizationGroup/cloudflare-edge-proxy

```js
// canary config
export const config = {
  defaultBackend: `https://${process.env.BLUE_DOMAIN}`,

  // turn on canary deployment
  canary: true,

  // set the percent of traffic to send to the canary from 0-100
  // note that you should only increase this number when shifting traffic to assure
  // that your users do not "jump around" between backends
  weight: 30,
  canaryBackend: `https://${process.env.GREEN_DOMAIN}`,

  // you should change this salt for every new canary release so that users are
  // not allocated in the same manner as previous deployments
  salt: "canary-abc-123",

  // default is false, if true proxy will set _vq cookie for consistent assignment to same backend
  setCookie: true
};
```

Deploy the proxy:

```
./commands.sh deploy_proxy
```

Now you can go to your main domain and if you delete your cookies you should see the app switching randomly between blue or green each time you delete cookies and refresh.

### Destroying

You can destroy any of this with Terraform by running the following commands.

```
./commands.sh destroy_blue
./commands.sh destroy_green
./commands.sh destroy_proxy
./commands.sh destroy_records
./commands.sh destroy_cloudflare
```

Or

```
./commands.sh destroy_all
```

### Using S3 to save every release (immutable deployments)

Optionally you may choose to save every release by a version number into S3 before deploying to Cloudflare. This will keep an immutable record of all releases and allow you to deploy any past release.

Note: This creates an additional dependency on an AWS S3 bucket.

##### Deploying

First you will need to add the following variables to your `.env` file. Remember your `S3_BUCKET_NAME` must be unique across all of AWS, so if creation fails you may need to choose a different name.

```
S3_BUCKET_NAME=edge-stack-org-demo
WORKER_VERSION=0.0.1
PROXY_VERSION=0.0.1
```

You will also need to have AWS keys available in your environment with appropriate permissions available to Terraform.

There is a second script with commands for deploying through s3: `s3deploy.sh`.

First initialize Terraform

```
./s3deploy.sh init
```

Deploy your s3 bucket. You may also choose to enable versioning on the bucket for even greater security in saving past releases. Choose one of these two commands:

```
# without versioning
./s3deploy.sh build_s3_bucket

# or to enable versioning
./s3deploy.sh build_s3_bucket_with_versioning
```

Once the bucket has been created use the deploy commands from `./s3deploy.sh`. You will need to manually bump the versions in your `.env` file before each deploy. If you attempt to deploy to an already deployed version it will not overwrite the s3 file, but will ask if you'd like to rollback to the prior version.

```
./s3deploy.sh deploy_worker blue
```

```
./s3deploy.sh deploy_worker green
```

```
./s3deploy.sh deploy_proxy
```

#### Destroying the s3 version

You may need to delete everything in your bucket manually before you can destroy the bucket with Terraform.

```sh
./s3deploy.sh destroy_blue
./s3deploy.sh destroy_green
./s3deploy.sh destroy_proxy
./s3deploy.sh destroy_s3_bucket
```

or

```sh
./s3deploy.sh destroy_all
```

### Terraform Notes

You may like to take a look at Terraform backends. This example uses a local backend, but for larger teams you may prefer to use a remote backend to store infrastructure state. You can read about the tradeoffs here: https://www.terraform.io/docs/backends/

### About Digital Optimization Group

We offer a headless CMS built for A/B testing and we are currently accepting requests for private beta access. We also provide full-stack A/B testing services and consulting. Email: info@digitaloptgroup.com

### Licence

MIT
