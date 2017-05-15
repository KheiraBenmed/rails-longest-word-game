  require 'open-uri'
  require 'json'
class LongestwordController < ApplicationController


  def game
    @grid_array = generate_grid(30)
    @start_time = Time.now
  end

  def score
    @attempt = params[:attempt].split("")
    @grid = params[:grid].split("")
    @start_time = params[:start_time].to_datetime
    @end_time = Time.now
    @score = run_game(@attempt, @grid, @start_time, @end_time)[:score]
    @time = run_game(@attempt, @grid, @start_time, @end_time)[:time]
  end

  private

  def generate_grid(grid_size)
    Array.new(grid_size) { ('A'..'Z').to_a[rand(26)] }
  end

  def included?(guess, grid)
    guess.all? { |letter| guess.count(letter) <= grid.count(letter) }
  end

  def compute_score(attempt, time_taken)
    (time_taken > 60.0) ? 0 : attempt.size * (1.0 - time_taken / 60.0)
  end

  def run_game(attempt, grid, start_time, end_time)
    result = { time: end_time - start_time }

    result[:translation] = get_translation(attempt)
    result[:score], result[:message] = score_and_message(
      attempt, result[:translation], grid, result[:time])

    result
  end

  def score_and_message(attempt, translation, grid, time)
    if included?(attempt.join("").upcase.split(""), grid)
      if translation
        score = compute_score(attempt, time)
        [score, "well done"]
      else
        [0, "not an english word"]
      end
    else
      [0, "not in the grid"]
    end
  end

  def get_translation(word)
    api_key = "57a5275a-c72d-4c45-b487-07e69e893fe1"
    begin
      response = open("https://api-platform.systran.net/translation/text/translate?source=en&target=fr&key=#{api_key}&input=#{word}")
      json = JSON.parse(response.read.to_s)
      if json['outputs'] && json['outputs'][0] && json['outputs'][0]['output'] && json['outputs'][0]['output'] != word
        return json['outputs'][0]['output']
      end
    rescue
      if File.read('/usr/share/dict/words').upcase.split("\n").include? word.to_s.upcase
        return word
      else
        return nil
      end
    end
  end
end
