require 'slack'
require 'magic_eightball'
require 'logger'
require 'yaml'

#require 'treat'
#include Treat::Core::DSL

logger = Logger.new("./magic_eightball.log")

eightball_config = YAML.load(File.open("./.config") {|f| f.read})

Slack.configure do |config|
  config.token = eightball_config[:token]
end

auth = Slack.auth_test
fail auth['error'] unless auth['ok']

client = Slack.realtime

client.on :hello do
  logger.info "logged in"

  keep_alive = Thread.new do
     while true
       logger.debug "Checking connection at #{Time.now}"
       auth = Slack.auth_test
       fail auth['error'] unless auth['ok']
       sleep 3600
     end
  end
end

client.on :message do |data|




  text = data['text']
  logger.info("Message received: #{text} in #{data['channel']}")

  if text && text != "" && text[-1,1] == '?'
    logger.info("Question detected because it ended with a '?'")

    if rand(10) < 2
      response = MagicEightball.shake
      logger.info("And we're answering this one with #{response}")

      Slack.chat_postMessage channel: data['channel'],
        text: ":8ball: says... #{response}",
        username: eightball_config[:username]
    end
  end

  #sec = section(text).do(:chunk, :segment, :tokenize, :parse)
  #sec.each_sentence do |sent|
  #  if sent.tokens.first.tag == "WP" && sent.tokens.last.tag == "." && sent.tokens.last.to_s == "?"
  #    Slack.chat_postMessage channel: data['channel'],
  #      text: ":8ball: says... #{MagicEightball.shake}",
  #      username: 'Sporadically Interrupting Magic Eightball'

  #    break
  #  end
  #end
end

client.start
