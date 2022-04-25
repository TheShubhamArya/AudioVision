# AudioVision

This is an iOS application that aims to help blind people see the text around them. This is made possible with the help of 
1. Speech recognition - to take users' commands and turn them into actions in the app
2. Text Detection -  to detect text out of an image
3. Image Stitching - to stitch multiple images together to create 1 long image which can be used to detect the text
4. Natural Language Processing - to detect spelling errors in the detected word and correcting it
5. Speech Synthesizer - to turn the processed text in to speech.

## Text Detection

<img width="629" alt="Screen Shot 2022-04-24 at 11 23 49 PM" src="https://user-images.githubusercontent.com/60827845/165020690-8c681778-eade-4c65-94be-293174edbf5b.png">

https://user-images.githubusercontent.com/60827845/165021190-7c36dc7e-98d5-4cb0-a817-590a45e34a6c.MP4

## Image Stitching

https://user-images.githubusercontent.com/60827845/165022362-51e91c94-b7fd-4a9e-869d-92f915d330ca.MP4

Steps
- Uses image registration requests from the vision framework to calculate an alignment transform between the 2 images.
- This uses a homographic image registration mechanism.
- A perspective transform filter is used for the homographic image registration.
- The warped image is then place on the base image to create a single image.


## References
- https://developer.apple.com/documentation/vision/recognizing_text_in_images
- https://developer.apple.com/documentation/vision/aligning_similar_images
- https://www.hackingwithswift.com/example-code/libraries/how-to-convert-speech-to-text-using-sfspeechrecognizer
