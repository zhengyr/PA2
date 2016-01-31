#Yiran Zheng
#zhengyr@brandeis.edu
#movie data class that reads all the data and predict the rating for movies
class MovieData
  attr_reader :users, :movie_s, :testFile #access data here
  #constructor
  def initialize(folder_name, file_name = "u.data")
    if file_name == "u.data"
      path = folder_name + "/" + file_name
      @testFile = nil
    else
      path = folder_name + "/" + file_name.to_s + ".base"
      @testFile = File.open(folder_name + "/" + file_name.to_s + ".test", "r")
    end
    @dataFile = File.open(path, "r")
    @users = Hash.new
    @movie_s = Hash.new
    load_Data
  end

  def load_Data
    #for each line in the file, read them to users and movie_s hash table
    @dataFile.each_line do |current_line|
      info = current_line.split(" ")
      # put information into users hash table
      if not @users.has_key?(info[0].to_i)
        @users[info[0].to_i] = Array.new
      end
      @users[info[0].to_i].push([info[1].to_i, info[2].to_i, info[3].to_i])

      if not @movie_s.has_key?(info[1].to_i)
        @movie_s[info[1].to_i] = Array.new
      end
      # element at 0 is user, element at 1 is rating
      @movie_s[info[1].to_i].push([info[0].to_i, info[2].to_i])
    end
  end
  #get rate of the movie for sepefic user
  def rating(u, m)
    user_array = users[u.to_i]
    user_array.each do |movie|
      if movie[0] == m
        return movie[1]
      end
    end
    0
  end
  #get predication, calculate average
  def predict(u, m)
    sum = 0
    mov = movie_s[m]
    if mov == nil#if the movie is not in the database, then return 3
      return 3
    end
    mov.each {|rate| sum +=rate[1]}
    return sum/movie_s[m].length.to_f
  end
  #return the ratings of a movie
  def ratings(m)
    general_calculate(movie_s[m.to_i], 1)
  end
  #return all the movies the user has seen
  def movies(u)
    general_calculate(users[u.to_i], 0)
  end
  #return all the the users who have seen the movie
  def viewers(m)
    general_calculate(movie_s[m.to_i], 0)
  end
  #get sepcific result from the user
  def general_calculate(list, i)
    result = Array.new
    list.each do |element|
      result.push(element[i].to_i)
    end
    result
  end
  #run the test for data
  def run_test(k = -1)
    test_list = Array.new
    check = k
    testFile.each_line do |current_line|
      k -=1
      info = current_line.split(" ")
      test_list.push([info[0].to_i, info[1].to_i, info[2].to_i,
      predict(info[0].to_i, info[1].to_i)])
      if check!= -1 and k==0
        break
      end
    end
    MovieTest.new(test_list)
  end
end
#test if the prediction for movie rate works well
class MovieTest
  attr_reader :test_list, :pred_error
  #constructor
  def initialize(test_list)
    @test_list = test_list
    @pred_error = Array.new
    load_error
  end
  #load all the errors into a list
  def load_error
    test_list.each do |current_user|
      pred_error.push(current_user[2]-current_user[3])
    end
  end
  #calculate the mean for errors
  def mean
    sum = 0
    pred_error.each{|e| sum += e}
    sum/pred_error.length.to_f
  end
  #calculate the std dev for predication
  def stddev
    sum = 0
    get_mean = mean
    pred_error.each { |e| sum += (e-get_mean)**2}
    return Math.sqrt(sum/pred_error.length.to_f)
  end
  #calculate the rms for predication
  def rms
    sum = 0
    get_mean = mean
    pred_error.each { |e| sum += e**2}
    return Math.sqrt(sum/pred_error.length.to_f)
  end
  #return result
  def to_a
    test_list
  end
end
#z = MovieData.new("ml-100k")
# z = MovieData.new("ml-100k", :u1)
#
# puts Time.now
# a = z.run_test()
# puts Time.now
# puts "mean is #{a.mean}"
# puts "stddev is #{a.stddev}"
# puts "rms is #{a.rms}"
# puts a.to_a.length
