#!/usr/bin/env ruby

require 'socket'
require 'date'
require 'json'
require 'logger'

# echo -n "[$(date +"%d/%m/%Y %H:%M")] Time to leave" | nc 127.0.0.1 1235

(ENV['APP_LISTEN_ADDRESS'].nil? || ENV['APP_LISTEN_ADDRESS'].empty?) ? app_address = '0.0.0.0' : app_address = ENV['APP_LISTEN_ADDRESS']
(ENV['APP_LISTEN_PORT'].nil? || ENV['APP_LISTEN_PORT'].empty?) ? app_port = 1234 : app_port = ENV['APP_LISTEN_PORT']

# https://ruby-doc.org/stdlib-2.4.0/libdoc/logger/rdoc/Logger.html
logger = Logger.new(STDOUT)
logger.level = Logger::WARN

server = TCPServer.new(app_address, app_port)
begin
  logger.warn("Listening on #{app_address}:#{app_port}")
  while connection = server.accept
    while line = connection.gets
      break if line =~ /quit/
      date_string = line.split(']').first[1..-1]
      client_msg = line.split(']').last.strip
      datetime = DateTime.strptime(date_string, '%d/%m/%Y %H:%M')
      responce = Hash.new
      responce[:timestamp] = datetime.to_time.to_i
      # responce[:hostname] = datetime.to_i
      responce[:container] = `hostname`.strip
      responce[:message] = client_msg
      logger.info(line)
      connection.puts "#{responce.to_json}\n"
    end
    connection.close
  end
rescue SignalException => e
  logger.warn("Exiting server...")
rescue Errno::ECONNRESET, Errno::EPIPE => e
  puts e.message
  logger.fatal(e.message)
  retry
end
