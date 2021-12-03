#Sumo Logic SDO solution - This files has parameters required to create FER's in Sumo Logic.

github_pull_request_fer_scope = "%\"x-github-event\"=pull_request"
github_pull_request_fer_parse = "json \"action\", \"pull_request.title\", \"pull_request.created_at\", \"pull_request.merged_at\" ,\"repository.name\" ,\"pull_request.merged\", \"pull_request.html_url\", \"pull_request.merge_commit_sha\", \"pull_request.base.ref\" , \"pull_request.user.login\", \"pull_request.labels[0].name\", \"pull_request.requested_reviewers[*].login\",\"pull_request.head.sha\" as action, title, dateTime, closeddate ,repository_name,  merge, link, commit_id, target_branch ,user, service, reviewers, head_commit_id nodrop\n| where action in (\"closed\", \"opened\") \n| parseDate(dateTime, \"yyyy-MM-dd'T'HH:mm:ss\", \"etc/utc\") as dateTime_epoch\n| if(action matches \"closed\" and merge matches \"true\", \"merged\", if(action matches \"closed\" and merge matches \"false\", \"declined\", if (action matches \"opened\", \"created\", \"other\"  ))) as status\n| if (status=\"merged\", parseDate(closeddate, \"yyyy-MM-dd'T'HH:mm:ss\", \"etc/utc\") , 000000000 ) as closeddate_epoch\n| toLong(closeddate_epoch)\n| \"n/a\" as team\n| \"pull_request\" as event_type\n"

github_push_fer_scope = "%\"x-github-event\" = \"push\""
github_push_fer_parse = "json \"commits[(@.length-2)].id\" as head_commit_id\n| json \"commits[(@.length-2)].timestamp\" as head_commit_datetime\n| json \"commits[(@.length-2)].message\" as head_commit_message\n| parseDate(head_commit_datetime, \"yyyy-MM-dd'T'HH:mm:ss\",\"etc/utc\") as head_commit_epoch\n| json \"commits[0].id\" as base_commit_id\n| json \"commits[0].timestamp\" as base_commit_datetime\n| json \"commits[0].message\" as base_commit_message\n| parseDate(base_commit_datetime, \"yyyy-MM-dd'T'HH:mm:ss\",\"etc/utc\") as base_commit_epoch\n| json \"repository.full_name\",\"sender.login\" as repository_name,user\n| if (isEmpty(service), \"n/a\",service) as service\n| \"n/a\" as team\n| \"push\" as event_type\n"

jenkins_build_fer_scope = "trace_id"
jenkins_build_fer_parse = "json field=_raw \"event_type\"\n| json \"event_type\", \"team\",  \"service\", \"trace_id\", \"user\", \"link\", \"title\", \"timeStamp\", \"message\", \"env_name\", \"result\", \"target_branch\", \"repository_name\", \"commit_id\" as event_type, team, service, trace_id, user, link, title, datetime, message, environment_name, status, target_branch, repository_name, commit_id nodrop\n| parse regex field=_sourceName \"(?<name>.+)#(?<build_number>.+)\"\n| toLong(datetime) as datetime_epoch\n| \"build\" as event_type\n"

jenkins_deploy_fer_scope = "trace_id"
jenkins_deploy_fer_parse = "json \"event_type\", \"team\",  \"service\", \"trace_id\", \"user\", \"link\", \"title\", \"timeStamp\", \"message\", \"env_name\", \"result\", \"target_branch\",\n\"repository_name\", \"commit_id\" as event_type, team, service, trace_id,\nuser, link, title, datetime, message, environment_name, status,\ntarget_branch, repository_name, commit_id\n| toLong(datetime) as datetime_epoch\n| \"deploy\" as event_type\n"

jenkins_build_status_fer_scope = "Pipeline_Stages"
jenkins_build_status_fer_parse = "json \"name\", \"number\" as pipeline_name, pipeline_number\n| json \"stages\" as StagesPipeline\n| \"pipeline\" as event_type\n"

