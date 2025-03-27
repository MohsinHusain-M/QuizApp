# mcq_test_app
Mobile quiz app that generates quiz questions dynamically using GROQ.com’s LLM APIs.

## Dependencies
1. http → Making API requests to fetch quiz questions from GROQ.com LLM APIs.
2. shared_preferences → Storing and retrieving past quiz scores.

## Project structure
1. lib/ (Root folder for Flutter code)
    1. main.dart (Entry point of the app)
    2. screens/ (Holds all the UI screens)
        1. home_screen.dart (Home screen with difficulty selection and past scores)
        2. quiz_screen.dart (Quiz screen with timer and question logic)
        3. result_screen.dart (Result screen showing score and correct/incorrect answers)
    3. services/ (Handles API calls and data processing)
        1. quiz_groq_api.dart (Service class for generating MCQs using API)
         
screens/ → Contains UI screens (Home, Quiz, Result)
services/ → Handles API calls for generating MCQs

## 1. Home Screen
1. Difficulty selection using radio buttons (Easy, Medium, Hard)
2. Start Quiz Button → Shows CircularProgressIndicator while loading questions
3. Navigates to Quiz Screen after successfully fetching questions
4. Displays Past Scores saved using Shared Preferences

## 2. Quiz Screen
1.  20-second Timer per question
2. On selecting an answer:
    1. Shows correct/incorrect status (Green for correct, Red for incorrect)
    2. Waits 1 second before moving to the next question
    3. If time runs out, it automatically moves to the next question
    4. Handles incorrect/correct answer highlighting

## 3.Result Screen
1. Displays:
    1. Final Score
    2. Percentage
    3. List of MCQs with correct/incorrect status .Highlights correct/incorrect answers in Green/Red
    4. Retry Button to go back to Home Screen and restart

## 4. quiz_groq_api
1. Calls the Groq API to generate 5 random multiple-choice questions based on the selected difficulty.
2. Uses HTTP POST request with authorization headers and request body.
3. Sends a prompt to the AI model (llama3-8b-8192) to generate structured JSON MCQs.
4. Parses the JSON response and extracts question, options, and correct answer.
5. Handles API errors and logs responses for debugging.

## 5. Drive Link to Images of the app
https://drive.google.com/drive/folders/1LRiML8fO55aWqXfb44rjec_hJZb1_G1Q?usp=sharing
