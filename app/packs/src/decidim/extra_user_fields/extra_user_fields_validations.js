import * as faceapi from 'face-api.js';

const MIN_CONFIDENCE = 0.5;
const FACE_MANIFEST = '/decidim-packs/weights';

const initValidations = async () => {
  const resultField = $('.face-validation-field input');
  const canvas = $('.face-validation-field canvas');
  const imageTag = $('.face-validation-field img');
  const imageField  = $('.face-file-field input');
  const detector = new faceapi.SsdMobilenetv1Options({ MIN_CONFIDENCE });

  await faceapi.nets.ssdMobilenetv1.load(FACE_MANIFEST);
  await faceapi.loadFaceLandmarkModel(FACE_MANIFEST);
  await faceapi.loadFaceRecognitionModel(FACE_MANIFEST);

  const showValidationError = () => {
    $('label[for="registration_user_document_image"]').addClass('is-invalid-label');
    $('.face-file-field input').addClass('is-invalid-input');
    $('.face-file-field .document-form-error').addClass('is-visible');
    imageField.val('');
  }

  const hideValidationError = () => {
    $('label[for="registration_user_document_image"]').removeClass('is-invalid-label');
    $('.face-file-field input').removeClass('is-invalid-input');
    $('.face-file-field .document-form-error').removeClass('is-visible');
  }

  const imageChanged = async () => {

    const imgFile = imageField[0].files[0];
    const img = await faceapi.bufferToImage(imgFile);
    imageTag[0].src = img.src;

    const fullFaceDescriptions = await faceapi
      .detectAllFaces(imageTag[0], detector)
      .withFaceLandmarks()
      .withFaceDescriptors();

    if (!fullFaceDescriptions.length) {
      showValidationError();
      return;
    }

    // create FaceMatcher with automatically assigned labels
    // from the detection results for the reference image
    const faceMatcher = new faceapi.FaceMatcher([fullFaceDescriptions[0]]);

    faceapi.matchDimensions(canvas[0], imageTag[0]);
    // resize detection and landmarks in case displayed image is smaller than
    // original size
    const resizedResults = faceapi.resizeResults(fullFaceDescriptions, imageTag[0]);
    // draw boxes with the corresponding label as text
    const labels = faceMatcher.labeledDescriptors
      .map(ld => ld.label);
  
    if(resizedResults.length !== 2) {
      showValidationError(); 
    } else {
      const labels = resizedResults.map(({ detection, descriptor }) => {
        const result = faceMatcher.findBestMatch(descriptor);
	const label = result._label;
	const distance = result._distance;
        const options = { label };
        const drawBox = new faceapi.draw.DrawBox(detection.box, options);
	return { label, distance };
      });
      if (labels[0].label !== labels[1].label) {
        showValidationError();
      } else {
        hideValidationError();
        resultField.val(`valid ${Math.abs(labels[0].distance - labels[1].distance)}`);
      }
    }
  }

  imageField[0].onchange = imageChanged;
}

const initHelpButtons = () => {
  const helpBox = $('.face-validation-field_help');
  $('.face-validation-field_toggle-help').click((e) => {
    helpBox.attr('hidden', (_, hidden) => !hidden);
  });
}

$(() => {
  initValidations();
  initHelpButtons();
});

