# Add a declarative step here for populating the DB with movies.

Given /the following movies exist/ do |movies_table|
  movies_table.hashes.each do |movie|
    # each returned element will be a hash whose key is the table header.
    # you should arrange to add that movie to the database here.
    flunk "Moview not created" unless  Movie.create!(movie)
  end
end

# Make sure that one string (regexp) occurs before or after another one
#   on the same page

Then /I should see "(.*)" before "(.*)"/ do |e1, e2|
  #  ensure that that e1 occurs before e2.
  #  page.content  is the entire content of the page as a string.
  #  page.body

#flunk %{Wrong Order for #{e1} and #{e2} } unless page.body =~ /#{e1}.*#{e2}/
#  flunk %{Wrong Order for #{e1} and #{e2} } unless page.body =~ /.*e1.*e2.*/
  position_e1 = page.body.index(e1)
  position_e2 = page.body.index(e2)

  flunk %{Wrong Order for #{e1} and #{e2} } unless position_e1 < position_e2

end

# Make it easier to express checking or unchecking several boxes at once
#  "When I uncheck the following ratings: PG, G, R"
#  "When I check the following ratings: G"

When /I (un)?check the following ratings: (.*)/ do |uncheck, rating_list|
  # HINT: use String#split to split up the rating_list, then
  #   iterate over the ratings and reuse the "When I check..." or
  #   "When I uncheck..." steps in lines 89-95 of web_steps.rb
  rating_list.split(',').each do |rating|
    clean_rating = rating.strip
    if uncheck == nil
      When %{I check "ratings_#{clean_rating}"}
    else
      When %{I uncheck "ratings_#{clean_rating}"}
    end
  end 
end

When /I (un)?check all the ratings/ do |uncheck|
 
  Movie.all_ratings.each do |rating|

    if uncheck == nil
      When %{I check "ratings_#{rating}"}
    else
      When %{I uncheck "ratings_#{rating}"}
    end
  end

end

When /I (un)?check ratings that are not: (.*)/ do |uncheck, rating_list|
  clean_list = rating_list.gsub(/\s+/,'')
  ignore_list = clean_list.split(',')

  Movie.all_ratings.each do |rating|

    unless ignore_list.include?(rating)
      if uncheck == nil
        When %{I check "ratings_#{rating}"}
      else
        When %{I uncheck "ratings_#{rating}"}
      end      
    end
  end
end

# Check all of the movies
Then /I should see all of the movies/ do
  Movie.all.each do |movie|
    flunk %{Movie Not Found - #{movie.title}} unless page.body.include? %{<td>#{movie.title}</td>}
  end
end

Then /I should see movies with ratings of: (.*)/ do |rating_list|
  clean_list = rating_list.gsub(/\s+/,'')
  split_ratings = clean_list.split(',')

  Movie.find_all_by_rating(split_ratings).each do |movie|
    flunk %{Movie Not Found - #{movie.title}} unless page.body.include? %{<td>#{movie.title}</td>}
  end
end


Then /I should not see movies with ratings that are not: (.*)/ do |rating_list|

  clean_list = rating_list.gsub(/\s+/,'')
  good_ratings_list = clean_list.split(',')

  Movie.all.each do |movie|
    unless good_ratings_list.include?(movie.rating)
      flunk %{Movie Should not be Found - #{movie.title}} if page.body.include? %{<td>#{movie.title}</td>}
    end
  end
end

Then /the director of "(.*)" should be "(.*)"/ do |movie_name, movie_director|
  movie = Movie.find_by_title(movie_name)
  flunk %{Movie director for #{movie_name} was #{movie.director} and not #{movie_director}} unless movie.director==movie_director

end


