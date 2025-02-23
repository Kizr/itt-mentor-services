class ApplicationMailer < Mail::Notify::Mailer
  GENERIC_NOTIFY_TEMPLATE = "a2c0c8f0-6d15-47db-b334-5fe198da1740".freeze

  default from: "no-reply@education.gov.uk"

  def notify_email(headers)
    headers.merge!(rails_mailer: mailer_name, rails_mail_template: action_name)
    view_mail(GENERIC_NOTIFY_TEMPLATE, headers)
  end

  private

  def service_name
    I18n.t("#{params[:service]}.service_name")
  end

  def default_url_options
    { host:, port: ENV["PORT"] }
  end

  def host
    case params[:service].to_s
    when "claims"
      ENV["CLAIMS_HOST"]
    when "placements"
      ENV["PLACEMENTS_HOST"]
    end
  end
end
