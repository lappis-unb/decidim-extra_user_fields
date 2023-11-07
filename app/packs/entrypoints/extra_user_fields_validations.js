import * as faceapi from 'face-api.js';

const MIN_CONFIDENCE = 0.5;
const FACE_MANIFEST = 'http://localhost:3001/';

const initValidations = async () => {
  const resultField = document.querySelector('.face-validation-field input');
  const canvas = document.querySelector('.face-validation-field canvas');
  const imageTag = document.querySelector('.face-validation-field img');
  const imageField  = document.querySelector('.face-file-field input');
  const detector = new faceapi.SsdMobilenetv1Options({ MIN_CONFIDENCE });

  await faceapi.nets.ssdMobilenetv1.load(FACE_MANIFEST);
  await faceapi.loadFaceLandmarkModel(FACE_MANIFEST);
  await faceapi.loadFaceRecognitionModel(FACE_MANIFEST);

  const imageChanged = async () => {

    const imgFile = imageField.files[0];
    const img = await faceapi.bufferToImage(imgFile);
    imageTag.src = img.src;

    const fullFaceDescriptions = await faceapi
      .detectAllFaces(imageTag, detector)
      .withFaceLandmarks()
      .withFaceDescriptors();

    if (!fullFaceDescriptions.length) {
      return;
    }

    // create FaceMatcher with automatically assigned labels
    // from the detection results for the reference image
    const faceMatcher = new faceapi.FaceMatcher([fullFaceDescriptions[0]]);

    faceapi.matchDimensions(canvas, imageTag);
    // resize detection and landmarks in case displayed image is smaller than
    // original size
    const resizedResults = faceapi.resizeResults(fullFaceDescriptions, imageTag);
    // draw boxes with the corresponding label as text
    const labels = faceMatcher.labeledDescriptors
      .map(ld => ld.label);
  
    if(resizedResults.length !== 2) {
      // validar imagens sem a identificação de dois rostos.
    } else {
      const labels = resizedResults.map(({ detection, descriptor }) => {
        const result = faceMatcher.findBestMatch(descriptor);
	const label = result._label;
	const distance = result._distance;
        const options = { label };
        const drawBox = new faceapi.draw.DrawBox(detection.box, options);
        // drawBox.draw(canvas);
	return { label, distance };
      });
    }
  }

  

  imageField.onchange = imageChanged;
}
document.onreadystatechange = function () {
  if (document.readyState === 'interactive') {
    initValidations();
  }
}
