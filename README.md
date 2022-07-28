# Trusted Advisor to GitHub Issues

The purpose of this repository is to automate the creation of GitHub Issues from AWS Trusted Advisor checks.

Functionally there are two key components to this application, detailed below.

### GitHub Action

The GitHub action is setup as follows:

- runs every time a push occurs on the repository

- outputs any newly added Issues in the Action

### Application Functionality

`main.rb` is called by [final step](https://github.com/ministryofjustice/aws-trusted-advisor-to-github-issues/blob/main/.github/workflows/main-rb-ci.yaml#:~:text=run%3A%20ruby%20lib/main.rb) in the GitHub action.

- creates GitHub Issues in the repository specified under the `repo` variable [here](https://github.com/ministryofjustice/aws-trusted-advisor-to-github-issues/blob/main/.github/workflows/main-rb-ci.yaml#:~:text=repo%3A%20%22ministryofjustice/aws%2Dta%2Dtesting%22). 

- Issues contain the Check, Category Status, Flagged Resources, Description etc as described [here](https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/Support/Client.html#describe_trusted_advisor_checks-instance_method).

- Since the AWS SDK returns _all_ AWS Trusted Advisory alerts - _regardless of their status_ - we filter for `error` and `warning` statuses [here](https://github.com/ministryofjustice/aws-trusted-advisor-to-github-issues/blob/1647fbab07e29aa5bbf0a7baf3cd4d8a1ce120d9/lib/main.rb#L39).

- Creates GitHub Issues for _all_ of the categories, also labels each Issue with its respective category:
  - `cost_optimizing`
  - `service_limits`
  - `fault_tolerance`
  - `security`
  - `performance`

- Additionally automatically labels each issue with its AWS Status `warning` or `error`. 

- Does not create duplicate Issues (based on the Title).

## Pre-Requisites

Create a _internal_ repository for your organization. Add the name of this repository (in the form `organisation/reponame`) to the `repo` keyword, as seen [here](https://github.com/ministryofjustice/aws-trusted-advisor-to-github-issues/blob/main/.github/workflows/main-rb-ci.yaml#:~:text=repo%3A%20%22ministryofjustice/aws%2Dta%2Dtesting%22).

⚠ If you create a public repository you may accidentally reveal sensitive information about your AWS environment.

Configure you GitHub Environment Secrets to allow the AWS SDK to login to your AWS Account. You will need two secrets: 

- `AWS_ROLE_TO_ASSUME` - OIDC Connector Role for Shared Services Account (Master AWS Account which manages other Accounts).
- `TECH_SERVICES_GITHUB_TOKEN` - This is a GitHub Access Token with read/write permissions on the repository which Issues will be written to.
- `ASSUME_ROLE` - Role to Assume with appropriate read permissions.

Instructions on configuring AWS Credentials within GitHub Actions are [here](https://github.com/aws-actions/configure-aws-credentials#examples).

If you are not familiar with GitHub environments more information can be found [here](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment).

## Testing

Since the core functionality of this app relies on both `octokit` and `aws-sdk-support` gems we do not see a need for rspec testing. 

To test, fork/clone this repo, complete the pre-requisite steps above on new repositories.
