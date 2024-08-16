require 'csv'
require 'anki_record'

OUTPUT_NAME = 'vds-quiz'
OUTPUT_FILE = 'vds-quiz.apkg'

def extract(question_with_answer)
  answers = [
    question_with_answer['answer_1'].capitalize,
    question_with_answer['answer_2'].capitalize,
    question_with_answer['answer_3'].capitalize,
  ]
  solution_index = question_with_answer['solution'].to_i - 1
  correct_answer = answers.delete_at solution_index
  
  {
    id: question_with_answer['id'],
    question: question_with_answer['question'],
    correct_answer: correct_answer,
    other_answers: answers,
  }
end

File.delete(OUTPUT_FILE) if File.exist?(OUTPUT_FILE)

# Read question/answer CSV
questions_with_answers = CSV.open('vds-questions-with-answers.csv', headers: :first_row).map(&:to_h)
questions_with_answers = questions_with_answers.map { |q| extract(q) }

# Read anki templates
front_html = IO.read(File.join('anki-templates', 'front.html'))
back_html = IO.read(File.join('anki-templates', 'back.html'))
front_js = IO.read(File.join('anki-templates', 'front.js'))
back_js = IO.read(File.join('anki-templates', 'back.js'))
css = IO.read(File.join('anki-templates', 'card.css'))

AnkiRecord::AnkiPackage.create(name: "vds-quiz") do |anki21_database|
  # Creating a new deck
  deck = AnkiRecord::Deck.new(anki21_database:, name: "VDS Quiz")
  deck.save

  # Creating a new note type
  note_type = AnkiRecord::NoteType.new(
    anki21_database:,
    name: "question",
  )
  note_type.css = css

  AnkiRecord::NoteField.new(
    note_type: note_type,
    name: "Id",
  )
  AnkiRecord::NoteField.new(
    note_type: note_type,
    name: "Question",
  )
  AnkiRecord::NoteField.new(
    note_type: note_type,
    name: "Choices",
  )
  card_template = AnkiRecord::CardTemplate.new(
    note_type: note_type,
    name: "multi choice"
  )
  question = "<b>{{Id}}.</b> {{Question}}<br><br>"
  card_template.question_format = "#{question}#{front_html}\n<script>#{front_js}</script>"
  card_template.answer_format = "#{question}#{back_html}\n<script>#{back_js}</script>"

  note_type.save

  # Creating notes
  for question_with_answer in questions_with_answers do
    note = AnkiRecord::Note.new(note_type: note_type, deck: deck)
    note.id = question_with_answer[:id]
    note.question = question_with_answer[:question]
    note.choices = question_with_answer[:other_answers].prepend(question_with_answer[:correct_answer]).join("<br>")
    note.save
  end
end
