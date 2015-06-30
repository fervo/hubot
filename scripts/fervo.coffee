class FervoController
    constructor: (@robot) ->

    getPhoneNumber: (username) ->
        @robot.adapter.client?.getUserByName(username)?.profile.phone

    sendSMS: (number, message, onComplete) ->
        auth = process.env.FSELKS_AUTH
        data = "from=Fervo&to=#{encodeURIComponent(number)}&message=#{encodeURIComponent(message)}"
        @robot.http("https://api.46elks.com/a1/SMS")
            .header('Authorization', "Basic #{auth}")
            .post(data) onComplete

module.exports = (robot) ->
    controller = new FervoController robot

    robot.respond /send (.*) a message saying (.*)/i, (res) ->
        phone = controller.getPhoneNumber(res.match[1])
        res.send "Sure thing, boss!"
        controller.sendSMS phone, res.match[2], (err, httpres, body) ->
            if err or httpres.statusCode > 299
                res.send "Sorry, couldn't do it, boss! I ran into some trouble: #{body}"
            else
                res.send "It's done."

    robot.respond /what's (.*) phone number/i, (res) ->
        username = res.match[1]
        phone = controller.getPhoneNumber(username)
        res.reply "#{username}'s phone number is #{phone}"

