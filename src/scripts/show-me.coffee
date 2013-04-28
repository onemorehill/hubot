# Description:
#	Displays what builds are running in which environment
#
# Commands:
#	hubot show me <project> - Shows what version of a project is running in each environment.

# Currently running environments

Util = require "util"
http = require 'http'

mtnEnvironments = [
	"dev",
	"test",
	"integ",
	"prod"
]


module.exports = (robot) -> 
  robot.respond /(show me) (.*)/i, (msg) ->
  	thisProject = new ThisProject(msg, "cruisebook")
  	getForAll(mtnEnvironments, thisProject)

# Display what build of the project is running in various environment

getForAll = (env, project) ->
	for e in env
		do (e) ->
			project.is_running(e)


class ThisProject
	constructor: (msg, name) ->
		@msg = msg
		@name = name
		@display = {}

	is_running: (env) ->
		msg = @msg
		bodyData = ""
		envUp = env.toUpperCase().trim()
		http.get { host: "#{env}.cruisebook.mtnsatcloud.com", path: "/cruisebook/status/manifest/build-version"}, (res) ->
			res.setEncoding('utf8')
			res.on 'data', (chunk) ->
				bodyData += chunk
				msg.send "#{envUp} is running build: "  + bodyData

	is_what: (env) ->
		msg = @msg
		msg
			.http("http://#{env}.cruisebook.mtnsatcloud.com/cruisebook/configuration")
			.get() (err, res, body) ->
				msg.send body
