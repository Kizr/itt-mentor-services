module TeachingRecord
  class RestClient
    class Request
      include HTTParty
      base_uri ENV.fetch("TEACHING_RECORD_BASE_URL", "")
      headers "Accept" => "application/json",
              "Content-Type" => "application/json;odata.metadata=minimal",
              "Authorization" => "Bearer #{ENV.fetch("TEACHING_RECORD_API_KEY", "")}",
              "X-Api-Version" => ENV.fetch("TEACHING_RECORD_API_MINOR_VERSION", "20240101")
    end

    class TeacherNotFoundError < StandardError; end
    class HttpError < StandardError; end

    def self.get(path)
      response = Request.get("/v3/#{path}")

      if response.ok?
        JSON.parse(response.body || "{}")
      elsif response.not_found?
        raise(TeacherNotFoundError, "status: #{response.code}, body: #{response.body}, headers: #{response.headers}")
      else
        raise(HttpError, "status: #{response.code}, body: #{response.body}, headers: #{response.headers}")
      end
    end
  end
end
