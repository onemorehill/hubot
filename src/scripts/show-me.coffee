# Description:
#	Displays what builds are running in which environment
#
# Commands:
#	hubot show me <project> running - Shows what version of a project is running in each environment.
# hubot show me <project> status - Shows the status for project for each environment.
#
# Currently running environments
#
# Author:
#		leetchang

Util = require "util"

mtnEnvironments = [
	"dev",
	"test",
	"integ",
	"prod"
]

module.exports = (robot) ->

	# TODO add ability to change projects
	# Hardcoded to cruisebook now
  robot.respond /(show me) (cruisebook) (running|status)/i, (msg) ->
  	thisProject = new ThisProject(msg, "cruisebook")
  	condition = msg.match[3]
  	if condition == "status"
  		getStatus(mtnEnvironments, thisProject)
  	else if condition == "running"
  		getRunning(mtnEnvironments, thisProject)
  	else
  		msg.send "I don't understand what you asking for => use running or status"

# Display what build of the project is running in various environment
getRunning = (env, project) ->
	for e in env
		do (e) ->
			project.is_running(e)

getStatus = (env, project) ->
	for e in env
		do (e) ->
			project.get_status(e)

###########################################################
## Project
###########################################################

class ThisProject
	constructor: (msg, name) ->
		@msg = msg
		@name = name
		@url = "#{name}.mtnsatcloud.com"
		@buildInfo = "/#{name}/status/manifest/build-version"
		@statusInfo = "/#{name}/configuration"

	is_running: (env) ->
		msg = @msg
		url = env + "." + @url
		urlUp = env.toUpperCase().trim() + "." + @url
		buildInfo = @buildInfo
		msg
			.http("http://#{url}#{buildInfo}")
			.get() (err,res, body) ->
				msg.send "#{urlUp} is running build: "  + body

	get_status: (env) ->
		msg = @msg
		url = env + "." + @url
		statusInfo = @statusInfo
		urlUp = env.toUpperCase().trim() + "." + @url
		msg
			.http("http://#{url}#{statusInfo}")
			.get() (err, res, body) ->
				bodyData = JSON.parse(body)
				systemStatus = bodyData.system_status.message.toUpperCase().trim()
				clientVersion = bodyData.min_client_version
				msg.send "#{urlUp}\n====================\n" +
					"System status is: #{systemStatus}\n" +
					"Minimum client version is: #{clientVersion}"
