
# Description
#   Returns hubot's uptime
#
# Dependencies:
#   "checklist-ninja": ""
#   "hubot-script-installer": ""
#
# Configuration:
#   HUBOT_CHECKLIST_PUBKEY, HUBOT_CHECKLIST_SECRET
#
# Commands:
#   hubot create checklist <title> - creates checklist
#   hubot list checklists - lists checklists 
#   hubot switch checklists <id> - switches active checklist
#   hubot active checklist - responds with active checklist
#
# Author:
#   markhuge


ninja = require 'checklist-ninja'

pubkey = process.env.HUBOT_CHECKLIST_PUBKEY
secret = process.env.HUBOT_CHECKLIST_SECRET

ninja.config
  pubkey: pubkey
  secret: secret

currentList = {}

handleMsg = (msg, callback) ->
  unless pubkey
    msg.send "Checklist Ninja pubkey is not set"
    msg.send "Please set the HUBOT_CHECKLIST_PUBKEY environment variable"
    return

  unless secret
    msg.send "Checklist Ninja secret key is not set"
    msg.send "Please set the HUBOT_CHECKLIST_SECRET environment variable"
    return

  callback()


module.exports = (robot) ->
  
# Create Checklist
  robot.respond /create checklist (.*)/i, (msg) ->
    handleMsg msg, ->
      name = msg.match[1]
      unless name
        return msg.reply "Please specify a name for your list"

      ninja.createChecklist name, (err, data) ->
        if err then return msg.send "Error #{err}"

        currentList = data
        data        = JSON.stringify(data)
        return msg.send "List created: #{data}"

# Create item
  robot.respond /create item (.*)/i, (msg) ->
    handleMsg msg, ->
      name = msg.match[1]
      unless currentList.id
        msg.reply "No active checklist(s)"
        msg.send "use '#{robot.name} switch checklist <id>' to set the active list"
      
      # Position is default to 1 for now. no idea what parent is...
      ninja.createItem currentList.id, name, currentList.id, 1, (err, data) ->
        if err then return msg.send "Error #{err}"
        
        data = JSON.stringify(data)
        return msg.send "Item created: #{data}"

# Switch active checklist
  robot.respond /switch checklists* (.*)/i, (msg) ->
    handleMsg msg, ->
      listID = msg.match[1]
      unless listID
        return msg.reply "Please specify an ID for your list"

      ninja.getChecklist listID, (err, data) ->
        if err then return msg.send "Error #{err}"
        currentList = data
        
        return msg.send "Active list set to: #{currentList.label} ID: #{currentList.id}"


# Show active checklist
  robot.respond /active checklists*/i, (msg) ->
    handleMsg msg, ->
      unless currentList.label
        msg.reply "No active checklist(s)"
        msg.send "use '#{robot.name} switch checklist <id>' to set the active list"
        return
      msg.send "Active Checklist #{currentList.label} ID: #{currentList.id}"




