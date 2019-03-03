$searchIP = "192.168.0.11"      # replace target string 置換対象文字列
$replaceIP = "192.168.0.22"     # replaced string 置換後文字列
$searchFileAry = [
	"/Users/username/ruby/testFile.txt",
	"/Users/username/ruby/testFile2.txt",
]                              # replace target files置換処理対象ファイル


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# ↑user settings 上記を修正してから実行
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
require 'io/console'

def searchInFile(filename, searchStr)
	hitHash = {}
	File.open(filename, "r") do |f|
		lineNumber = 0
		f.each_line do |line|
			lineNumber += 1
			hitHash[lineNumber] = line.chomp if line.chomp =~ /#{searchStr}/
		end
	end
	return hitHash
end

def searchInFiles(searchFileAry, searchStr)
	resultHash = {}
	searchFileAry.each do |filename|
		hitHash = searchInFile(filename, Regexp.escape(searchStr))
		resultHash[filename] = hitHash if hitHash.size > 0
	end
	resultHash.each do |filename, hitHash|
		hitHash.each { |key, val| puts("#{filename} line#{key}: #{val}") }
	end
end

def replaceInFile(filename, searchStr, replaceStr)
	buffer = File.open(filename, "r") { |r| r.read() }
	buffer.gsub!(searchStr, replaceStr)
	File.open(filename, "w") { |f| f.write(buffer) }
end

def createMySQLCommand
	puts(" ================= Paste Bellow Command After Connecting Vagrant SSH [START] ================= ")
  puts("[option] automatically create sql for update DB. change code for your environment.")
	puts("mysql -uroot -ppassword dbname")
	puts("update TABLE_NAME set VALUE='#{$replaceIP}' where VALUE='#{$replaceIP}';)
	puts(" ================= Paste Bellow Command After Connecting Vagrant SSH [END] ================= ")

end

def main
	puts(" ================= Search Start ================= ")
	# 検索対象の一覧表示
	resultHash = searchInFiles($searchFileAry, $searchIP)
	if resultHash.size == 0
		puts("Keyword '#{$searchIP}' is not founds in Files #{$searchFileAry}")
		exit 0
	end
	
	# 書き換え最終確認
	puts("Do you want to replace '#{$searchIP}' with #{$replaceIP} (y/n)")
	while true
		c = STDIN.raw(&:getc)
		exit 0 if c == 'n'
		break if c == 'y'
	end

	# 書き換え
	resultHash.each do |filename, hitHash|
		replaceInFile(filename, $searchIP, $replaceIP)
	end
	puts(" ================= Replace Finished!! ================= ")

	# 念の為再度置換後文字列で検索した結果
	searchInFiles($searchFileAry, $replaceIP)
end

main
createMySQLCommand