opsgenie_alerts_fer_scope = "(\"Close\" or \"Create\")"
opsgenie_alerts_fer_parse = "json \"alert.createdAt\", \"alert.updatedAt\", \"action\", \"alert.team\", \"alert.priority\", \"alert.source\", \"alert.alertId\" as dateTime, closeddate, alert_type, team, priority, service, alert_id nodrop\n| where alert_type in (\"Close\", \"Create\") \n| toLong(closeddate/1000) as closeddate_epoch\n| toLong(datetime*1000) as datetime_epoch\n| if (priority matches \"p1\", \"high\", if(priority matches \"p2\", \"medium\",  if(priority matches \"p3\", \"medium\",  if(priority matches\n\"p4\", \"low\",  if(priority matches \"p5\", \"low\", \"other\")))))  as priority\n| if (alert_type matches \"*Create\", \"alert_created\", if(alert_type  matches \"*Close\", \"alert_closed\", \"other\") ) as event_type\n"

bitbucket_pull_request_fer_scope = "%\"x-event-key\"=pullrequest:*"
bitbucket_pull_request_fer_parse = "json \"pullrequest.title\", \"pullrequest.destination.repository.full_name\",  \"pullrequest.destination.branch.name\", \"pullrequest.created_on\", \"pullrequest.author.display_name\",  \"pullrequest.state\", \n\"pullrequest.links.html.href\", \"pullrequest.merge_commit.hash\", \"pullrequest.reviewers[*].display_name\", \"pullrequest.updated_on\", \"pullrequest.source.commit.hash\" as title, repository_name, target_branch, dateTime, user, action, link,\ncommit_id, reviewers, updated_date, head_commit_id nodrop\n| parseDate(dateTime, \"yyyy-MM-dd'T'HH:mm:ss\",\"etc/utc\") as datetime_epoch\n| parse regex field=%\"x-event-key\" \".+:(?<status>.+)\"\n| if (status matches \"created\", \"created\", if(status matches \"fulfilled\", \"merged\", if(status matches \"rejected\", \"declined\", \"other\"))) as status \n| if(status = \"created\", \"n/a\", updated_date) as closeddate\n| if(closeddate = \"n/a\", 0, parseDate(closeddate, \"yyyy-MM-dd'T'HH:mm:ss\",\"etc/utc\")) as closeddate_epoch\n| tolong(closeddate_epoch)\n| \"n/a\" as service\n| \"n/a\" as team\n| \"pull_request\" as event_type\n"

bitbucket_build_fer_scope = "%\"x-event-key\"=repo:commit_status_* (\"SUCCESSFUL\" OR \"FAILED\")"
bitbucket_build_fer_parse = "json \"commit_status.state\", \"commit_status.commit.message\", \"commit_status.name\", \"actor.display_name\", \"repository.full_name\",  \"commit_status.refname\", \"commit_status.url\", \"commit_status.created_on\", \"commit_status.commit.hash\",\n\"commit_status.repository.name\" as status, message, title, user, repository_name, target_branch, link, datetime, commit_id, service \n| commit_id as trace_id\n| \"n/a\" as team\n| parse regex field= datetime\n\"(?<datetime_epoch>\\d\\d\\d\\d-\\d\\d-\\d\\dT\\d\\d:\\d\\d:\\d\\d)\"  nodrop   \n| parseDate(datetime_epoch, \"yyyy-MM-dd'T'HH:mm:ss\") as datetime_epoch\n| where status in (\"SUCCESSFUL\", \"FAILED\")\n| \"build\" as event_type\n"

bitbucket_deploy_fer_scope = "deploymentEnvironment pipe_result_link deploy_status commit_link"
bitbucket_deploy_fer_parse = "json field=_raw  \"deploymentEnvironment\",  \"repoFullName\", \"pipe_result_link\", \"deploy_status\", \"commit\",  \"event_date\", \"prDestinationBranch\", \"repoOwner\", \"buildNumber\"  as environment_name,\nrepository_name, link, status, commit_id, datetime, target_branch, user,\ntitle\n| commit_id as trace_id\n| \"n/a\" as team\n| \"n/a\" as service\n| concat(\"build number \", title, \". Commit link \", link) as message\n| parseDate(datetime, \"yyyy-MM-dd HH:mm:ss\",\"etc/utc\") as datetime_epoch | if (status matches \"0\", \"Success\", \"Failed\") as status\n| \"deploy\" as event_type\n"

