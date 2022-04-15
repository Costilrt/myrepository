# import modules
import os
import csv

# create path for csv file to be read
path = '/Users/rollycostillas/Desktop/UPennDataScience/Homework/3-python-challenge/PyPoll'
csvpath = os.path.join(path, 'Resources', 'election_data.csv')

# set dictionary for recording candidates and votes
candidates = {}

# open csv file and read through
with open(csvpath, newline="",encoding = 'utf-8') as csvfile:
 csvreader = csv.reader(csvfile,delimiter=",")

 # skip header row
 header = next(csvreader)

 # each row is looped through: each candidate voted for is stored in a dictionary
 for row in csvreader:

 # if the candidate is already in the dictionary, their vote count is increased by one; else the candidate is added to the dictionary with a vote of 1 (excluding header row)
    if candidates.get(row[2], False):
        candidates[row[2]] += 1
    else:
        candidates[row[2]] = 1

# set variables for recording total vote count & highest number of votes
vote_count = 0
highest_votes = 0

# loop through candidates & votes in the dictionary to count total # votes & candidate with highest # votes
for candidate, votes in candidates.items():
 vote_count += votes

 # if candidate's votes are higher than highest_votes, then winner & highest_votes are updated
 if votes > highest_votes:
    winner = candidate
    highest_votes = votes

# set list for lines to be printed & variable for calculating a candidate's percent of votes
vote_percent = 0
print_lines = []

# add starting strings to each item of the print_lines list
print_lines.append("Election Results")
print_lines.append("-----------------------------")
print_lines.append("Total Votes: " + str(vote_count))
print_lines.append("-----------------------------")

# add more strings to each item of the print_lines list
# looping through the candidates & votes to determine vote_percent of that candidate & record all variables in a string for print_lines list
for candidate, votes in candidates.items():
 vote_percent = round(votes/vote_count*100,3)
 print_lines.append(candidate + ": " + str(vote_percent) + "% (" + str(votes) + ")")

# add ending strings to each item of the print_lines list
print_lines.append("-----------------------------")
print_lines.append("Winner: " + winner)
print_lines.append("-----------------------------")

# create the output text file
path = '/Users/rollycostillas/Desktop/UPennDataScience/Homework/3-python-challenge/PyPoll'
output_path = os.path.join(path,'PyPoll_results.txt')

# write to the output text file the results
with open(output_path, "w") as txtfile:

 # loop through all print_lines and print to both the text file and the terminal
 for line in print_lines:
    txtfile.writelines([line+"\n"])
 print(line)
