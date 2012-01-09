# A quickie script to do bulk renaming of Album ID3 tags in my music collection.


require 'taglib'

if ARGV.empty?
    puts 'Require atleast one argument - the full directory to start operation.'
    puts "#{__FILE__} /path/to/mp3"
    exit
end

runPath = ARGV[0]

puts 'Starting on path :', runPath

dirStack = []
dirStack.push runPath

until dirStack.empty?
    currDir = dirStack.pop
    Dir.chdir currDir 

    # Add sub-directories in path
    dirList = Dir.glob('*').select do |entryName|
        if File.directory? entryName and not (entryName.eql? '.' or entryName.eql? '..')
            true
        end
    end
    dirList.collect! { |entryName| "#{currDir}/#{entryName}" }
    dirStack = dirStack | dirList

    # Has any MP3s ?
    fileList = Dir.glob('*.mp3')
    if fileList.empty?
        next    
    end
    
    puts "Current Directory: #{currDir}"

    # Display ID3 if first file
    puts "First file info:"
    file = TagLib::MPEG::File.new fileList[0]
    tag = file.id3v2_tag
    albumName = tag.album
    puts albumName
    file.close

    puts 'What to do - Edit All(e) or Check All Files(c) or Skip(any key) ?'
    userInp = STDIN.gets.chomp

    case userInp
    when 'e'
        puts 'Enter new value for Album tag:'
        albumName = STDIN.gets.chomp
            
        fileList.each do |fileName|
            puts fileName
            file = TagLib::MPEG::File.new fileName
            tag = file.id3v2_tag
            tag.album = albumName
            file.save
            file.close
        end

    when 'c'
        puts 'Checking if all files have consistent album names:'
        fileList.each do |fileName|
            puts fileName
            file = TagLib::MPEG::File.new fileName
            tag = file.id3v2_tag
            if tag.album != albumName
                puts "#{fileName}'s album differs: #{tag.album} vs #{albumName}. What to do - Overwrite(o) or Give New Name(g) or Skip(any key)?"
                userInp = STDIN.gets.chomp
                case userInp
                when 'o'
                    tag.album = albumName
                    file.save
                when 'g'
                    puts 'Type in new name:'
                    newAlbumName = STDIN.gets.chomp
                    tag.album = newAlbumName
                    puts "Overwritten with #{newAlbumName}."
                    file.save
                end
                file.close
            end
        end
    else
        puts 'Skipping current folder.'
        next    
    end
end
