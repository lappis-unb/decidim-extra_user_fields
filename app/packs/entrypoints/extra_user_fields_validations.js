import * as faceapi from 'face-api.js';

const MIN_CONFIDENCE = 0.5;
const FACE_MANIFEST = 'src/decidim/extra_user_fields/weights/';

const initValidations = async () => {
  const resultField = document.querySelector('.face-validation-field input');
  const canvas = document.querySelector('.face-validation-field canvas');
  const imageField  = document.querySelector('.face-file-field input');
  const detector = new faceapi.SsdMobilenetv1Options({ MIN_CONFIDENCE });
  await faceapi.nets.ssdMobilenetv1.load(FACE_MANIFEST);
  await faceapi.loadFaceRecognitionModel(FACE_MANIFEST);

  const imageChanged = async () => {

    const fullFaceDescriptions = await faceapi
      .detectAllFaces(imageField, getFaceDetectorOptions())
      .withFaceLandmarks()
      .withFaceDescriptors()

    if (!fullFaceDescriptions.length) {
      return
    }

    // create FaceMatcher with automatically assigned labels
    // from the detection results for the reference image
    const faceMatcher = new faceapi.FaceMatcher([fullFaceDescriptions[0]])

    faceapi.matchDimensions(canvas, imageField)
    // resize detection and landmarks in case displayed image is smaller than
    // original size
    const resizedResults = faceapi.resizeResults(fullFaceDescriptions, imageField)
    // draw boxes with the corresponding label as text
    const labels = faceMatcher.labeledDescriptors
      .map(ld => ld.label)
  
    if(resizedResults.length !== 2) {
      alert('upload an image with two faces')
    } else {
      resizedResults.forEach(({ detection, descriptor }) => {
        const label = faceMatcher.findBestMatch(descriptor).toString()
        const options = { label }   
        const drawBox = new faceapi.draw.DrawBox(detection.box, options)
        drawBox.draw(canvas)
      })
    }
  }

  imageField.onchange = imageChanged;
}
document.onreadystatechange = function () {
  if (document.readyState === 'interactive') {
    initValidations();
  }
}
