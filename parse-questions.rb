require 'csv'

def extract_answer(lines)
  answer = [lines[0].strip!]

  line_index = 1
  while line_index < lines.length do
    line = lines[line_index]
    break if line.match(/^(\d. )/)
    line_index += 1
    answer.append line.strip!
  end

  return { answer: answer.join(" ")[3..-1], remaining_lines: lines[line_index..-1] }
end

def extract_question(lines)
  question_id = lines[0].match(/^\d\d\d\d/)[0]
  question_lines = [lines[0][question_id.length..-1].strip!]

  line_index = 1
  while line_index < lines.length do
    line = lines[line_index]
    break if line.match(/^(\d. )/)
    question_lines.append(line.strip!)
    line_index += 1
  end

  lines = lines[line_index..-1]

  extracted = extract_answer(lines)
  answer_1 = extracted[:answer]
  lines = extracted[:remaining_lines]

  extracted = extract_answer(lines)
  answer_2 = extracted[:answer]
  lines = extracted[:remaining_lines]

  extracted = extract_answer(lines)
  answer_3 = extracted[:answer]
  lines = extracted[:remaining_lines]

  if lines.any?
    raise "Lines unexpectedly remaining: #{lines}"
  end

  {
    id: question_id,
    question: question_lines.join(" "),
    answer_1: answer_1,
    answer_2: answer_2,
    answer_3: answer_3,
  }
end

# Read the input questions. The questions are just copy-pasted from the PDF
# with the answers section removed.
lines = File.readlines('vds-questions.txt')

question_line_groups = []
current_question = [lines.first]
found_answers = false

# Extract the question lines
for line in lines[1..-1] do
  if found_answers && line.match(/^\d\d\d\d/)
    question_line_groups.append current_question
    current_question = []
    found_answers = false
  end
  found_answers ||= line.match(/^(\d. )/)
  current_question.append line
end

# Record the last question lines
if current_question.any?
  question_line_groups.append current_question
end


# Convert question lines to a hash
questions = question_line_groups.map{ |q| extract_question(q) }

# Read the answers CSV to a map
solutions_csv = CSV.read("vds-solutions-cleaned.csv")
solutions_map = {}
for solution in solutions_csv do
  solutions_map[solution[0].gsub('.', '')] = solution[1]
end

# Add the solutions to the questions
for question in questions do
  solution = solutions_map.delete(question[:id])
  raise "no solution for #{solution[:id]}" if solution.nil?
  question[:solution] = solution
end
if solutions_map.any?
  raise "unmatched solutions remain: ${solutions_map}"
end

# Write the questions and answers to a CSV
CSV.open("vds-questions-with-answers.csv", "w") do |csv|
  csv << ["id", "question", "answer_1", "answer_2", "answer_3", "solution"]
  for question in questions do

  csv << [
    question[:id],
    question[:question],
    question[:answer_1],
    question[:answer_2],
    question[:answer_3],
    question[:solution]
  ]
  end
end
