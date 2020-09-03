require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class PGE < OmniAuth::Strategies::OAuth2

      # Default client_options for this strategy
      option :client_options, {
        site: 'https://api.pge.com',
        authorize_url: "https://api.pge.com/datacustodian/test/oauth/v2/authorize",
        token_url: "https://api.pge.com/datacustodian/test/oauth/v2/token",
      }

      def scope_url
        auth_params = authorize_params
        params = {
          "client_id" => options[:client_id],
          "redirect_uri" => callback_url,
          "response_type" => "code",
          #required to ensure that PG+E redirects logged out accounts properly ->
          "scope" => "149112",
          "state" => auth_params[:state]
          #<----------------
        }
        query_string = URI.encode_www_form(params)

        "https://sharemydata.pge.com/myAuthorization/?" + query_string + "#authorization/welcome"
      end

      def build_access_token
        options.token_params.merge!(
          headers: {
            "Authorization" => authorization_header,
            "Content-Type" => "text/plain",
          },
        )

        params_string = URI.encode_www_form(
          "code" => request.params["code"],
          "grant_type" => "authorization_code",
          "redirect_uri" => callback_url
        )
        options[:client_options][:token_url] += "?" + params_string

        super
      end

      def authorization_header
        credential_string = "#{options[:client_id]}:#{options[:client_secret]}"
        encoded_credentials = Base64.urlsafe_encode64(credential_string)
        "Basic #{encoded_credentials}"
      end

      def redirect_to_scope
        session['omniauth.params'] = request.params
        if request.params['origin']
          env['rack.session']['omniauth.origin'] = request.params['origin']
        elsif env['HTTP_REFERER'] && !env['HTTP_REFERER'].match(/#{request_path}$/)
          env['rack.session']['omniauth.origin'] = env['HTTP_REFERER']
        end
        redirect scope_url
      end

      def request_call # rubocop:disable CyclomaticComplexity, MethodLength, PerceivedComplexity
        unless request.params['scope']
          return redirect_to_scope
        end

        setup_phase
        log :info, 'Request phase initiated.'
        # store query params from the request url, extracted in the callback_phase
        OmniAuth.config.before_request_phase.call(env) if OmniAuth.config.before_request_phase
        if options.form.respond_to?(:call)
          log :info, 'Rendering form from supplied Rack endpoint.'
          options.form.call(env)
        elsif options.form
          log :info, 'Rendering form from underlying application.'
          call_app!
        else
          request_phase
        end
      end

      def callback_url
        full_host + script_name + callback_path
      end

      info do
        access_token.to_hash
      end
    end
  end
end

module Faraday
  class Connection
    alias original_run_request run_request

    # Builds and runs the Faraday::Request.
    #
    # method  - The Symbol HTTP method.
    # url     - The String or URI to access.
    # body    - The String body
    # headers - Hash of unencoded HTTP header key/value pairs.
    #
    # Returns a Faraday::Response.
    def run_request(method, url, body, headers)
      original_run_request(method, url, "", headers)
    end
  end
end

OmniAuth.config.add_camelization 'pge', 'PGE'
