require_relative 'web_hook'

class SlackHook
  def initialize(url, channel)
    @channel = channel
    @hook = WebHook.new url
  end

  def post_blocks(blocks)
    @hook.post({
      channel: @channel,
      blocks: blocks,
    })
  end

  def post(markdown)
    @hook.post({
      channel: @channel,
      blocks:
      [
        {
          "type": 'section',
          "text": {
            "type": 'mrkdwn',
            "text": markdown,
          },
        },
      ],
    })
  end
end
