require 'socket'

module RestAssured
  class Client
    def self.start_server
      Kernel.system("bundle exec rest-assured -d :memory: -p #{free_tcp_port}")
    end

    private

    def self.free_tcp_port
      server = TCPServer.new('127.0.0.1', 0)
      free_port = server.addr[1]
      server.close
      free_port
    end
  end
end
