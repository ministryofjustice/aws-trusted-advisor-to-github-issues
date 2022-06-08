# Trusted Advisor to GitHub Issues

🚧 UNDER CONSTRUCTION 🚧

The purpose of this repository is to automate the creation of GitHub Issues from Trusted Advisor checks.

Functionally there are two key components to this application, detailed below.

### GitHub Action

The GitHub action is setup as follows:
- _runs every specify time period or under which conditions the app will run_

- outputs to the repository details in

### Application Functionality

`main.rb` is called by final step in the GitHub action.

- creates GitHub Issues in the repository specified in <location>

- Issues contain the Check, Category Status, Flagged Resources, Description etc as described <here>.

- Since the <AWS command> returns all AWS Trusted Advisory alerts - _regardless of their status_ - we filter for `error` and `warning` statuses [here]() _link to line 16 of main.rb_

- Creates GitHub Issues for all of the categories:
  - `cost_optimizing`
  - `service_limits`
  - `fault_tolerance`
  - `security`
  - `performance`

- Does not create duplicate Issues (based on the Title)

### AWS

_details surrounding how the app can assume the correct role in your organisation_

## 👷‍♂️ Next Features / To Do

- Parameterise the token, repository etc into .env file
- Add Makefile
- Configure to run on GitHub using Actions / Runners /
- Update README to include information regarding OIDC and which variables are required to work
- Ability to create issues for individual categories, not only _all_ of the five.

## Testing

Since the core functionality of this app relies on both `octokit` and `aws-sdk-support` we do not see a need for rspec testing.

## Pre-Requisites

Create a internal repository for your organization. Add this

Issues are labelled based on their categories in AWS Trusted Advisor. Add the five categories as labels:
  - `cost_optimizing`
  - `service_limits`
  - `fault_tolerance`
  - `security`
  - `performance`

Configure you GitHub Environment Secrets to allow the AWS SDK to login to your AWS Account.

If you are not familiar with GitHub environments more information can be found [here](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment)

