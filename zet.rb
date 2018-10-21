#!/usr/bin/ruby -w

require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'fileutils'
require 'optparse'
include FileUtils

OPTIONS = {:next=>false, :bus_line=>"0", :dir=>0}
DIRS = []
TIMES = [[], []]

def parse_args
  OptionParser.new do |opts|
    opts.banner = "Usage: zet.rb [options]"
    
    opts.on("-b BUS_LINE", "--bus BUS_LINE", "Choose bus line") do |o|
      OPTIONS[:bus_line] = o
    end
  
    opts.on("-n", "--next", "Get the leaving time of the next bus from now") do |o|
      OPTIONS[:next] = o
    end
  
    opts.on("-d DIRECTION_NUMBER", "--dir DIRECTION_NUMBER", "Choose direction ( can be 0 or 1 )") do |o|
      OPTIONS[:dir] = o
    end
  end.parse!
end

def get_next
  curr_time = Time.now

  for time in TIMES[OPTIONS[:dir].to_i]
    if curr_time < time
      print(time.hour, ":", time.min, "\n")
      break
    end
  end
end

def main
  
  url="http://www.zet.hr/raspored-voznji/325?route_id=" + OPTIONS[:bus_line]
  page = Nokogiri::HTML(open(url))

  page_times = page.css('[class="col-lg-6 col-md-6 col-sm-6 col-xs-12"]')

  DIRS.push page_times[0].children[1].content
  DIRS.push page_times[1].children[1].content

  # puts times[0].children[3].children[1].children[0].content

  first = true

  curr_time = Time.now

  page_times[0].children[3].children.each do |i|
    unless i.children[0].nil?
      unless first then
        TIMES[0].push(Time.new(curr_time.year, curr_time.month, curr_time.day, i.children[0].content[0..1], i.children[0].content[3..4]))
      end
      first = false
    end
  end

  first = true

  page_times[1].children[3].children.each do |i|
    unless i.children[0].nil?
      unless first then
        # TIMES[1].push(i.children[0].content)
        TIMES[1].push(Time.new(curr_time.year, curr_time.month, curr_time.day, i.children[0].content[0..1], i.children[0].content[3..4]))
        # puts i.children[0].content
      end
      first = false
    end
  end

  if OPTIONS[:next]
    get_next
  end
end

parse_args
main