#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

declare -a countries_array

# get an array of all the countries
while IFS=',' read -r year round winner opponent winner_goals opponent_goals; do
  if [[ $year == "year" ]]; then
        continue
  fi

  countries_array+=("$winner")
  countries_array+=("$opponent")
done < games.csv

declare -a unique_countries_array

# build the unique countries array
for element in "${countries_array[@]}"; do
  if [[ ! " ${unique_countries_array[@]} " =~ " $element " ]]; then
    unique_countries_array+=("$element")
  fi
done

# iterate through the unique countries array and add each element (along with an incrementing team id) to the PSQL table teams
team_id=1
for element in "${unique_countries_array[@]}"; do
  $PSQL "INSERT INTO teams(name, team_id) VALUES ('$element', '$team_id');"
  ((team_id++))
done

while IFS=',' read -r year round winner opponent winner_goals opponent_goals; do
  if [[ $year == "year" ]]; then
    continue
  fi

  winner_id=$($PSQL "SELECT team_id FROM teams WHERE name = '$winner';")
  opponent_id=$($PSQL "SELECT team_id FROM teams WHERE name = '$opponent';")

  $PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES ('$year', '$round', '$winner_id', '$opponent_id', '$winner_goals', '$opponent_goals');"
done < games.csv