require "rails_helper"

RSpec.describe TeachingRecord::GetTeacher do
  context "with invalid trn" do
    subject(:get_teacher) { described_class.call(trn: "2222222") }

    before { failure_stub_request }

    it "raises error" do
      expect { get_teacher }.to raise_error(TeachingRecord::RestClient::TeacherNotFoundError)
    end
  end

  context "with valid trn" do
    subject(:get_teacher) { described_class.call(trn: "1234567") }

    before { success_stub_request }

    it "returns teacher details" do
      teacher = get_teacher
      expect(teacher).to match({
        "trn" => "1234567",
        "firstName" => "Judith",
        "middleName" => "",
        "lastName" => "Chicken",
        "dateOfBirth" => "1991-01-22",
        "nationalInsuranceNumber" => "B15J60R13",
        "email" => "anonymous@anonymousdomain.org.net.co.uk",
        "qts" => nil,
        "eyts" => nil,
      })
    end
  end

  context "when we receive an response that is not ok? or not_found?" do
    subject(:get_teacher) { described_class.call(trn: "xxxxxxx") }

    before { unhandled_stub_request }

    it "raises generic HttpError" do
      expect { get_teacher }.to raise_error(TeachingRecord::RestClient::HttpError)
    end
  end

  def success_stub_request
    stub_request(:get, "https://preprod.teacher-qualifications-api.education.gov.uk/v3/teachers/1234567")
      .with(
        headers: {
          "Accept" => "application/json",
          "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
          "Authorization" => "Bearer secret",
          "Content-Type" => "application/json;odata.metadata=minimal",
          "User-Agent" => "Ruby",
          "X-Api-Version" => "20240101",
        },
      )
      .to_return(
        status: 200,
        body: "{\"trn\":\"1234567\",\"firstName\":\"Judith\",\"middleName\":\"\",\"lastName\":\"Chicken\",\"dateOfBirth\":\"1991-01-22\",\"nationalInsuranceNumber\":\"B15J60R13\",\"email\":\"anonymous@anonymousdomain.org.net.co.uk\",\"qts\":null,\"eyts\":null}",
        headers: {},
      )
  end

  def failure_stub_request
    stub_request(:get, "https://preprod.teacher-qualifications-api.education.gov.uk/v3/teachers/2222222")
      .with(
        headers: {
          "Accept" => "application/json",
          "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
          "Authorization" => "Bearer secret",
          "Content-Type" => "application/json;odata.metadata=minimal",
          "User-Agent" => "Ruby",
          "X-Api-Version" => "20240101",
        },
      )
      .to_return(
        status: 404,
        body: "{\"type\":\"https://tools.ietf.org/html/rfc9110#section-15.5.5\",\"title\":\"Not Found\",\"status\":404,\"traceId\":\"00-dff9d2243466591e882b480c8bdbfc27-f60a1ced105d1602-00\"}",
        headers: {},
      )
  end

  def unhandled_stub_request
    stub_request(:get, "https://preprod.teacher-qualifications-api.education.gov.uk/v3/teachers/xxxxxxx")
      .with(
        headers: {
          "Accept" => "application/json",
          "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
          "Authorization" => "Bearer secret",
          "Content-Type" => "application/json;odata.metadata=minimal",
          "User-Agent" => "Ruby",
          "X-Api-Version" => "20240101",
        },
      )
      .to_return(
        status: 500,
        body: "{\"type\":\"https://tools.ietf.org/html/rfc9110#section-15.5.5\",\"title\":\"Not Found\",\"status\":404,\"traceId\":\"00-dff9d2243466591e882b480c8bdbfc27-f60a1ced105d1602-00\"}",
        headers: {},
      )
  end
end
