# 🎤🖼️ Audio & Image API Integration Guide

## New Endpoints Available

Your API now has **2 new powerful endpoints** for multimedia:

### 1. 🖼️ **Image Analysis** - `/chat/image`
### 2. 🎤 **Audio Processing** - `/chat/audio`

---

## 🖼️ Image Analysis Endpoint

**Upload an image and get AI analysis**

### Endpoint
```
POST /chat/image
```

### Request (Multipart Form)
- `image`: Image file (JPG, PNG, GIF, WebP)
- `question`: Your question about the image

### Response (JSON)
```json
{
  "analysis": "This diagram shows...",
  "question": "Explain this UML diagram",
  "model_used": "gpt-4o"
}
```

---

## 🎤 Audio Processing Endpoint

**Upload audio → Get transcription + answer + audio response**

### Endpoint
```
POST /chat/audio
```

### Request (Multipart Form)
- `audio`: Audio file (WAV, MP3, M4A)
- `question`: (Optional) Skip transcription if provided

### Response (JSON)
```json
{
  "transcription": "Qu'est-ce qu'une classe en Java ?",
  "answer": "Une classe est...",
  "audio_url": "data:audio/mp3;base64,...",
  "sources": [...],
  "model_used": "gpt-4o-mini"
}
```

---

## 💻 Integration Examples

### JavaScript - Image Upload

```javascript
async function analyzeImage(imageFile, question) {
  const formData = new FormData();
  formData.append('image', imageFile);
  formData.append('question', question);
  
  const response = await fetch('http://192.168.11.107:8000/chat/image', {
    method: 'POST',
    body: formData
  });
  
  const data = await response.json();
  console.log(data.analysis);
}

// Usage with file input
const input = document.querySelector('input[type="file"]');
input.addEventListener('change', (e) => {
const file = e.target.files[0];
  analyzeImage(file, "Explique ce diagramme");
});
```

---

### JavaScript - Audio Upload

```javascript
async function processAudio(audioFile) {
  const formData = new FormData();
  formData.append('audio', audioFile);
  
  const response = await fetch('http://192.168.11.107:8000/chat/audio', {
    method: 'POST',
    body: formData
  });
  
  const data = await response.json();
  
  // Display transcription
  console.log("You said:", data.transcription);
  
  // Display answer
  console.log("Answer:", data.answer);
  
  // Play audio response
  const audio = new Audio(data.audio_url);
  audio.play();
}
```

---

### Python - Image Analysis

```python
import requests

def analyze_image(image_path, question):
    url = "http://192.168.11.107:8000/chat/image"
    
    with open(image_path, 'rb') as img:
        files = {'image': img}
        data = {'question': question}
        
        response = requests.post(url, files=files, data=data)
        return response.json()

# Usage
result = analyze_image("diagram.png", "Explain this UML diagram")
print(result['analysis'])
```

---

### Python - Audio Processing

```python
import requests
import base64

def process_audio(audio_path):
    url = "http://192.168.11.107:8000/chat/audio"
    
    with open(audio_path, 'rb') as audio:
        files = {'audio': audio}
        
        response = requests.post(url, files=files)
        data = response.json()
        
        print(f"Transcription: {data['transcription']}")
        print(f"Answer: {data['answer']}")
        
        # Save audio response
        audio_data = base64.b64decode(data['audio_url'].split(',')[1])
        with open('response.mp3', 'wb') as f:
            f.write(audio_data)

# Usage
process_audio("question.wav")
```

---

### React - Image Upload Component

```jsx
import React, { useState } from 'react';

function ImageAnalyzer() {
  const [analysis, setAnalysis] = useState('');
  const [loading, setLoading] = useState(false);

  const handleImageUpload = async (e) => {
    const file = e.target.files[0];
    const question = prompt("What do you want to know about this image?");
    
    const formData = new FormData();
    formData.append('image', file);
    formData.append('question', question);
    
    setLoading(true);
    const response = await fetch('http://192.168.11.107:8000/chat/image', {
      method: 'POST',
      body: formData
    });
    
    const data = await response.json();
    setAnalysis(data.analysis);
    setLoading(false);
  };

  return (
    <div>
      <input type="file" accept="image/*" onChange={handleImageUpload} />
      {loading && <p>Analyzing...</p>}
      {analysis && <p>{analysis}</p>}
    </div>
  );
}
```

---

### Flutter - Audio Recording & Upload

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

Future<Map<String, dynamic>> processAudio(File audioFile) async {
  var request = http.MultipartRequest(
    'POST',
    Uri.parse('http://192.168.11.107:8000/chat/audio')
  );
  
  request.files.add(
    await http.MultipartFile.fromPath('audio', audioFile.path)
  );
  
  var response = await request.send();
  var responseData = await response.stream.bytesToString();
  
  return json.decode(responseData);
}

// Usage
var result = await processAudio(File('recording.wav'));
print('Transcription: ${result['transcription']}');
print('Answer: ${result['answer']}');
```

---

## 🧪 Test with cURL

### Image Test
```bash
curl -X POST http://192.168.11.107:8000/chat/image \
  -F "image=@diagram.png" \
  -F "question=Explain this diagram"
```

### Audio Test
```bash
curl -X POST http://192.168.11.107:8000/chat/audio \
  -F "audio=@question.wav"
```

---

## ⚠️ Important Notes

### File Size Limits
- Images: Max 10MB recommended
- Audio: Max 25MB recommended

### Supported Formats
- **Images**: JPG, PNG, GIF, WebP
- **Audio**: WAV, MP3, M4A, OGG

### Response Times
- Image analysis: 3-8 seconds
- Audio processing: 5-15 seconds (transcription + RAG + TTS)

---

## 🔒 Security Considerations

For production, add:
1. **File validation** (check actual file type, not just extension)
2. **Size limits** (prevent huge uploads)
3. **Rate limiting** (prevent spam)
4. **Authentication** (API keys)

---

## 📊 Testing in Swagger

Visit: `http://192.168.11.107:8000/docs`

You'll see the new endpoints:
- `/chat/image` - Try uploading an image
- `/chat/audio` - Try uploading audio

Interactive testing with file upload forms!

---

**🎉 Your friends can now integrate audio and image features! 🚀**
