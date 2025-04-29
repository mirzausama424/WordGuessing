
import UIKit
import AVFoundation


class ViewController: UIViewController {

    @IBOutlet weak var wordGuessedLabel: UILabel!
    @IBOutlet weak var remainingWordsLabel: UILabel!
    @IBOutlet weak var wordMissesLabel: UILabel!
    @IBOutlet weak var remainingWordsInGameLabel: UILabel!
    @IBOutlet weak var WordBeindreveledLabel: UILabel!
    @IBOutlet weak var guessedLetterTextField: UITextField!
    @IBOutlet weak var guessedLetterButton: UIButton!
    @IBOutlet weak var tryAgainButton: UIButton!
    @IBOutlet weak var gameStatusLabel: UILabel!
    @IBOutlet weak var flowerImage: UIImageView!

    var wordsToGuess = ["Swift", "Python", "Java"]
    var currentWordIndex = 0
    var wordToGuess = ""
    var lettersGuessed = ""
    var totalGuesses = 0
    var wrongGuessesRemaining = 8
    var wordsGuessedCount = 0
    var wordsMissedCount = 0
    var audioplayer : AVAudioPlayer!

    override func viewDidLoad() {
        super.viewDidLoad()
        guessedLetterButton.isEnabled = false
        tryAgainButton.isHidden = true
        guessedLetterTextField.delegate = self
        guessedLetterTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        startNewWord()
    }

    func startNewWord() {
        wordToGuess = wordsToGuess[currentWordIndex]
        lettersGuessed = ""
        wrongGuessesRemaining = 8
        totalGuesses = 0
        guessedLetterTextField.text = ""
        guessedLetterTextField.isEnabled = true
        guessedLetterButton.isEnabled = false
        tryAgainButton.isHidden = true
        flowerImage.image = UIImage(named: "flower8")
        updateDisplayedWord()
        updateGameStatusLabels()
    }

    func updateDisplayedWord() {
        var revealedWord = ""
        for letter in wordToGuess {
            if lettersGuessed.contains(letter.lowercased()) {
                revealedWord += "\(letter) "
            } else {
                revealedWord += "_ "
            }
        }
        revealedWord.removeLast()
        WordBeindreveledLabel.text = revealedWord
    }

    func updateGameStatusLabels() {
        wordGuessedLabel.text = "\(wordsGuessedCount)"
        wordMissesLabel.text = "\(wordsMissedCount)"
        remainingWordsLabel.text = "\(wordsToGuess.count - (wordsGuessedCount + wordsMissedCount))"
        remainingWordsInGameLabel.text = "\(wordsToGuess.count)"
    }
    
    
    func drawflowerAndPlaySound(guessedLetter: String) {
        if wordToGuess.lowercased().contains(guessedLetter) {
            // ✅ Correct single letter: Play sound only, no change to flower
            playSound(name: "correct")
        } else {
            // ❌ Incorrect guess
            wrongGuessesRemaining -= 1

            if wrongGuessesRemaining > 0 {
                // Step 1: Show wilt image
                flowerImage.image = UIImage(named: "wilt\(wrongGuessesRemaining)")
                playSound(name: "incorrect")

                // Step 2: After 0.5s, switch to updated flower image
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.flowerImage.image = UIImage(named: "flower\(self.wrongGuessesRemaining)")
                }
            } else {
                // Final mistake - wilt0 then disappear
                flowerImage.image = UIImage(named: "wilt0")
                playSound(name: "word-not-guessed")

                UIView.animate(withDuration: 0.5, animations: {
                    self.flowerImage.alpha = 0.0
                    self.flowerImage.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                }) { _ in
                    self.flowerImage.transform = .identity
                }
            }
        }
    }




    func makeGuess() {
        guard let guessedLetter = guessedLetterTextField.text?.lowercased(), !guessedLetter.isEmpty else { return }
        
        if lettersGuessed.contains(guessedLetter) {
            gameStatusLabel.text = "You've already guessed \"\(guessedLetter.uppercased())\"."
            return
        }

        lettersGuessed += guessedLetter
        updateDisplayedWord()
        drawflowerAndPlaySound(guessedLetter: guessedLetter)
        totalGuesses += 1
        let guessWord = totalGuesses == 1 ? "guess" : "guesses"
        gameStatusLabel.text = "You've made \(totalGuesses) \(guessWord)."

        if WordBeindreveledLabel.text?.replacingOccurrences(of: " ", with: "") == wordToGuess {
            playSound(name: "word-guessed")
            gameStatusLabel.text = "You guessed the word in \(totalGuesses) \(guessWord)!"
            wordsGuessedCount += 1
            endGame()
        } else if wrongGuessesRemaining == 0 {
            playSound(name: "word-not-guessed")
            gameStatusLabel.text = "You're out of guesses! The word was \"\(wordToGuess)\"."
            wordsMissedCount += 1
            endGame()
        }
    }

    func endGame() {
        guessedLetterTextField.isEnabled = false
        guessedLetterButton.isEnabled = false

        // Check if ALL words are guessed or missed
        if (wordsGuessedCount + wordsMissedCount) == wordsToGuess.count {
            gameStatusLabel.text = "Congratulations! You've completed all words!\nTap 'Try Again' to restart."
            tryAgainButton.isHidden = false
        } else {
            tryAgainButton.isHidden = false
        }
        updateGameStatusLabels()
    }
    func playSound(name: String) {
        guard let soundURL = Bundle.main.url(forResource: name, withExtension: "mp3", subdirectory: "flower sounds") else {
            print("Could not find the sound file: \(name).mp3 in flower sounds folder.")
            return
        }

        do {
            audioplayer = try AVAudioPlayer(contentsOf: soundURL)
            audioplayer.play()
        } catch {
            print("Error playing sound: \(error.localizedDescription)")
        }
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        if let text = textField.text, !text.trimmingCharacters(in: .whitespaces).isEmpty {
            textField.text = String(text.last!).uppercased()
            guessedLetterButton.isEnabled = true
        } else {
            guessedLetterButton.isEnabled = false
        }
    }

    @IBAction func guessedLetterButtonTapped(_ sender: UIButton) {
        guessedLetterTextField.resignFirstResponder()
        makeGuess()
        guessedLetterTextField.text = ""
        guessedLetterButton.isEnabled = false
    }

    @IBAction func tryAgainButtonTapped(_ sender: UIButton) {
        if (wordsGuessedCount + wordsMissedCount) == wordsToGuess.count {
            // Restart the entire game
            currentWordIndex = 0
            wordsGuessedCount = 0
            wordsMissedCount = 0
        } else {
            // Move to next word
            currentWordIndex += 1
        }

        if currentWordIndex < wordsToGuess.count {
            startNewWord()
        } else {
            gameStatusLabel.text = "Game Over! Tap 'Try Again' to restart."
            guessedLetterTextField.isEnabled = false
            guessedLetterButton.isEnabled = false
        }

        // ✅ Reset flower image with all petals visible
        flowerImage.image = UIImage(named: "flower8")
        flowerImage.alpha = 1.0
    }

    @IBAction func doneKeyPressed(_ sender: UITextField) {
        guessedLetterTextField.resignFirstResponder()
        makeGuess()
        guessedLetterTextField.text = ""
        guessedLetterButton.isEnabled = false
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guessedLetterTextField.resignFirstResponder()
        makeGuess()
        guessedLetterTextField.text = ""
        guessedLetterButton.isEnabled = false
        return true
    }
}
