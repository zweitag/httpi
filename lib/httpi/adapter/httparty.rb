require "httpi/response"

module HTTPI
  module Adapter

    # = HTTPI::Adapter::HTTParty
    #
    # Adapter for the HTTParty client.
    class HTTParty
      
      # Requires the "httparty" gem.
      def initialize(request = nil)
        require "httparty"
      end

      # Returns a memoized <tt>Curl::Easy</tt> instance.
      def client
        @client ||= Client.new
      end

      # Executes an HTTP GET request.
      # @see HTTPI.get
      def get(request)
        do_request(request) { |client, _| client.http_get }
      end

      # Executes an HTTP POST request.
      # @see HTTPI.post
      def post(request)
        do_request(request) { |client, body| client.http_post body }
      end

      # Executes an HTTP HEAD request.
      # @see HTTPI.head
      def head(request)
        do_request(request) { |client,_| client.http_head }
      end

      # Executes an HTTP PUT request.
      # @see HTTPI.put
      def put(request)
        do_request(request) { |client, body| client.http_put body }
      end

      # Executes an HTTP DELETE request.
      # @see HTTPI.delete
      def delete(request)
        do_request(request) { |client,_| client.http_delete }
      end

    private
    
      class Client
        include ::HTTParty
        
        attr_accessor :response, :body, :timeout
        
        def initialize
#           puts "We must party hard..."
        end
        
        def method_missing(m, *args)
          self.class.send m, *args
        end
        
        def http_get
          @response ||= self.get "", :timeout => timeout
        end
        
        def http_post(body)
          @response ||= self.post "", :body => body, :timeout => timeout
        end
        
        def http_head
          @response ||= self.head "", :timeout => timeout
        end
        
        def http_put(body)
          @response ||= self.put "", :body => body, :timeout => timeout
        end
        
        def http_delete
          @response ||= self.delete "", :timeout => timeout
        end
        
        
      end

      def do_request(request)
        setup_client request
        yield(client, client.body)
        respond_with client
      end

      def setup_client(request)
        basic_setup request
        setup_http_auth request if request.auth.http?
        setup_ssl_auth request.auth.ssl if request.auth.ssl?
      end

      def basic_setup(request)
        client.base_uri request.url.to_s
        client.body = request.body
#         client.proxy_url = request.proxy.to_s if request.proxy
        client.timeout = request.read_timeout if request.read_timeout
#         client.connect_timeout = request.open_timeout if request.open_timeout
        client.headers request.headers
#         client.verbose = false
      end

#       def setup_http_auth(request)
#         client.http_auth_types = request.auth.type
#         client.username, client.password = *request.auth.credentials
#       end

#       def setup_ssl_auth(ssl)
#         client.cert_key = ssl.cert_key_file
#         client.cert = ssl.cert_file
#         client.cacert = ssl.ca_cert_file if ssl.ca_cert_file
#         client.ssl_verify_peer = ssl.verify_mode == :peer
#       end

      def respond_with(client)
        Response.new client.response.code, client.headers, client.response.body
      end

    end
  end
end