bitbucket_push_fer_scope = "%\"x-event-key\" = \"repo:push\""
bitbucket_push_fer_parse = "json \"push.changes[0].commits[1].hash\" as head_commit_id\n| json \"push.changes[0].commits[1].date\" as head_commit_datetime\n| json \"push.changes[0].commits[1].message\" as head_commit_message\n| parseDate(head_commit_datetime, \"yyyy-MM-dd'T'HH:mm:ss\",\"etc/utc\") as head_commit_epoch\n| json \"push.changes[0].commits[(@.length-1)].hash\" as base_commit_id\n| json \"push.changes[0].commits[(@.length-1)].date\" as base_commit_datetime\n| json \"push.changes[0].commits[(@.length-1)].message\" as base_commit_message\n| parseDate(base_commit_datetime, \"yyyy-MM-dd'T'HH:mm:ss\",\"etc/utc\") as base_commit_epoch\n| json \"actor.display_name\",\"repository.name\" as user,repository_name\n| \"n/a\" as service\n| \"n/a\" as team\n| \"push\" as event_type\n"

jira_issues_fer_scope = "issue_*"
jira_issues_fer_parse = "json field=_raw \"issue_event_type_name\", \"issue.self\",  \"issue.key\", \"issue.fields.issuetype.name\", \"issue.fields.project.name\", \"issue.fields.status.statusCategory.name\",  \"issue.fields.priority.name\", \"issue.fields.components\" as  issue_event_type, link, issue_key, issue_type, project_name, issue_status,  priority, service\n| parse regex field=service \"name\\\":\\\"(?<service>.+?)\\\",\\\"\" \n| \"n/a\" as team\n| json \"issue.fields.resolutiondate\", \"issue.fields.created\" as closedDate, dateTime \n| parseDate(dateTime, \"yyyy-MM-dd'T'HH:mm:ss.SSSZ\") as datetime_epoch\n| if (isNull(closeddate) , 00000000000, parseDate(closedDate, \"yyyy-MM-dd'T'HH:mm:ss.SSSZ\") ) as closeddate_epoch\n| toLong(closeddate_epoch)\n| \"issue\" as event_type\n"

pagerduty_alerts_fer_scope = "(\"incident.trigger\" or \"incident.resolve\" )"
pagerduty_alerts_fer_parse = "parse regex \"(?<event>\\{\\\"event\\\":\\\"incident\\..+?\\}(?=,\\{\\\"event\\\":\\\"incident\\..+|\\]\\}$))\" \n|json  field=event \"event\", \"created_on\", \"incident\" as alert_type,\ndateTime, incident\n|json field=incident \"id\",  \"service.name\" , \"urgency\",\n\"teams[0].summary\", \"html_url\"  as alert_id, service, priority, team,\nlink\n|json  field=incident \"created_at\" as closeddate nodrop\n| where alert_type in (\"incident.trigger\", \"incident.resolve\")\n| parseDate(dateTime, \"yyyy-MM-dd'T'HH:mm:ss'Z'\") as dateTime_epoch\n| parseDate(closeddate, \"yyyy-MM-dd'T'HH:mm:ss'Z'\") as closeddate_epoch\n| if (alert_type matches \"*trigger\", \"alert_created\", if(alert_type matches \"*resolve\", \"alert_closed\", \"other\") ) as event_type\n"

