class WebHook
  def initialize(url)
    @url = url
  end

  def post(data)
    HTTP
      .headers(content_type: 'application/json')
      .post(@url, body: data.to_json)
  end
end
