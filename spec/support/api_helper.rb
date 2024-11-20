# frozen_string_literal: true

module ApiHelper
  def authenticated_header(headers, user)
    {
      **headers,
      'Authorization' => "Bearer #{JWT.encode(user.jwt_payload, ENV['JWT_SECRET'])}"
    }
  end

  def to_strong_parameters(params)
    ActionController::Parameters.new(params).permit!.tap do |whitelisted|
      stringify_values(whitelisted)
    end
  end

  private

  def stringify_values(values)
    return values unless values.respond_to?(:transform_values!)

    values.transform_values! do |value|
      if value.is_a?(ActionController::Parameters)
        stringify_values(value)
      elsif value.is_a?(Array)
        value.map { |element| stringify_values(element) }
      elsif [Rack::Test::UploadedFile, ActionDispatch::Http::UploadedFile].include?(value.class)
        value
      else
        value.to_s
      end
    end
  end
end
