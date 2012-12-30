watch(%r{solutions/(\d+).rb}) do |m|
  system "clear"
  system "rake tasks:#{m[1]}"
  system "rspec specs/#{m[1]}_spec.rb --require ./#{m} --colour --format documentation"
end
