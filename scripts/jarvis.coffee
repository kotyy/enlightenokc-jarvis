# Description:
#   Example scripts for you to examine and try out.
#
# Notes:
#   They are commented out by default, because most of them are pretty silly and
#   wouldn't be useful and amusing enough for day to day huboting.
#   Uncomment the ones you want to try and experiment with.
#
#   These are from the scripting documentation: https://github.com/github/hubot/blob/master/docs/scripting.md

module.exports = (robot) ->

    # Description:
    #   Submit time query to www.timeapi.org
    # https://gist.github.com/robcowie/4519412
    # Commands:
    #   hubot time - Current time in local timezone
    #   hubot time <timezone> - Current time in timezone
    #   hubot time <timezone> <query> - Time in timezone based on query 
  robot.respond /time (\D{3})([\d\D ]*)/i, (msg) ->
    tz = msg.match[1] || "utc"
    q = msg.match[2].trim() || "now"
    url = "http://www.timeapi.org/" + tz + "/" + q
    msg.http(url)
      .get() (err, res, body) ->
        if res.statusCode == 500
          msg.send "Sorry, I don't understand that time query. See http://chronic.rubyforge.org"
        else
          msg.send body
          
  welcomeResponses = [
      "No problem!", 
      "I'm glad to help!", 
      "Happy to be of assistance.", 
      "Don't tell anyone, but you're my favorite frog.", 
      "You're Welcome.",
      "My pleasure.",
      "No trouble!",
      "Anytime.",
  ]
  robot.hear /(?:thanks|thank you|thanx|thnx|thx|ty) jarvis/i, (msg) ->
    msg.reply msg.random welcomeResponses

  salutations = [
    "Nice to meet you.",
    "Hi to you, too!",
    "Oh, hello!",
    "Happy to make your acquaintance.",
    "We've got such a smurf problem around these parts... OH! Didn't see you. Hi!",
  ]
  robot.hear /(?:hi|hello|good morning|good afternoon|good evening) jarvis/i, (msg) ->
    msg.reply msg.random salutations
        
  robot.hear /smurf/i, (msg) ->
    msg.send "Smurfs? SMURFS? WE DON'T NEED NO STINKIN SMURFS."
  
  # https://www.ingress.com/intel?ll=-77.846809,166.665052&z=17
  robot.hear /https:\/\/www.ingress.com\/intel\?ll=([0-9\-\.]+),([0-9\-\.]+)&z=(\d+)/i, (msg) ->
    lat = msg.match[1]
    lon = msg.match[2]
    zoom = msg.match[3]
    msg.send "https://www.google.com/maps/dir//#{lat},#{lon}/@#{lat},#{lon},#{zoom}z"

  robot.respond /open the (.*) doors/i, (msg) ->
    doorType = msg.match[1]
    if doorType is "pod bay"
      msg.reply "I'm afraid I can't let you do that."
    else
      msg.reply "Opening #{doorType} doors"
  
  
  robot.googleGeocodeKey = process.env.HUBOT_GOOGLE_GEOCODE_KEY
  googleGeocodeUrl = 'https://maps.googleapis.com/maps/api/geocode/json'

  lookupLatLong = (msg, location, cb) ->
    params =
      address: location
    params.key = robot.googleGeocodeKey if robot.googleGeocodeKey?

    msg.http(googleGeocodeUrl).query(params)
      .get() (err, res, body) ->
        try
          body = JSON.parse body
          coords = body.results[0].geometry.location
        catch err
          err = "Could not find #{location}"
          return cb(err, msg, null)
        cb(err, msg, coords)

  missionMapUrl = (coords) ->
    return "https://www.google.com/fusiontables/embedviz?q=select+col8+from+1fcYuKkOVrEW-1BbndpfbkFBShjEQHL7e1cT6A1cm&viz=MAP&h=false&lat=" + encodeURIComponent(coords.lat) + "&lng=" + encodeURIComponent(coords.lng) + "&t=1&z=13&l=col8&y=2&tmplt=2&hml=TWO_COL_LAT_LNG"

  sendIntelLink = (err, msg, coords) ->
    return msg.send err if err
    url = missionMapUrl coords
    msg.reply "<a href='" + url + "'>Here you go!</a>"

  robot.respond /(mission)(?: for)?\s(.*)/i, (msg) ->
    location = msg.match[2]
    lookupLatLong msg, location, sendIntelLink
  
  # robot.hear /I like pie/i, (msg) ->
  #   msg.emote "makes a freshly baked pie"
  #
  # lulz = ['lol', 'rofl', 'lmao']
  #
  # robot.respond /lulz/i, (msg) ->
  #   msg.send msg.random lulz
  #
  # robot.topic (msg) ->
  #   msg.send "#{msg.message.text}? That's a Paddlin'"
  #
  #
  # enterReplies = ['Hi', 'Target Acquired', 'Firing', 'Hello friend.', 'Gotcha', 'I see you']
  # leaveReplies = ['Are you still there?', 'Target lost', 'Searching']
  #
  # robot.enter (msg) ->
  #   msg.send msg.random enterReplies
  # robot.leave (msg) ->
  #   msg.send msg.random leaveReplies
  #
  # answer = process.env.HUBOT_ANSWER_TO_THE_ULTIMATE_QUESTION_OF_LIFE_THE_UNIVERSE_AND_EVERYTHING
  #
  # robot.respond /what is the answer to the ultimate question of life/, (msg) ->
  #   unless answer?
  #     msg.send "Missing HUBOT_ANSWER_TO_THE_ULTIMATE_QUESTION_OF_LIFE_THE_UNIVERSE_AND_EVERYTHING in environment: please set and try again"
  #     return
  #   msg.send "#{answer}, but what is the question?"
  #
  # robot.respond /you are a little slow/, (msg) ->
  #   setTimeout () ->
  #     msg.send "Who you calling 'slow'?"
  #   , 60 * 1000
  #
  # annoyIntervalId = null
  #
  # robot.respond /annoy me/, (msg) ->
  #   if annoyIntervalId
  #     msg.send "AAAAAAAAAAAEEEEEEEEEEEEEEEEEEEEEEEEIIIIIIIIHHHHHHHHHH"
  #     return
  #
  #   msg.send "Hey, want to hear the most annoying sound in the world?"
  #   annoyIntervalId = setInterval () ->
  #     msg.send "AAAAAAAAAAAEEEEEEEEEEEEEEEEEEEEEEEEIIIIIIIIHHHHHHHHHH"
  #   , 1000
  #
  # robot.respond /unannoy me/, (msg) ->
  #   if annoyIntervalId
  #     msg.send "GUYS, GUYS, GUYS!"
  #     clearInterval(annoyIntervalId)
  #     annoyIntervalId = null
  #   else
  #     msg.send "Not annoying you right now, am I?"
  #
  #
  # robot.router.post '/hubot/chatsecrets/:room', (req, res) ->
  #   room   = req.params.room
  #   data   = JSON.parse req.body.payload
  #   secret = data.secret
  #
  #   robot.messageRoom room, "I have a secret: #{secret}"
  #
  #   res.send 'OK'
  #
  # robot.error (err, msg) ->
  #   robot.logger.error "DOES NOT COMPUTE"
  #
  #   if msg?
  #     msg.reply "DOES NOT COMPUTE"
  #
  # robot.respond /have a soda/i, (msg) ->
  #   # Get number of sodas had (coerced to a number).
  #   sodasHad = robot.brain.get('totalSodas') * 1 or 0
  #
  #   if sodasHad > 4
  #     msg.reply "I'm too fizzy.."
  #
  #   else
  #     msg.reply 'Sure!'
  #
  #     robot.brain.set 'totalSodas', sodasHad+1
  #
  # robot.respond /sleep it off/i, (msg) ->
  #   robot.brain.set 'totalSodas', 0
  #   robot.respond 'zzzzz'
