const functions = require('firebase-functions');
const logger = require('firebase-functions/logger');
const Busboy = require('busboy');
const { ImageAnnotatorClient } = require('@google-cloud/vision');

const client = new ImageAnnotatorClient();

exports.performOCR = functions.https.onRequest((request, response) => {
    const busboy = new Busboy({ headers: request.headers });
    let imageBuffer;

    busboy.on('file', (_fieldname, file, _filename, _encoding, _mimetype) => {
        const chunks = [];
        file.on('data', (data) => {
            chunks.push(data);
        });

        file.on('end', () => {
            imageBuffer = Buffer.concat(chunks);
        });
    });

    busboy.on('finish', async () => {
        try {
            const requestPayload = {
                image: {
                    content: imageBuffer.toString('base64'),
                },
                features: [{ type: 'TEXT_DETECTION' }],
            };

            const [result] = await client.annotateImage(requestPayload);
            const detections = result.textAnnotations;

            if (detections.length > 0) {
                response.send(detections[0].description);
            } else {
                response.send('No text detected');
            }
        } catch (error) {
            logger.error('Error during OCR:', error);
            response.status(500).send('Error processing image');
        }
    });

    request.pipe(busboy);
});
