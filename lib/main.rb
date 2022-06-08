require 'aws-sdk-support'
require 'octokit'

role_credentials = Aws::AssumeRoleCredentials.new(
  client: Aws::STS::Client.new,
  role_arn: ENV["AWS_ROLE_ARN"],
  role_session_name: "ruby-app-cloud-ops"
)

aws_client = Aws::Support::Client.new(credentials: role_credentials, region: "us-east-1")
github_client = Octokit::Client.new(:access_token => ENV["token"])

checks = aws_client.describe_trusted_advisor_checks({
  language: "en"
})

REPO = ENV["repo"]

issue_titles = []

github_client.list_issues(REPO)

last_response = github_client.last_response

last_response.data.each { |check| issue_titles << check["title"] }

until last_response.rels[:next].nil?
  last_response = last_response.rels[:next].get
  last_response.data.each do |check|
    issue_titles << check["title"]
  end
end

statuses = ["error", "warning"]

checks.checks.each do |check|
  unless issue_titles.include?(check.name)
    resp = aws_client.describe_trusted_advisor_check_summaries({ check_ids: [check.id] })
    if statuses.include?(resp.summaries[0].status)
      body = "Category: #{check.category}\nStatus: #{resp.summaries[0].status}"
      puts ""
      puts "********************************************************************************"
      puts "********************************************************************************"
      puts "Check: #{check.name}"
      puts "Category: #{check.category}"
      puts "Status: #{resp.summaries[0].status}"
      body += "\nHas flagged resources: #{resp.summaries[0].has_flagged_resources}"
      puts "Has flagged resources: #{resp.summaries[0].has_flagged_resources}"
      body += "\nResources flagged: #{resp.summaries[0].resources_summary.resources_flagged}"
      puts "Resources flagged: #{resp.summaries[0].resources_summary.resources_flagged}"
      body += "\n\n#{check.description}"
      puts "Description:"
      puts "#{check.description}"
      check_result = aws_client.describe_trusted_advisor_check_result({
        check_id: check.id,
        language: "en",
      })
      puts "Check result:"
      puts "========================================================"
      puts "Result status: #{check_result.result.status}"
      body += "\n\nFlagged resources:"
      puts "******** Flagged resources: ********"
      check_result.result.flagged_resources.each_with_index do |resource, index|
        puts ""
        body += "\n\nResource \##{index+1} ID: #{resource.resource_id}:"
        puts ">>>>> Resource \##{index+1} ID: #{resource.resource_id}"
        puts "Resource metadata:"
        check.metadata.zip(resource.metadata).each { |m| puts m.flatten().join(": ")
        body += "\n#{m.flatten().join(": ")}" }
      end

      github_client.create_issue(REPO, check.name, body, :labels => [check.category, resp.summaries[0].status])
      puts github_client.last_response
      sleep 2
    end
  end
end
