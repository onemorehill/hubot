# Description:
#	Displays what builds are running in which environment
#
# Commands:
#	hubot show me <project> - Shows what version of a project is running in each environment.
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

	is_running: (env) ->
		msg = @msg
		envUp = env.toUpperCase().trim()
		msg
			.http("http://#{env}.cruisebook.mtnsatcloud.com/cruisebook/status/manifest/build-version")
			.get() (err,res, body) ->
				msg.send "#{envUp} is running build: "  + body

	get_status: (env) ->
		msg = @msg
		envUp = env.toUpperCase().trim()
		msg
			.http("http://#{env}.cruisebook.mtnsatcloud.com/cruisebook/configuration")
			.get() (err, res, body) ->
				bodyData = JSON.parse(body)
				systemStatus = bodyData.system_status.message.toUpperCase().trim()
				clientVersion = bodyData.min_client_version
				msg.send "#{envUp}\n====================\n" +
					"System status is: #{systemStatus}\n" +
					"Minimum client version is: #{clientVersion}"
