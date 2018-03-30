#!/usr/bin/env ruby

require 'socket'
require 'resolv'
require 'date'
require 'json'
require 'logger'

# echo -n "[$(date +"%d/%m/%Y %H:%M")] Time to leave" | nc 127.0.0.1 1235

(ENV['APP_LISTEN_ADDRESS'].nil? || ENV['APP_LISTEN_ADDRESS'].empty?) ? app_address = '0.0.0.0' : app_address = ENV['APP_LISTEN_ADDRESS']
(ENV['APP_LISTEN_PORT'].nil? || ENV['APP_LISTEN_PORT'].empty?) ? app_port = 1234 : app_port = ENV['APP_LISTEN_PORT']

# https://ruby-doc.org/stdlib-2.4.0/libdoc/logger/rdoc/Logger.html
logger = Logger.new(STDOUT)
logger.level = Logger::WARN

begin
  server = TCPServer.new(app_address, app_port)
  # getting containername from DNS
  addr_infos = Socket.ip_address_list
  ip_address = addr_infos.last.ip_address
  resolver = Resolv::DNS.new
  container_name = resolver.getname(ip_address).to_s.split('.').first
  # container_name = 'test'
  logger.warn("Listening on #{app_address}:#{app_port}")
  while connection = server.accept
    while line = connection.gets
      break if line =~ /quit/
      if /^\[\d{1,2}\/\d{1,2}\/\d{4} \d{1,2}:\d{1,2}\].*$/ =~ line
        date_string = line.split(']').first[1..-1]
        client_msg = line.split(']').last.strip
        datetime = DateTime.strptime(date_string, '%d/%m/%Y %H:%M')
        responce = Hash.new
        responce[:timestamp] = datetime.to_time.to_i
        responce[:hostname] = `hostname`.strip
        responce[:container] = container_name
        responce[:message] = client_msg
        logger.info(line)
        connection.puts "#{responce.to_json}\n"
      else
        responce = Hash.new
        responce[:error]   = true
        responce[:message] = 'Invalid input data.'
        logger.warn(line)
        connection.puts "#{responce.to_json}\n"
      end
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
