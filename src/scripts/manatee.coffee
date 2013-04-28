# Description:
#   An HTTP Listener / Event Emitter for GitHub Commits
#
# Dependencies:
#
# Configuration:
#   None
#
# Commands:
#   sad manatee
#
# URLS:
#
# Authors:
#   lchang

module.exports = (robot) ->
	robot.respond /sad manatee (.+)/i, (msg) ->
		msg.send "http://www.manatees.net/manateeb.jpg#.png"