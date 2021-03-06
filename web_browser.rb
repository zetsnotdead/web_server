require 'socket'
require 'json'

class WebBrowser
  def initialize
    start
  end

  private

  def start
    what_to_do

    case @verb
    when "GET"
      get_url
      open_socket
      send_request
      recieve_headers
      read_status_code
      recieve_body
      close_socket
    when "POST"
      ask_for_input
      open_socket
      send_request
      send_body
      recieve_result
      close_socket
    end
  end

  ## USER INPUT
  def what_to_do
    puts "What do you wan to do? GET / POST"
    @verb = gets.chomp
  end

  def ask_for_input
    results = {viking: {}}
    puts "Viking name"
      results[:viking][:name] =  gets.chomp
     puts "Viking email"
      results[:viking][:email] = gets.chomp
    @body = results.to_json
  end

  def get_url
    puts "Enter URL, ex localhost/index.html"
    @host, @path = gets.chomp.split("/")
  end

  ## SOCKET

  def close_socket
    @socket.close
  end

  def open_socket
    @socket = TCPSocket.new(@host, 2000)
  end


  # RECIEVING
  def recieve_headers
   headers = []
    while line = @socket.gets and line !~ /^\s*$/
      headers << line.chomp
  end

    @response_headers = headers
  end

  def recieve_body
    puts "server head response ...\n#{@response_headers.join("\n")} "
    unless @code == 404
      read_length
      body = @socket.read(@length)
      puts "\nserver body response ...\n#{body} "
    end
  end

  def recieve_result
    results = []
      while line = @socket.gets and line !~ /^\s*$/
        results << line.chomp
      end
    puts results.join("\n")
  end


  ## SENDING REQUESTS
  def send_body
    @socket.puts  @body
  end

  def send_request
    request_line = "#{@verb} #{@path} HTTP/1.0\r\n"
    headers = create_headers

    request = request_line + headers + "\r\n"
    puts "\nrequesting ... \n#{request}"

    @socket.puts request
  end


  def create_headers
    header1 = "From: test@test\r\n"
    header2 = "User-Agent: test@test.com\r\n"
    header3 = "Content-Length: #{@body.length}\r\n" if @verb == "POST"

    headers = case @verb
              when "POST" then header1 + header2 + header3
              when "GET" then header1 + header2
              end
  end

  def read_length
    @length = @response_headers.select {|line| line =~ /Content-Length:/}.to_s.gsub(/\D/, "").to_i
  end

  def read_status_code
    @code = @response_headers[0].split(" ")[1].to_i
  end

  def error
    puts "Error 404, Not Found!"
  end
end

WebBrowser.new






