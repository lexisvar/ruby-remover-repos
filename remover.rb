require 'optparse'
require 'rest-client'
require 'json'

options = {}
@api_url = 'https://api.github.com/'

class Parser
  def self.parse(args)
    options = {}
    opt_parser = OptionParser.new do |opts|
      opts.banner = 'Usage: ruby remover.rb [options] ARG...'
      opts.separator 'Delete github repos.'
      opts.separator 'Example: ruby remover.rb -t <token> -r <repos-file>'
      
      opts.separator ''
      opts.separator 'Options:'

      opts.on('-tTOKEN', '--token=TOKEN', '# token (required)') do |t|
        options[:token] = t
      end

      opts.on('-repos', '--repos=REPOS', '# Creates a file with the repos that can be removed (optional)') do |r|
        options[:repos] = r
      end

      opts.on('-v', '--[no-]verbose', 'Run verbosely') do |v|
        options[:verbose] = v
      end
      
      opts.separator ''
      opts.separator 'Help options:'
      
      opts.on('-h', '--help', 'Prints this help') do
        puts opts
        exit
      end
    end

    opt_parser.parse!(args)
    return options
  end
end

begin
  options = Parser.parse ARGV
rescue Exception => e
  puts "Exception encountered: #{e}"
  exit 1
end

#Print the usage if there are no arguments.
Parser.parse %w[--help] if options.empty?

# Set the verbose option if the ruby verbose flag is on
options[:verbose] = true if $VERBOSE 

# Print options

if options[:verbose]
  @start = Time.now
end

[:token, :repos].each do |opt|
  if options[opt].nil?
    puts options
    puts "Missing #{opt} argument"
    exit 1
  end
end

def list_repos(token, filename)
  begin
    r = RestClient.get "#{@api_url}user/repos", {:Authorization => "Bearer #{token}", params: {per_page: 100}}
    repos = JSON.parse r.body

    File.open(filename, "w+") do |f|
      repos.each do |repo|
        if(repo['permissions']['admin'])
          f.puts(repo['full_name'])
        end
      end
    end

    puts "File #{filename} was created successfully. Please remove from this file repos that will be not deleted from your GitHub account"
    
  rescue Exception => e
    puts "Exception encountered: #{e}"
    exit 1
  end
end

def remove_repos(token, filename)
  begin
    
    File.readlines(filename).each do |repo|
      puts repo
    end
    puts " "
    puts "**********************************************************************************"
    puts "* This repo list will be deleted from your Github Account are you sure? [yes|no] *"
    puts "**********************************************************************************"
    puts " "
    delete = gets

    if delete.chomp === 'yes'
      File.readlines(filename).each do |repo|
        puts "deleting #{repo}"
        r = RestClient.delete "#{@api_url}repos/#{repo.chomp}", {:Authorization => "Bearer #{token}"}
        if r.code == 204
          puts "deleted successfully"
        else
          puts "not found"
        end
      end
    else
      puts 'Okay neither repo will be deleted.'
    end
    
  rescue Exception => e
    puts "Exception encountered: #{e}"
    exit 1
  end
end

if options[:repos]
  if File.zero?(options[:repos])
    list_repos(options[:token], options[:repos])
  else 
    remove_repos(options[:token], options[:repos])
  end
end

if options[:verbose]
  elapsed = Time.now - @start
  puts 'Elapsed time: ' +  elapsed.to_s + ' seconds'
end