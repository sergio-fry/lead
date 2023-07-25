require_relative 'web_hook'

class HuginnHook
  def initialize(url)
    @hook = WebHook.new url
  end

  def post(data)
    @hook.post({ data: [data] })
  end
end