gitlab_pull_request_fer_scope = " %\"x-gitlab-event\"=\"Merge Request Hook\" "
gitlab_pull_request_fer_parse = "json \"object_attributes.action\",\"object_attributes.state\" ,\"object_attributes.title\", \"object_attributes.created_at\",\"object_attributes.updated_at\",\"user.name\",\"project.name\",\"object_attributes.target_branch\" ,\"object_attributes.url\",\"assignees[*].name\",\"object_attributes.merge_commit_sha\",\"repository.name\",\"project.path_with_namespace\",\"object_attributes.last_commit.id\"  as action,status, title,createddatetime, updateddatetime_epoch,user,project_name,target_branch,link,reviewers,commit_id,repository_name,team, head_commit_id nodrop\n|  parse regex field=team \"(?<team>.+)\\/.+\" \n| if (status matches \"opened\", \"created\", if(status matches \"merged\", \"merged\", if(status matches \"closed\", \"declined\", \"other\"))) as status\n| parseDate(createddatetime, \"yyyy-MM-dd HH:mm:ss\",\"etc/utc\") as datetime_epoch\n| parseDate(updateddatetime_epoch, \"yyyy-MM-dd HH:mm:ss\",\"etc/utc\") as updateddatetime_epoch\n|if(status in (\"declined\",\"merged\") ,updateddatetime_epoch,000000000)as  closeddate_epoch\n| project_name as service\n| toLong(datetime_epoch)\n| toLong(closeddate_epoch)\n| \"pull_request\" as event_type\n"

gitlab_build_request_fer_scope = " %\"x-gitlab-event\"=\"Job Hook\" "
gitlab_build_request_fer_parse = " json \"project_name\",\"build_name\",\"build_status\" ,\"build_stage\",\"user.name\",\"repository.name\",\"commit.message\" , \"repository.homepage\",\"commit.sha\",\"build_created_at\",\"environment.name\",\"ref \",\"pipeline_id\" as project_name , build_name ,status,build_stage,user, repository_name,message , homepage,commit_id,datetime,environment_name,target_branch,pipeline_id nodrop\n| where build_name matches \"Gitlab_Build_Job_Name\"\n| parse regex field=project_name \"\\/(?<project_name>[^\\\"]+)\"\n | split homepage delim='/' extract 4 as team\n| project_name as service\n| commit_id as trace_id\n|concat(\"build \",build_name,\" \",status) as message\n|concat(\"pipeline # \",pipeline_id) as title\n| concat(homepage,\"/-/jobs/\",trace_id) as link\n| parseDate(datetime, \"yyyy-MM-dd HH:mm:ss\") as datetime_epoch\n| toLong(datetime_epoch) as datetime_epoch\n| if(status matches \"success\",\"Success\",if(status matches \"failed\",\"Failed\",status)) as status\n| if(isEmpty(environment_name),\"n/a\",environment_name) as environment_name\n| \"build\" as event_type\n"

gitlab_deploy_request_fer_scope = " %\"x-gitlab-event\"=\"Deployment Hook\" "
gitlab_deploy_request_fer_parse = "json \"deployment_id\",\"status\",\"status_changed_at\",\"environment\",\"deployable_url\",\"user.name\",\"commit_url\",\"project.name\",\"project.default_branch\",\"project.path_with_namespace\"  as deployment_id,status,datetime,environment_name,link,user ,commit_link,service,target_branch,team nodrop\n|  parse regex field=team \"(?<team>.+)\\/.+\" \n|concat(\"deployment # \",deployment_id) as title\n|concat(\"deploying to \",environment_name,\" deployment # \",deployment_id) as message\n| parse regex field=commit_link \"\\/commit\\/(?<commit_id>[^\\\"]+)\"\n| commit_id as trace_id\n| service as repository_name\n| parseDate(datetime, \"yyyy-MM-dd HH:mm:ss\",\"etc/utc\") as datetime_epoch\n| toLong(datetime_epoch) as datetime_epoch\n| if(status matches \"success\",\"Success\",if(status matches \"failed\",\"Failed\",status)) as status\n| \"deploy\" as event_type\n"

