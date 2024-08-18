require 'csv'
require 'anki_record'

PARAGLIDE_OUTPUT_NAME = "vds-quiz-parapendio"
PARAGLIDE_OUTPUT_FILE = "#{PARAGLIDE_OUTPUT_NAME}.apkg"

DELTAPLANE_QUESTION_IDS = [
"2147", "7062", "7063", "7064", "7065", "7066", "7067", "7068", "7069", "7070",
"7071", "7072", "7073", "7074", "7075", "7076", "7077", "7078", "7079", "8011",
"8012", "8013", "8014", "8015", "8016", "9037", "9038", "9039", "9040", "9041",
"9042"
]

def extract(question_with_answer)
  answers = [
    question_with_answer['answer_1'],
    question_with_answer['answer_2'],
    question_with_answer['answer_3'],
  ].each { |a| a[0] = a[0].upcase }

  solution_index = question_with_answer['solution'].to_i - 1
  correct_answer = answers.delete_at solution_index

  {
    id: question_with_answer['id'],
    question: question_with_answer['question'],
    correct_answer: correct_answer,
    other_answers: answers,
  }
end

def create_deck(file_name, deck_name, css, question_format, answer_format, questions)
  AnkiRecord::AnkiPackage.create(name: file_name) do |anki21_database|
    # Creating a new deck
    deck = AnkiRecord::Deck.new(anki21_database:, name: deck_name)
    deck.save
  
    # Creating a new note type
    note_type = AnkiRecord::NoteType.new(
      anki21_database:,
      name: "question",
    )
    note_type.css = css
  
    AnkiRecord::NoteField.new(note_type: note_type, name: "Id")
    AnkiRecord::NoteField.new(note_type: note_type, name: "Question")
    AnkiRecord::NoteField.new(note_type: note_type, name: "Choices")
  
    card_template = AnkiRecord::CardTemplate.new(note_type: note_type, name: "multi choice")
    card_template.question_format = question_format
    card_template.answer_format = answer_format
  
    note_type.save
  
    # Creating notes
    for question in questions do
      note = AnkiRecord::Note.new(note_type: note_type, deck: deck)
      note.id = question[:id]
      note.question = question[:question]
      note.choices = question[:other_answers].prepend(question[:correct_answer]).join("<br>")
      note.save
    end
  end
end

File.delete(PARAGLIDE_OUTPUT_FILE) if File.exist?(PARAGLIDE_OUTPUT_FILE)

# Read, process and filter questions
questions = CSV.open('vds-questions-with-answers.csv', headers: :first_row).
  map(&:to_h).
  map{ |q| extract(q) }.
  select { |q| !DELTAPLANE_QUESTION_IDS.include?(q[:id]) }

# Read anki templates
front_html = IO.read(File.join('anki-templates', 'front.html'))
back_html = IO.read(File.join('anki-templates', 'back.html'))
front_js = IO.read(File.join('anki-templates', 'front.js'))
back_js = IO.read(File.join('anki-templates', 'back.js'))
css = IO.read(File.join('anki-templates', 'card.css'))

question = "<b>{{Id}}.</b> {{Question}}<br><br>"
question_format = "#{question}#{front_html}\n<script>#{front_js}</script>"
answer_format = "#{question}#{back_html}\n<script>#{back_js}</script>"

create_deck(PARAGLIDE_OUTPUT_NAME, "VDS Quiz Parapendio", css, question_format, answer_format, questions)

