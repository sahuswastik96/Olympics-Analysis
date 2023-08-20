# SQL Data Analysis for Olympics Dataset

## Dataset Overview

This SQL data analysis explores the Olympics dataset containing two tables: `OLYMPICS_HISTORY` and `OLYMPICS_HISTORY_NOC_REGIONS`. The dataset provides insights into various aspects of Olympic history, including athlete details, events, medals, and participating nations.

**Table: OLYMPICS_HISTORY**

- id: INT
- name: VARCHAR
- sex: VARCHAR
- age: VARCHAR
- height: VARCHAR
- weight: VARCHAR
- team: VARCHAR
- noc: VARCHAR
- games: VARCHAR
- year: INT
- season: VARCHAR
- city: VARCHAR
- sport: VARCHAR
- event: VARCHAR
- medal: VARCHAR

**Table: OLYMPICS_HISTORY_NOC_REGIONS**

- noc: VARCHAR
- region: VARCHAR
- notes: VARCHAR

**Link to the Dataset:** [Olympics Dataset on Kaggle](https://www.kaggle.com/datasets/swostiksahoo/olympics-dataset)

## Exploring Olympic Data

In this case study, we explore the dataset to answer the following questions:

1. How many Olympic games have been held?
2. What is the total number of nations that participated in each Olympic game?
3. Which year saw the highest and lowest number of countries participating in the Olympics?
4. Which nation has participated in all Olympic games?
5. Identify the sport played in all summer Olympics.
6. Which sports were played only once in the Olympics?
7. Fetch the total number of sports played in each Olympic game.
8. Fetch the oldest athletes to win a gold medal.
9. Find the ratio of male and female athletes who participated in all Olympic games.
10. Fetch the top 5 athletes who have won the most gold medals.
11. Fetch the top 5 athletes who have won the most total medals (gold/silver/bronze).
12. Fetch the top 5 most successful countries in the Olympics, defined by the number of medals won.
13. List down the total gold, silver, and bronze medals won by each country.
14. List down the total gold, silver, and bronze medals won by each country corresponding to each Olympic game.
15. Break down all Olympic games where India won a medal for Hockey and the number of medals in each Olympic game.
16. Determine the sport/event in which India has won the highest number of medals.

Feel free to execute the provided SQL queries on the Olympics dataset to extract valuable insights from the Olympic history data.