gitlab_issue_request_fer_scope = " %\"x-gitlab-event\"=\"Issue Hook\" "
gitlab_issue_request_fer_parse = "json \"user.name\",\"project.name\",\"object_attributes.created_at\",\"object_attributes.url\",\"labels[*].title\",\"object_attributes.state\",\"object_attributes.severity\",\"object_attributes.action\",\"repository.name\",\"assignees[*].name\",\"object_attributes.id\",\"object_attributes.closed_at\",\"project.path_with_namespace\" as user,project_name,dateTime,link,issue_type,issue_status,priority,issue_event_type,repository,assignees,issue_key,closedDate,team nodrop\n|  parse regex field=team \"(?<team>.+)\\/.+\" \n| project_name as service\n| substring(issue_type,1,length(issue_type)-1) as issue_type\n|if (issue_type matches \"*incident*\",\"incident\",\"issue\") as issue_type\n| parseDate(datetime, \"yyyy-MM-dd HH:mm:ss\") as datetime_epoch\n| if (isNull(closeddate) , 00000000000, parseDate(closedDate, \"yyyy-MM-dd HH:mm:ss\")) as closeddate_epoch\n| if(issue_status matches \"opened\",\"To Do\",if(issue_status matches \"closed\",\"Complete\",issue_status)) as issue_status\n| toLong(datetime_epoch) as datetime_epoch\n| toLong(closeddate_epoch) as closeddate_epoch\n| \"issue\" as event_type\n"

gitlab_push_fer_scope = " %\"x-gitlab-event\" = \"Push Hook\"" 
gitlab_push_fer_parse = "json \"commits[(@.length-2)].id\" as head_commit_id\n| json \"commits[(@.length-2)].timestamp\" as head_commit_datetime\n| json \"commits[(@.length-2)].message\" as head_commit_message\n| parseDate(head_commit_datetime, \"yyyy-MM-dd'T'HH:mm:ss\",\"etc/utc\") as head_commit_epoch\n| json \"commits[0].id\" as base_commit_id\n| json \"commits[0].timestamp\" as base_commit_datetime\n| json \"commits[0].message\" as base_commit_message\n| parseDate(base_commit_datetime, \"yyyy-MM-dd'T'HH:mm:ss\",\"etc/utc\") as base_commit_epoch\n| json \"repository.name\",\"user_name\" as repository_name,user\n| \"push\" as event_type\n"

circleci_build_fer_scope = "circleci/job-collector\n"
circleci_build_fer_parse = "json \"workflows.job_name\" as job_type\n|where toLowerCase(job_type) matches \"BUILDJOBNAME\" \n|json \"custom_data.env\",\"custom_data.team\",\"custom_data.service\",\"workflows.job_id\",\"user.login\",\"build_url\",\"start_time\",\"branch\",\"outcome\",\"reponame\",\"vcs_revision\",\"job_name\",\"build_num\",\"messages\" as environment_name,team,service,trace_id,user,link,datetime,target_branch,job_status,repository_name,commit_id,job_name,build_number,message nodrop\n| if(job_status == \"success\", \"Success\", \"Failed\") as status\n| toLong(parseDate(datetime, \"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'\")) as datetime_epoch\n| concat(job_type, \" # \",build_number) as title\n|\"build\" as event_type"

circleci_deploy_fer_scope = "circleci/job-collector\n"
circleci_deploy_fer_parse = "json \"workflows.job_name\" as job_type\n|where toLowerCase(job_type) matches (\"DEPLOYJOBNAME\")\n|json \"custom_data.env\",\"custom_data.team\",\"custom_data.service\",\"workflows.job_id\",\"user.login\",\"build_url\",\"start_time\",\"branch\",\"outcome\",\"reponame\",\"vcs_revision\",\"job_name\",\"messages\",\"build_num\" as environment_name,team,service,trace_id,user,link,datetime,target_branch,job_status,repository_name,commit_id,job_name,message,job_num nodrop\n| if(job_status == \"success\", \"Success\", \"Failed\") as status\n| toLong(parseDate(datetime, \"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'\",\"etc/utc\")) as datetime_epoch\n| concat(job_type, \" # \",job_num) as title\n|\"deploy\" as event_type\n" 
